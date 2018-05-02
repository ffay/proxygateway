local config = require "config"
local _M = {}
local log = ngx.log
local ERR = ngx.ERR

function open_redis()
    local redis = require "resty.redis"
    local red = redis:new()
    red:set_timeout(1000) -- 1 sec
    local ok, err = red:connect(config["redis_host"], config["redis_port"])
    if not ok then
        log(ERR, "failed to connect: ", err)
    end
    return red, err
end

function return_redis(red)
    -- put it into the connection pool of size 100,
    -- with 10 seconds max idle time
    local ok, err = red:set_keepalive(10000, 100)
    if not ok then
        log(ERR, "failed to set keepalive: ", err)
        return
    end
end

function _M.checkAccessLimit(uri, uriSeconds, uriTimes, ipUriSeconds, ipUriTimes)
    if not uriSeconds or not ipUriSeconds then
        return
    end

    local red, err = open_redis()
    if err then
        return
    end

    -- 针对整个接口限流
    if uriSeconds then
        local value, _ = red:get(uri)
        if value then
            if value >= uriTimes then
                return_redis()
                ngx.exit(403)
            end
            red:incr(uri)
        else
            red:setex(uri, uriSeconds, 1)
        end
    end

    -- 针对IP接口限流
    if ipUriSeconds then
        local headers = ngx.req.get_headers()
        local ip = headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"
        local value, _ = red:get(ip .. uri)
        if value then
            if value >= ipUriTimes then
                return_redis()
                ngx.exit(403)
            end
            red:incr(ip .. uri)
        else
            red:setex(ip .. uri, ipUriSeconds, 1)
        end
    end
    return_redis()
end

return _M