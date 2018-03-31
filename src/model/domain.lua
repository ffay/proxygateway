local mysql = require "model.mysql"
local domain_model = {}

function domain_model.addDomain(name)
    local db = mysql.getDb()
    local res, err, _, _ = db:query("INSERT INTO agw_domain (name)values(\'" .. name .. "\')", 10)
    db:set_keepalive(10000, 100)
    return res, err
end

function domain_model.delete(id)
    local db = mysql.getDb()
    local res, err, _, _ = db:query("DELETE FROM agw_domain WHERE id=" .. id, 10)
    db:set_keepalive(10000, 100)
    return res, err
end

function domain_model.update(id, name)
    local db = mysql.getDb()
    local res, err, _, _ = db:query("UPDATE agw_domain SET name=\'" .. name .. "\' WHERE id=" .. id, 10)
    db:set_keepalive(10000, 100)
    return res, err
end

function domain_model.getDomain(id)
    local db = mysql.getDb()
    local service, err, _, _ = db:query("SELECT * FROM agw_domain WHERE id=" .. id, 10)
    db:set_keepalive(10000, 100)
    return service, err
end

function domain_model.getDomains()
    local db = mysql.getDb()
    local res, err, _, _ = db:query("SELECT * FROM agw_domain ORDER BY id ASC", 10)
    db:set_keepalive(10000, 100)
    return res, err
end

return domain_model
