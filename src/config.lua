local config={};
config['mysql_host'] = "127.0.0.1"
config['mysql_port'] = "3306"
config['mysql_user'] = "root"
config['mysql_pass'] = ""
config['mysql_db'] = "agw"

config['admin_name'] = "admin"
config['admin_pass'] = "admin"

-- 需要通过接口远程管理时打开下面的配置
-- config['api_key'] = "your apikey"

return config;
