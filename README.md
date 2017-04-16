
**PGW（Proxy Gateway）**

Proxy Gateway基于openresty（nginx lua module）开发，可以作为接口网关（api gateway）使用，整合业务模块接口，微服务治理聚合，通过web配置界面，能够轻松进行代理配置管理，支持负载均衡，服务器状态检测，后续简称PGW。包括以下特性

- 支持多域名，可以配置多个出口域名，互不干扰
- 代理分组（服务模块），可以按照业务模块进行分组
- 负载均衡，可以给每组（每个业务模块）代理配置多台后端服务器，PGW会自动进行负载均衡
- 服务器监控，将down掉的服务器自动剔除，恢复以后自动加入
- 路径配置支持正则表达式对uri进行重写，例如 /user/([0-9]+)/profile   /user/profile/$1，所有访问/user/用户id/profile 都将被映射到 /user/profile/用户id
- 集群部署，PGW配置的MySQL数据库使用同一个就能达到集群效果，在任意一台PGW服务器上进行的配置都将在所有PGW服务器上生效
- https配置，与nginx配置一致，修改nginx.conf文件
- 高效，反向代理能力基本和原生nginx一致

**安装**

- 安装最新版本的openresty http://openresty.org/en/installation.html
- nginx.conf配置如下，如果按照默认路径（/usr/local/openresty/）安装，可以参考以下步骤

```shell
cd /usr/local/openresty/nginx
git clone https://github.com/ffay/proxygateway.git
```

然后把/usr/local/openresty/nginx/conf/nginx.conf 用源码中的nginx.conf替换即可
    

```nginx

worker_processes  2;

events {
    worker_connections  102400;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    lua_shared_dict cache 10m;

    #换成你的实际路径，这里将源码中src目录加入到 lua_package_path
    lua_package_path '/usr/local/openresty/nginx/proxygateway/src/?.lua;;';

    #lua_code_cache off;

    upstream servers {
      server 127.0.0.1;
      balancer_by_lua_block{
        local balancer = require "balancer"
        balancer.balancing()
      }
    }

    init_worker_by_lua_block{
        require "init"
    }

    server {
        listen  80  default_server;
        server_name localhost;

        location / {
            set $backend_host '127.0.0.1';
            set $backend_port 80;
            set $newhost '';
            set $upstream 'http://servers';
            access_by_lua_block{
                local access = require "access"
                access.dispatch()
            }
            proxy_set_header Host $newhost;
            proxy_http_version 1.1;
            proxy_pass $upstream;
        }
        error_log logs/error.log;
    }

    #将源码中的 manage.conf 路径
    include /usr/local/openresty/nginx/proxygateway/manage.conf;
}
```

- 配置manage.conf

```
server {
    listen 8081;
    server_name localhost;
    index index.html;
    location /api/v1 {
        access_by_lua_block{
            local access = require "manage.access"
            access.checkLogin()
        }
        content_by_lua_block{
          local ctl = require "manage.controller"
          ctl.run()
        }
    }

    location /static {
        #源码中html的实际路径
        root /usr/local/openresty/nginx/proxygateway/html;
    }

    location / {
        access_by_lua_block{
            local access = require "manage.access"
            access.checkLogin()
        }
        #源码中html的实际路径
        root /usr/local/openresty/nginx/proxygateway/html;
    }
}
```

- 在PGW源码中  src/config.lua 进行管理员以及MySQL相关配置
- 在数据库中运行pgw.sql脚本
- 启动openresty（openresty安装目录/nginx/sbin/nginx）
- 在浏览器中打开 http://ip:8081 ，如果是集群部署，打开任意一台的PGW管理界面进行配置即可，登录即可进行域名以及分组代理等配置管理，其中添加的域名需要解析到相应PGW的ip，如果前端还有负载均衡器（例如aws或aliyun的load balancing），域名直接解析到负载均衡器ip即可

**管理配置**
- 域（域名）管理，可以任意添加多个域名，默认域 localhost 在该域下的配置，直接访问IP生效，PGW通过域名进行配置隔离，每个域名下的配置互不干扰，需要将域名解析到PGW的IP
- 服务模块，每个域名下面可以添加多个服务模块，用于将接口按业务模块进行分组
- 后端服务器，每个服务模块下面可以配置多台后端服务器，可以为每台服务器指定权重，负载均衡时会按权重进行接口请求分发，支持http以及https代理
- 代理路径（uri）配置，每个服务模块下可配置多个代理uri规则，配置规则类似nginx location的配置，配置实例

|Request uri|Original uri|说明|
|:----    |:---|:----- |
|/ |/  |将所有对PGW某个域下的请求转发到后端服务器 |
|/u |/user  |将所有对PGW某个域下/u开头的请求重写成/user后转发到后端服务器，例如，请求 /u/1001 转发到后端服务器为 /user/1001 |
|/topic/([0-9]+)/([0-9]+)     |/topic?uid=$1&tid=$2  |支持正则匹配，请求 /topic/1001/2002 转发到后端服务器为  /topic?uid=1001&tid=2002  |
|/t%?tid=(.*)    |/topic?tid=$1  |支持正则匹配,Request uri中如果有 ? 出现，需要在前面加上 %，用于转义问号 |

所有接口映射配置必须以 / 开头，同一个域下面 Request uri 不能重复，Request uri字符串越长匹配优先级越高

**后续**

- 认证检测
- 访问频率控制
- IP黑白名单
- 数据统计
- 欢迎提出更多功能

