local cjson = require "cjson"
local app = {}
local routes ={}
function app:route(route, func)
    routes[route] = func
end

function app:run()
    local params = {}
    if ngx.req.get_method() == "POST" then
        ngx.req.read_body()
        params, err = ngx.req.get_post_args()
    end

    local get_params = ngx.req.get_uri_args()
    for name, param in pairs(get_params) do
        params[name] = param
    end

    for name, param in pairs(params) do
        param, index=string.gsub(param, "\'", "\\\'")
        params[name] = param
    end
    local response = {}
    response["status"] = 200
    response["errno"] = 0
    response["msg"] = "success"
    if routes[ngx.var.uri]~= nil then
        local res, err, errno = routes[ngx.var.uri](params)
        --ngx.log(ngx.ERR, res ,err)
        if err ~= nil then
            response["msg"] = err
            if errno == nil then
               response["errno"] = 1
            else
               response["errno"] = errno
            end
        else
            response["info"] = res
        end
    else
        response["status"] = 404
        response["errno"] = 161
        response["msg"] = "api not found"
        ngx.status = 404
    end
    ngx.header.content_type = 'application/json;charset=UTF-8';
    ngx.say(cjson.encode(response))
end

return app
