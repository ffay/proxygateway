local cjson = require "cjson"
local config = require "config"
local api_model = require "model.api"
local server_model = require "model.server"
local domain_model = require "model.domain"
local service_model = require "model.module"
local agw_service = require "service.agw"
local app = require "manage.app"
local _M = {}

function check_require_params(params, names)
    for k, name in pairs(names) do
        if params[name] == nil then
            ngx.header.content_type = 'application/json;charset=UTF-8';
            ngx.say(cjson.encode({errno = 101, status = 400, msg = "missing param:"..name}))
            ngx.status = 400
            ngx.exit(400)
        end
    end
end


function _M.run()
    app:route("/api/v1/login", function(params)
        check_require_params(params, {"username","password"})
        if params["username"] ~= config["admin_name"] then
            return nil,"error username",102
        end
        if params["password"] ~= config["admin_pass"] then
            return nil,"error password",102
        end
        local headers = ngx.req.get_headers()
        local resty_md5 = require "resty.md5"
        local str = require "resty.string"
        local md5 = resty_md5:new()
        local ok = md5:update(config["admin_name"]..config["admin_pass"]..headers["user-agent"]..os.time())
        local digest = md5:final()
        local token = str.to_hex(digest)
        local ck = require "resty.cookie"
        local cookie, err = ck:new()
        cookie:set({key = "token", value = token, path = "/"})
        local cache = ngx.shared.cache
        cache:set("login-token", token)
        return {token = token}
    end)

    app:route("/api/v1/logout", function(params)
        local cache = ngx.shared.cache
        cache:set("login-token", nil)
        return ngx.redirect("/login.html")
    end)

    app:route("/api/v1/domain/add", function(params)
        check_require_params(params, {"name"})
        return domain_model.addDomain(params["name"])
    end)

    app:route("/api/v1/domain/delete", function(params)
        check_require_params(params, {"domain_id"})
        return agw_service.deleteDomain(params["domain_id"])
    end)

    app:route("/api/v1/domain/update", function(params)
        check_require_params(params, {"domain_id","name"})
        return domain_model.update(params["domain_id"], params["name"])
    end)

    app:route("/api/v1/domain/all", function(params)
        local res, err = domain_model.getDomains()
        return res, err
    end)

    app:route("/api/v1/service/delete", function(params)
        check_require_params(params, {"service_id"})
        return agw_service.deleteService(params["service_id"])
    end)

    app:route("/api/v1/service/list", function(params)
        check_require_params(params, {"domain_id"})
        return agw_service.getServices(params["domain_id"])
    end)

    app:route("/api/v1/service/get", function(params)
        check_require_params(params, {"service_id"})
        return service_model.getService(params["service_id"])
    end)

    app:route("/api/v1/service/add", function(params)
        check_require_params(params, {"domain_id", "name","description"})
        return service_model.add(params["domain_id"], params["name"], params["host"], params["description"])
    end)

    app:route("/api/v1/service/edit", function(params)
        check_require_params(params, {"service_id", "name", "host", "description"})
        return service_model.update(params["service_id"], params["name"], params["host"], params["description"])
    end)

    app:route("/api/v1/server/list", function(params)
        check_require_params(params, {"service_id"})
        return server_model.getServiceServers(params["service_id"])
    end)

    app:route("/api/v1/server/add", function(params)
        check_require_params(params, {"service_id", "ip", "port", "weight", "description", "protocol"})
        return server_model.add(params["service_id"], params["ip"], params["port"], params["weight"], params["description"], params["protocol"])
    end)

    app:route("/api/v1/server/delete", function(params)
        check_require_params(params, {"server_id"})
        return server_model.delete(params["server_id"])
    end)

    app:route("/api/v1/server/get", function(params)
        check_require_params(params, {"server_id"})
        return server_model.getServer(params["server_id"])
    end)

    app:route("/api/v1/server/edit", function(params)
        check_require_params(params, {"server_id", "ip", "port", "weight", "description", "protocol"})
        return server_model.update(params["server_id"], params["ip"], params["port"], params["weight"], params["description"], params["protocol"])
    end)

    app:route("/api/v1/api/list", function(params)
        check_require_params(params, {"service_id"})
        return api_model.getServiceApis(params["service_id"])
    end)

    app:route("/api/v1/api/add", function(params)
        check_require_params(params, {"service_id","request_uri","original_uri","description"})
        return api_model.add(params["service_id"], params["request_uri"], params["original_uri"], params["description"])
    end)

    app:route("/api/v1/api/delete", function(params)
        check_require_params(params, {"api_id"})
        return api_model.delete(params["api_id"])
    end)

    app:route("/api/v1/api/get", function(params)
        check_require_params(params, {"api_id"})
        return api_model.getApi(params["api_id"])
    end)

    app:route("/api/v1/api/edit", function(params)
        check_require_params(params, {"api_id","request_uri","original_uri","description"})
        return api_model.update(params["api_id"], params["request_uri"], params["original_uri"], params["description"])
    end)

    app:run()
end

return _M
