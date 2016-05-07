local config=require "config"
local mysql = require "resty.mysql"

local log = ngx.log
local ERR = ngx.ERR
local DEBUG = ngx.DEBUG
local mysql_connection = {}

function mysql_connection.getDb()
    local db, err = mysql:new()
    local ok, err, errno, sqlstate = db:connect{
            host = config["mysql_host"],
            port = config["mysql_port"],
            database = config["mysql_db"],
            user = config["mysql_user"],
            password = config["mysql_pass"],
            max_packet_size = 1024 * 1024 }
    if not ok then
        log(ERR, "failed to connect to mysql", err)
        return
    end
	log(DEBUG, "connected to mysql")
	return db
end

return mysql_connection
