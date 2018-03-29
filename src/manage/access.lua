local _M = {}
local cjson = require "cjson"

function _M.checkLogin()
    local uri = ngx.var.uri
    if uri ~= "/api/v1/login" and uri ~= "/login.html" then
        local cache = ngx.shared.cache
        local token = cache:get("login-token")
        local ck = require "resty.cookie"
        local cookie, err = ck:new()
        local isApi = string.find(uri,"/api/v1/");
        if isApi and (token == nil or token ~= cookie:get("token")) then
            local response = {}
            response["status"] = 401
            response["errno"] = 40100
            response["msg"] = "Authentication required"
            ngx.header.content_type = 'application/json;charset=UTF-8';
            ngx.say(cjson.encode(response))
            return;
        end
        if token == nil or token ~= cookie:get("token") then
            return ngx.redirect("/login.html")
        end
    end
end

return _M