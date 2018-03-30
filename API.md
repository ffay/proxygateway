## api_key
api_key可以在config.lua中增加配置
```lua
config['api_key'] = "your api key string"
```

## 域名
### 添加域名
#### 接口地址
- POST /api/v1/domain/add?api_key={api_key}
#### 表单参数
| 参数               | 是否必须     | 说明                                      |
| ---------------- | ------ | --------------------------------------- |
| name      | 是 | 域名名称                                  |

#### 返回示例
```json
{
    "info": {
        "insert_id": 17,
        "affected_rows": 1,
        "server_status": 2,
        "warning_count": 0
    },
    "errno": 0,
    "status": 200,
    "msg": "success"
}
```

### 删除域名
#### 接口地址
- POST /api/v1/domain/delete?api_key={api_key}
#### 表单参数
| 参数               | 是否必须     | 说明                                      |
| ---------------- | ------ | --------------------------------------- |
| domain_id      | 是 | 域名ID                                  |

#### 返回示例
```json
{
    "errno": 0,
    "status": 200,
    "msg": "success"
}
```
> 域名删除时会删除所有域名相关的数据，慎用

### 修改域名
#### 接口地址
- POST /api/v1/domain/update?api_key={api_key}
#### 表单参数
| 参数               | 是否必须     | 说明                                      |
| ---------------- | ------ | --------------------------------------- |
| domain_id      | 是 | 域名ID                                  |
| name      | 是 | 域名名称                                  |

#### 返回示例
```json
{
    "errno": 0,
    "status": 200,
    "msg": "success"
}
```
> 域名删除时会删除所有域名相关的数据，慎用

### 查询已添加域名列表
#### 接口地址
- GET /api/v1/domain/all?api_key={api_key}

#### 返回示例
```json
{
    "info": [
        {
            "name": "www.xxx.com",
            "id": 2
        }
    ],
    "errno": 0,
    "status": 200,
    "msg": "success"
}
```

## 模块
> 每个域名下可以有多个模块

- /api/v1/service/add
- /api/v1/service/edit
- /api/v1/service/delete
- /api/v1/service/get
- /api/v1/service/list

## 服务器
> 每个模块可以有多个后端服务器

- /api/v1/server/add
- /api/v1/server/edit
- /api/v1/server/delete
- /api/v1/server/get
- /api/v1/server/list

## URI映射
> 每个模块可以有多个URI接口映射

- /api/v1/api/add
- /api/v1/api/edit
- /api/v1/api/delete
- /api/v1/api/get
- /api/v1/api/list