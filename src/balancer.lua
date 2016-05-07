local _M = {}

function _M.balancing()
	local balancer = require "ngx.balancer"
	local host = ngx.var.backend_host
	local port = ngx.var.backend_port
	local ok, err = balancer.set_current_peer(host, port)
	if not ok then
		ngx.log(ngx.ERR, "failed to set the current peer: ", err)
		return ngx.exit(500)
	end
	ok, err = balancer.set_more_tries(3)
	if not ok then
		ngx.log(ngx.ERR, "failed to set more tries: ", err)
		return ngx.exit(500)
	end
end

return _M