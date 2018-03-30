local agw_service = require "service.agw"

local log = ngx.log
local ERR = ngx.ERR
local DEBUG = ngx.DEBUG
local new_timer = ngx.timer.at

local api_sync_interval = 3
local server_state_check_interval = 20

local api_sync_timer
local server_state_check_timer

-- sync api proxy infos from mysql 
api_sync_timer = function(premature)
    if not premature then
        local ret, result = pcall(agw_service.syncApiInfo)
        if ret then
            log(DEBUG, "sync api info over")
        else
            log(ERR, "sync api info failed:", result)
        end
        new_timer(api_sync_interval, api_sync_timer)
    end
end

-- check servers' status
server_state_check_timer = function(premature)
    if not premature then
        local ret, result = pcall(agw_service.checkState)
        if ret then
            log(DEBUG, "server state check over")
        else
            log(ERR, "error occured when check server state:", result)
        end
        new_timer(server_state_check_interval, server_state_check_timer)
    end
end

local ok, err = new_timer(api_sync_interval, api_sync_timer)
if not ok then
    log(ERR, "failed to create timer: ", err)
    return
end

ok, err = new_timer(server_state_check_interval, server_state_check_timer)
if not ok then
    log(ERR, "failed to create timer: ", err)
    return
end
