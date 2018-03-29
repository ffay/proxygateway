local _M = {}

function test_output(content, status)
    ngx.header.content_type = 'application/json;charset=UTF-8';
    ngx.say(content)
    ngx.status = status
    ngx.exit(status)
end

function split(str, delimiter)
    if str == nil or str == '' or delimiter == nil then
        return nil
    end

    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

function rewrite(request_uri, reg, original_uri)
    i, j = string.find(request_uri, reg)
    if i ~= nil then
        local real_uri, index = string.gsub(request_uri, reg, original_uri, 1)
        return real_uri
    end
    return nil
end

function _M.dispatch()
    local cjson = require "cjson"
    local cache = ngx.shared.cache
    local config_str = cache:get(ngx.var.host);
    if config_str == nil then
        config_str = cache:get("localhost");
        if config_str == nil then
            ngx.exit(404)
        end
    end

    local config = cjson.decode(config_str)

    local real_uri
    local api_info
    local api_uri_array = config["api_uri_array"]
    local api_uri_map = config["api_uri_map"]
    local uri = ngx.var.uri
    if ngx.var.args ~= nil then
        uri = uri .. "?" .. ngx.var.args
    end

    for k, uri_regx in pairs(api_uri_array) do
        local api_info_t = api_uri_map[uri_regx];
        real_uri = rewrite(uri, api_info_t["request_uri"], api_info_t["original_uri"]);
        if (real_uri ~= nil) then
            api_info = api_info_t
            break;
        end
    end

    if api_info == nil then
        ngx.exit(404)
    end

    local servers = api_info["servers"]
    local server_count = table.getn(servers)

    if server_count == 0 then
        ngx.exit(503)
    end

    local request_index_cache_key = ngx.var.host .. "_request_index_" .. api_info["request_uri"]
    local request_index = cache:get(request_index_cache_key)
    if request_index == nil then
        request_index = 1
    end
    cache:set(request_index_cache_key, request_index + 1)
    local server = servers[request_index % server_count + 1];

    if api_info["host"] == "localhost" then
        api_info["host"] = ngx.var.host
    end

    if server["protocol"] ~= nil and server["protocol"] ~= "" then
        ngx.var.upstream = server["protocol"] .. "servers"
    end

    ngx.var.backend_host = server["ip"]
    ngx.var.backend_port = server["port"]
    ngx.var.newhost = api_info["host"]
    ngx.req.set_header("Host", api_info["host"])

    local uri_t = split(real_uri, "?")
    ngx.req.set_uri(uri_t[1])
    if table.getn(uri_t) == 2 then
        local uri_args = uri_t[2]
        ngx.req.set_uri_args(uri_args)
    else
        ngx.req.set_uri_args({})
    end
end

return _M