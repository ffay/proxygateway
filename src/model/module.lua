local mysql = require "model.mysql"
local service_model = {}

function service_model.add(domain_id, name, host, description)
    description = ndk.set_var.set_quote_sql_str(description)
    local db = mysql.getDb()
    local res, err, _, _ = db:query("INSERT INTO agw_service (domain_id, name,host,description)values(\'" .. domain_id .. "\',\'" .. name .. "\',\'" .. host .. "\'," .. description .. ")", 10)
    db:set_keepalive(10000, 100)
    return res, err
end

function service_model.deleteByDomainId(did)
    local db = mysql.getDb()
    local res, err, _, _ = db:query("DELETE FROM agw_service WHERE domain_id=" .. did, 10)
    db:set_keepalive(10000, 100)
    return res, err
end

function service_model.delete(id)
    local db = mysql.getDb()
    local res, err, _, _ = db:query("DELETE FROM agw_service WHERE id=" .. id, 10)
    db:set_keepalive(10000, 100)
    return res, err
end

function service_model.update(id, name, host, description)
    description = ndk.set_var.set_quote_sql_str(description)
    local db = mysql.getDb()
    local res, err, _, _ = db:query("UPDATE agw_service SET name=\'" .. name .. "\',host=\'" .. host .. "\',description=" .. description .. " WHERE id=" .. id, 10)
    db:set_keepalive(10000, 100)
    return res, err
end

function service_model.getService(id)
    local db = mysql.getDb()
    local services, err, _, _ = db:query("SELECT * FROM agw_service WHERE id=" .. id, 10)
    service = nil
    if table.getn(services) > 0 then
        service = services[1]
    else
        err = "error service id"
    end
    db:set_keepalive(10000, 100)
    return service, err
end

function service_model.getServices(domain_id)
    local db = mysql.getDb()
    local services, err, _, _ = db:query("SELECT * FROM agw_service WHERE domain_id=" .. domain_id, 10)
    db:set_keepalive(10000, 100)
    return services, err
end

return service_model
