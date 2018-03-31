local _M = {}
local cjson = require "cjson"
local config = require "config"

function _M.checkLogin()
    local params = ngx.req.get_uri_args()
    if params["api_key"] ~= nil and params["api_key"] == config["api_key"] then
        return 1
    end
    local uri = ngx.var.uri
    if uri ~= "/api/v1/login" and uri ~= "/login.html" then
        local session = ngx.shared.session
        local ck = require "resty.cookie"
        local cookie, _ = ck:new()
        local token = cookie:get("token")
        local user;
        if token ~= nil then
            user = session:get(token)
        end
        local isApi = string.find(uri, "/api/v1/");
        if isApi and user == nil then
            local response = {}
            response["status"] = 401
            response["errno"] = 40100
            response["msg"] = "Authentication required"
            ngx.header.content_type = 'application/json;charset=UTF-8';
            ngx.say(cjson.encode(response))
            ngx.exit(401)
            return;
        end
        if user == nil then
            return ngx.redirect("/login.html")
        end
    end
    return 1
end

return _M