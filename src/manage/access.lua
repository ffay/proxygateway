local _M = {}

function _M.checkLogin()
	local uri = ngx.var.uri
	if uri ~= "/api/v1/login" and uri ~= "/login.html" then
		local cache = ngx.shared.cache
		local token = cache:get("login-token")
	    local ck = require "resty.cookie"
	    local cookie, err = ck:new()
	    if token == nil or token ~= cookie:get("token") then
	    	return ngx.redirect("/login.html")
	    end
	end
end

return _M