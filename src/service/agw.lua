local cjson = require "cjson"
local api_model = require "model.api"
local service_model = require "model.module"
local server_model = require "model.server"
local domain_model = require "model.domain"

local cache = ngx.shared.domain_cache

local log = ngx.log
local ERR = ngx.ERR
local agw_service = {}

function check_state(ip, port)
    local sock = ngx.socket.tcp()
    sock:settimeout(5000)
    local ok, err = sock:connect(ip, port)
    sock:close()
    if not ok then
        log(ERR, "server connect err:", err)
        return false
    end
    return true
end

function set_domain_api_info(domainId, domainName)
    local services, _ = service_model.getServices(domainId)
    local service_api_uri_map = {}
    local service_api_uri_array = {}
    for _, service in pairs(services) do
        local servers = server_model.getServiceServersWithState(service["id"], 1)
        local apis = api_model.getServiceApis(service["id"])
        for _, api in pairs(apis) do
            api["servers"] = servers
            api["host"] = service["host"]
            if service["host"] == "" then
                api["host"] = domainName
            end
            local original_uri, _ = string.gsub(api["original_uri"], "%$([0-9]+)", "%%%1")
            api["original_uri"] = original_uri
            service_api_uri_map[api["request_uri"]] = api
            table.insert(service_api_uri_array, api["request_uri"])
        end
    end
    table.sort(service_api_uri_array, function(a, b) return string.len(a) > string.len(b) end)
    local config = { api_uri_map = service_api_uri_map, api_uri_array = service_api_uri_array }
    cache:set(domainName, cjson.encode(config))
end

function agw_service.syncApiInfo()
    local cachedDomains = cache:get_keys(0);
    local new_domain_map = {}
    local domains, _ = domain_model.getDomains()
    for _, domain in pairs(domains) do
        set_domain_api_info(domain["id"], domain["name"])
        new_domain_map[domain["name"]] = domain
    end
    -- 清除缓存中已删除的域名配置
    for _, domainName in pairs(cachedDomains) do
        if new_domain_map[domainName] == nil then
            cache:delete(domainName)
        end
    end
end

function agw_service.checkState()
    local servers = server_model.getAllServers()
    for _, server in pairs(servers) do
        if check_state(server["ip"], server["port"]) == false then
            log(ERR, "server down:", server["ip"] .. ":" .. server["port"])
            server_model.updateState(server["id"], 0)
        else
            server_model.updateState(server["id"], 1)
        end
    end
end

function agw_service.getServices(domainId)
    local services, err = service_model.getServices(domainId)
    for _, service in pairs(services) do
        local up_servers_count = table.getn(server_model.getServiceServersWithState(service["id"], 1))
        local down_servers_count = table.getn(server_model.getServiceServersWithState(service["id"], 0))
        local status = "no backend servers"
        if up_servers_count ~= 0 or down_servers_count ~= 0 then
            status = "up " .. up_servers_count .. ",down " .. down_servers_count
        end
        service["status"] = status
    end
    return services, err
end

function agw_service.deleteDomain(domainId)
    domain_model.delete(domainId)
    local services = service_model.getServices(domainId)
    for _, service in pairs(services) do
        api_model.deleteByServiceId(service["id"])
        server_model.deleteByServiceId(service["id"])
    end
    service_model.deleteByDomainId(domainId)
end

function agw_service.deleteService(serviceId)
    api_model.deleteByServiceId(serviceId)
    server_model.deleteByServiceId(serviceId)
    service_model.delete(serviceId)
end

return agw_service
