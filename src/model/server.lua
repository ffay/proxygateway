local mysql = require "model.mysql"
local server_model = {}

function server_model.add(service_id, ip, port, weight, description, protocol)
    description = ndk.set_var.set_quote_sql_str(description)
    local db = mysql.getDb()
    local res, err, _, _ = db:query("INSERT INTO agw_server(service_id,ip,port,weight,description,protocol)values(\'" .. service_id .. "\',\'" .. ip .. "\',\'" .. port .. "\',\'" .. weight .. "\'," .. description .. ",\'" .. protocol .. "\')", 10)
    db:set_keepalive(10000, 100)
    return res, err
end

function server_model.delete(server_id)
    local db = mysql.getDb()
    local res, err, _, _ = db:query("DELETE FROM agw_server WHERE id=" .. server_id, 10)
    db:set_keepalive(10000, 100)
    return res, err
end

function server_model.deleteByServiceId(sid)
    local db = mysql.getDb()
    local res, err, _, _ = db:query("DELETE FROM agw_server WHERE service_id=" .. sid, 10)
    db:set_keepalive(10000, 100)
    return res, err
end

function server_model.update(server_id, ip, port, weight, description, protocol)
    description = ndk.set_var.set_quote_sql_str(description)
    local db = mysql.getDb()
    local res, err, _, _ = db:query("UPDATE agw_server SET ip=\'" .. ip .. "\',port=" .. port .. ",protocol=\'" .. protocol .. "\',weight=\'" .. weight .. "\',description=" .. description .. " WHERE id=" .. server_id, 10)
    db:set_keepalive(10000, 100)
    return res, err
end

function server_model.getServers(state)
    local db = mysql.getDb()
    local servers, _, _, _ = db:query("SELECT * FROM agw_server WHERE status=" .. state, 10)
    db:set_keepalive(10000, 100)
    if not servers then
        return
    end
    return servers
end

function server_model.getServiceServers(service_id)
    local db = mysql.getDb()
    local servers, err, errno, sqlstate = db:query("SELECT * FROM agw_server WHERE service_id=" .. service_id, 10)
    return servers, err
end

function server_model.getServiceServersWithState(service_id, state)
    local db = mysql.getDb()
    local servers, err, _, _ = db:query("SELECT * FROM agw_server WHERE service_id=" .. service_id .. " AND status=" .. state, 10)
    db:set_keepalive(10000, 100)
    return servers, err
end

function server_model.getServer(id)
    local db = mysql.getDb()
    local servers, err, _, _ = db:query("SELECT * FROM agw_server WHERE id=" .. id, 10)
    db:set_keepalive(10000, 100)
    server = nil
    if table.getn(servers) > 0 then
        server = servers[1]
    else
        err = "error server id"
    end
    return server, err
end

function server_model.getServersByMid(mid)
    local db = mysql.getDb()
    local servers, _, _, _ = db:query("SELECT * FROM agw_server WHERE mid=" .. mid, 10)
    db:set_keepalive(10000, 100)
    if not servers then
        return
    end
    return servers
end

function server_model.getAllServers()
    local db = mysql.getDb()
    local servers, _, _, _ = db:query("SELECT * FROM agw_server", 10)
    db:set_keepalive(10000, 100)
    if not servers then
        return
    end
    return servers
end

function server_model.updateState(sid, state)
    local db = mysql.getDb()
    local res, err, _, _ = db:query("UPDATE agw_server SET status=" .. state .. " WHERE id=" .. sid, 10)
    db:set_keepalive(10000, 100)
    if not res then
        ngx.log(ngx.ERR, "update server state err:", err);
        return false
    end
    return true
end

return server_model
