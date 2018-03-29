local mysql = require "model.mysql"
local api_model = {}

-- 由于系统都是内部使用，对SQL注入问题没有特殊处理
function api_model.getApis()
    local db = mysql.getDb()
	local apis, err, errno, sqlstate = db:query("select * from agw_api", 10)
    db:set_keepalive(10000, 10)
    return apis, err
end

function api_model.add(service_id, request_uri, original_uri, description)
    local db = mysql.getDb()
    description = ndk.set_var.set_quote_sql_str(description)
	local res, err, errno, sqlstate = db:query("INSERT INTO agw_api (service_id,request_uri,original_uri,description)values(\'"..service_id.."\',\'"..request_uri.."\',\'"..original_uri.."\',"..description..")", 10)
    db:set_keepalive(10000, 10)
    return res, err
end

function api_model.delete(aid)
    local db = mysql.getDb()
	local res, err, errno, sqlstate = db:query("DELETE FROM agw_api WHERE id="..aid, 10)
    db:set_keepalive(10000, 10)
    return res, err
end

function api_model.deleteByServiceId(sid)
    local db = mysql.getDb()
	local res, err, errno, sqlstate = db:query("DELETE FROM agw_api WHERE service_id="..sid, 10)
    db:set_keepalive(10000, 10)
    return res, err
end

function api_model.update(id, request_uri, original_uri, description)
    local db = mysql.getDb()
    description = ndk.set_var.set_quote_sql_str(description)
	local res, err, errno, sqlstate = db:query("UPDATE agw_api SET request_uri=\'"..request_uri.."\',original_uri=\'"..original_uri.."\',description="..description.." WHERE id="..id, 10)
    db:set_keepalive(10000, 10)
    return res, err
end

function api_model.getApi(id)
    local db = mysql.getDb()
    local apis, err, errno, sqlstate = db:query("SELECT * FROM agw_api WHERE id="..id, 10)
    api = nil
    if table.getn(apis) > 0 then
        api = apis[1]
    else
        err = "error api id"
    end
    db:set_keepalive(10000, 10)
    return api, err
end

function api_model.getServiceApis(sid)
    local db = mysql.getDb()
	local services, err, errno, sqlstate = db:query("SELECT * FROM agw_api WHERE service_id="..sid, 10)
    db:set_keepalive(10000, 10)
    return services, err
end

return api_model
