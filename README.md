# LNMP Docker 环境

一个基于 Docker Compose 的完整 LNMP (Linux + Nginx + MySQL + PHP) 开发环境。

## 🚀 特性

- **完整的 LNMP 栈**: Nginx + MySQL + PHP + phpMyAdmin
- **MySQL 主从复制**: 支持 MySQL Master-Slave 复制集群
- **多版本支持**: 支持 PHP 7.4/8.0/8.1/8.2/8.3 和 MySQL 5.7/8.0/8.1
- **缓存和消息队列**: Redis + MongoDB + Kafka + RabbitMQ
- **gRPC 和 Composer 支持**: 完整的 gRPC 扩展和 Composer 依赖管理
- **代码热加载**: 开发模式下文件修改自动生效，无需重启容器
- **Docker Compose 编排**: 一键启动所有服务
- **优化的配置**: 针对开发环境优化的性能和安全设置
- **便捷的管理脚本**: 支持 Linux/macOS 和 Windows
- **数据持久化**: 数据库和日志数据持久化存储
- **现代化 UI**: 美观的示例页面和状态监控
- **版本选择工具**: 交互式版本选择和配置

## 📋 系统要求

- Docker 20.10+
- Docker Compose 2.0+
- 至少 2GB 可用内存
- 至少 5GB 可用磁盘空间

## 🛠️ 快速开始

### 1. 克隆项目

```bash
git clone <repository-url>
cd docker-lnmp
```

### 2. 选择版本 (可选)

**Linux/macOS:**
```bash
chmod +x select-version.sh
./select-version.sh
```

**Windows:**
```cmd
select-version.bat
```

### 3. 启动服务

**Linux/macOS:**
```bash
chmod +x start.sh
./start.sh
```

**Windows:**
```cmd
start.bat
```

或者直接使用 Docker Compose:
```bash
docker-compose up -d --build
```

### 3. 访问服务

- **网站首页**: http://localhost:8888 (后端) / http://localhost:8889 (负载均衡器)
- **phpMyAdmin**: http://localhost:8080
- **PHP信息**: http://localhost:8888/phpinfo.php (后端) / http://localhost:8889/phpinfo.php (负载均衡器)
- **Redis管理**: http://localhost:8081
- **RabbitMQ管理**: http://localhost:15672
- **负载均衡器健康检查**: http://localhost:8889/health

## 📁 项目结构

```
docker-lnmp/
├── docker-compose.yml          # Docker Compose 配置
├── Dockerfile.php             # PHP 自定义镜像
├── start.sh                   # Linux/macOS 管理脚本
├── start.bat                  # Windows 管理脚本
├── nginx/
│   └── conf.d/
│       └── default.conf       # Nginx 配置
├── php/
│   ├── php.ini               # PHP 配置
│   └── php-fpm.conf          # PHP-FPM 配置
├── mysql/
│   └── conf/
│       └── my.cnf            # MySQL 配置
└── www/
    ├── index.php             # 示例首页
    └── phpinfo.php           # PHP 信息页面
```

## 🔧 服务配置

### 支持的版本

| 组件 | 版本 | 状态 |
|------|------|------|
| PHP | 7.4, 8.0, 8.1, 8.2, 8.3 | 全部支持 |
| MySQL | 5.7, 8.0, 8.1 | 全部支持 |
| Nginx | Alpine | 最新版本 |
| phpMyAdmin | 最新版本 | 最新版本 |
| Redis | 7-alpine | 最新版本 |
| MongoDB | 7 | 最新版本 |
| Kafka | 7.4.0 | 最新版本 |
| RabbitMQ | 3-management-alpine | 最新版本 |

### 端口映射

| 服务 | 默认端口 | 可配置 | 说明 |
|------|----------|--------|------|
| Nginx 负载均衡器 | 8889 | 是 | 负载均衡器 |
| Nginx 后端 | 8888 | 是 | Web 服务器 |
| MySQL Master | 33306 | 是 | 主数据库服务 |
| MySQL Slave | 33307 | 是 | 从数据库服务 |
| phpMyAdmin | 8080 | 是 | 数据库管理界面 |
| Redis | 6379 | 是 | 缓存服务 |
| Redis Commander | 8081 | 是 | Redis 管理界面 |
| MongoDB | 27017 | 是 | NoSQL 数据库 |
| Kafka | 9092 | 是 | 消息队列 |
| Zookeeper | 2181 | 是 | Kafka 协调服务 |
| RabbitMQ | 5672 | 是 | 消息队列 |
| RabbitMQ Management | 15672 | 是 | RabbitMQ 管理界面 |

### 环境变量配置

可以通过 `.env` 文件或环境变量配置以下参数：

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `PHP_VERSION` | 8.2-fpm-alpine | PHP 版本 |
| `MYSQL_VERSION` | 8.0 | MySQL 版本 |
| `NGINX_PORT` | 8888 | Nginx 后端端口 |
| `NGINX_LB_PORT` | 8889 | Nginx 负载均衡器端口 |
| `MYSQL_MASTER_PORT` | 33306 | MySQL 主库端口 |
| `MYSQL_SLAVE_PORT` | 33307 | MySQL 从库端口 |
| `PMA_PORT` | 8080 | phpMyAdmin 端口 |
| `MYSQL_ROOT_PASSWORD` | root123456 | MySQL root 密码 |
| `MYSQL_DATABASE` | lnmp_db | 数据库名称 |
| `MYSQL_USER` | lnmp_user | 数据库用户 |
| `MYSQL_PASSWORD` | lnmp123456 | 数据库密码 |
| `REDIS_PASSWORD` | redis123456 | Redis 密码 |
| `REDIS_PORT` | 6379 | Redis 端口 |
| `REDIS_COMMANDER_PORT` | 8081 | Redis 管理端口 |
| `MONGO_ROOT_USER` | admin | MongoDB root 用户 |
| `MONGO_ROOT_PASSWORD` | mongodb123456 | MongoDB root 密码 |
| `MONGO_DATABASE` | lnmp_mongo | MongoDB 数据库 |
| `MONGO_PORT` | 27017 | MongoDB 端口 |
| `KAFKA_PORT` | 9092 | Kafka 端口 |
| `ZOOKEEPER_PORT` | 2181 | Zookeeper 端口 |
| `RABBITMQ_USER` | admin | RabbitMQ 用户 |
| `RABBITMQ_PASSWORD` | rabbitmq123456 | RabbitMQ 密码 |
| `RABBITMQ_PORT` | 5672 | RabbitMQ 端口 |
| `RABBITMQ_MANAGEMENT_PORT` | 15672 | RabbitMQ 管理端口 |

## 📝 管理命令

### 使用管理脚本

**Linux/macOS:**
```bash
./start.sh [命令]
```

**Windows:**
```cmd
start.bat [命令]
```

### 版本选择工具

**Linux/macOS:**
```bash
./select-version.sh
```

**Windows:**
```cmd
select-version.bat
```

### 负载均衡器管理工具

**Linux/macOS:**
```bash
./lb-manager.sh [命令]
```

**Windows:**
```cmd
lb-manager.bat [命令]
```

可用命令：
- `start` - 启动负载均衡器
- `stop` - 停止负载均衡器
- `restart` - 重启负载均衡器
- `status` - 查看状态
- `test` - 测试负载均衡
- `config` - 查看配置
- `stats` - 查看统计
- `enter` - 进入负载均衡器容器
- `backend` - 进入后端服务器容器
- `logs` - 查看日志
- `reload` - 重新加载配置

### 快速测试负载均衡器

**Linux/macOS:**
```bash
./test-loadbalancer.sh
```

**Windows:**
```cmd
test-loadbalancer.bat
```

### 快速测试 gRPC 功能

**Linux/macOS:**
```bash
./test-grpc.sh
```

**Windows:**
```cmd
test-grpc.bat
```

### 开发模式（热加载）

**Linux/macOS:**
```bash
./dev.sh start
```

**Windows:**
```cmd
dev.bat start
```

开发模式特性：
- 代码热加载（文件修改自动生效）
- 文件变化监控
- 开发模式PHP配置
- 详细错误日志
- Xdebug调试支持

### 可用命令

| 命令 | 说明 |
|------|------|
| `start` | 启动所有服务 |
| `stop` | 停止所有服务 |
| `restart` | 重启所有服务 |
| `status` | 查看服务状态 |
| `logs` | 查看服务日志 |
| `enter [service]` | 进入指定容器 |
| `backup` | 备份数据库 |
| `clean` | 清理所有数据 |
| `help` | 显示帮助信息 |

### 直接使用 Docker Compose

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 查看日志
docker-compose logs -f

# 进入容器
docker-compose exec php sh
docker-compose exec mysql-master mysql -u root -p
docker-compose exec mysql-slave mysql -u root -p
```

## ⚖️ 负载均衡器

### 负载均衡架构

本项目配置了 Nginx 负载均衡器：

- **负载均衡器**: 端口 8889，接收所有客户端请求
- **后端服务器**: 端口 8888，处理实际业务请求

### 负载均衡特性

- **算法**: 轮询 (Round Robin)
- **健康检查**: 自动检测后端服务器状态
- **故障转移**: 自动剔除故障服务器
- **会话保持**: 支持基于 IP 的会话保持

### 负载均衡器配置

```bash
# 查看负载均衡器状态
curl http://localhost:8889/health

# 测试负载均衡
curl http://localhost:8889/lb-test.php

# 查看负载均衡器日志
docker-compose logs nginx-loadbalancer
```

### 扩展后端服务器

如需添加更多后端服务器，编辑 `nginx/loadbalancer.conf`：

```nginx
upstream backend_servers {
    server nginx-backend:80 max_fails=3 fail_timeout=30s;
    server nginx-backend-2:80 max_fails=3 fail_timeout=30s;
    server nginx-backend-3:80 max_fails=3 fail_timeout=30s;
}
```

### 负载均衡算法

支持以下算法（在 `nginx/loadbalancer.conf` 中配置）：

- **轮询** (默认): 按顺序分发请求
- **最少连接**: `least_conn;`

## 🚀 gRPC 和 Composer 支持

### gRPC 扩展

本项目已预装 gRPC 和 Protobuf 扩展：

- **gRPC 扩展**: 支持高性能的 RPC 通信
- **Protobuf 扩展**: 支持 Protocol Buffers 序列化
- **示例代码**: 包含完整的 gRPC 服务器和客户端示例

### Composer 支持

- **Composer 预装**: PHP 镜像已预装最新版本的 Composer
- **依赖管理**: 支持自动加载和依赖管理
- **示例项目**: 包含 gRPC 项目的 Composer 配置

### gRPC 使用示例

```bash
# 进入 PHP 容器
docker-compose exec php sh

# 安装 gRPC 依赖
composer install

# 生成 Protobuf 类
protoc --php_out=generated --grpc_out=generated hello.proto

# 启动 gRPC 服务器
php www/grpc/server.php

# 运行 gRPC 客户端
php www/grpc/client.php
```

### 测试 gRPC 功能

访问以下页面测试 gRPC 功能：

- **gRPC 测试页面**: http://localhost:8888/grpc-test.php
- **gRPC 项目目录**: http://localhost:8888/grpc/
- **Protobuf 定义**: http://localhost:8888/grpc/hello.proto
- **热加载测试页面**: http://localhost:8888/hot-reload-test.php

### Composer 命令

```bash
# 安装依赖
composer install

# 添加新包
composer require package/name

# 更新依赖
composer update

# 重新生成自动加载
composer dump-autoload

# 查看已安装的包
composer show
```

## 🔥 代码热加载功能

### 热加载特性

本项目支持完整的代码热加载功能，让开发更加高效：

- **文件修改立即生效**: 修改代码文件后无需重启容器
- **自动文件监控**: 实时监控文件变化并记录日志
- **开发模式优化**: 针对开发环境优化的PHP配置
- **详细错误日志**: 完整的错误报告和日志记录
- **Xdebug调试支持**: 集成Xdebug调试功能

### 启动开发模式

**Linux/macOS:**
```bash
# 启动开发环境
./dev.sh start

# 查看开发环境状态
./dev.sh status

# 查看文件变化日志
./dev.sh logs

# 停止开发环境
./dev.sh stop
```

**Windows:**
```cmd
# 启动开发环境
dev.bat start

# 查看开发环境状态
dev.bat status

# 查看文件变化日志
dev.bat logs

# 停止开发环境
dev.bat stop
```

### 开发模式配置

开发模式使用 `docker-compose.dev.yml` 覆盖文件，提供以下优化：

- **OPcache禁用**: 确保代码修改立即生效
- **错误显示启用**: 显示详细的错误信息
- **文件监控**: 自动监控文件变化
- **开发工具**: 提供开发辅助服务

### 测试热加载功能

1. **启动开发环境**:
   ```bash
   ./dev.sh start
   ```

2. **访问测试页面**:
   ```
   http://localhost:8888/hot-reload-test.php
   ```

3. **修改测试文件**:
   - 编辑 `www/hot-reload-test.php`
   - 修改颜色、文字或其他内容
   - 保存文件

4. **查看变化**:
   - 刷新页面或等待自动刷新
   - 确认修改立即生效

### 开发模式管理命令

| 命令 | 说明 |
|------|------|
| `start` | 启动开发环境 |
| `stop` | 停止开发环境 |
| `restart` | 重启开发环境 |
| `status` | 查看服务状态 |
| `logs` | 查看文件变化日志 |
| `php-logs` | 查看PHP错误日志 |
| `nginx-logs` | 查看Nginx访问日志 |
| `enter-php` | 进入PHP容器 |
| `enter-nginx` | 进入Nginx容器 |
| `health` | 健康检查 |
| `test-watcher` | 测试文件监控 |
| `clean` | 清理开发环境 |

### 文件监控日志

开发模式会自动监控文件变化并记录到 `dev-tools/file-changes.log`：

```bash
# 查看文件变化日志
./dev.sh logs

# 或者直接查看日志文件
tail -f dev-tools/file-changes.log
```

### 开发环境目录结构

```
docker-lnmp/
├── dev-tools/              # 开发工具目录
│   └── file-changes.log    # 文件变化日志
├── logs/                   # 日志目录
│   ├── php/               # PHP错误日志
│   └── nginx/             # Nginx访问日志
├── tmp/                   # 临时文件目录
│   └── php/               # PHP临时文件
└── www/                   # 网站代码目录
    └── hot-reload-test.php # 热加载测试页面
```
- **IP哈希**: `ip_hash;`
- **一致性哈希**: `hash $request_uri consistent;`

## 🔄 MySQL 主从复制

### 复制架构

本项目配置了 MySQL 主从复制集群：

- **Master (主库)**: 端口 3306，处理写操作
- **Slave (从库)**: 端口 3307，处理读操作

### 复制状态检查

```bash
# 检查主库状态
docker-compose exec mysql-master mysql -u root -p -e "SHOW MASTER STATUS\G"

# 检查从库状态
docker-compose exec mysql-slave mysql -u root -p -e "SHOW SLAVE STATUS\G"
```

### 测试复制功能

1. **在主库创建数据**:
```sql
USE test_db;
INSERT INTO users (name, email) VALUES ('Test User', 'test@example.com');
```

2. **在从库验证数据**:
```sql
USE test_db;
SELECT * FROM users;
```

### 复制配置

- **主库配置**: `mysql/conf/master.cnf`
- **从库配置**: `mysql/conf/slave.cnf`
- **初始化脚本**: `mysql/init-master.sql`
- **复制设置脚本**: `mysql/setup-slave.sh`

### 注意事项

- 从库为只读模式，不能直接写入数据
- 主库故障时，需要手动切换主从角色
- 建议定期备份主从数据

## 🔍 故障排除

### 常见问题

1. **端口冲突**
   - 检查 80、3306、8080 端口是否被占用
   - 修改 `docker-compose.yml` 中的端口映射

2. **权限问题**
   - 确保 Docker 有足够权限访问项目目录
   - 在 Linux 上可能需要使用 `sudo`

3. **数据库连接失败**
   - 等待 MySQL 完全启动（首次启动需要几分钟）
   - 检查数据库配置是否正确

4. **PHP 扩展缺失**
   - 重新构建 PHP 镜像: `docker-compose build php`
   - 检查 `Dockerfile.php` 中的扩展安装

### 查看日志

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f nginx
docker-compose logs -f php
docker-compose logs -f mysql
```

## 🔒 安全配置

### 生产环境建议

1. **修改默认密码**
   - 更新 `docker-compose.yml` 中的数据库密码
   - 使用强密码和随机字符串

2. **SSL 证书**
   - 在 `nginx/ssl/` 目录放置 SSL 证书
   - 配置 HTTPS 虚拟主机

3. **防火墙设置**
   - 只开放必要的端口
   - 限制数据库访问

4. **定期备份**
   ```bash
   ./start.sh backup
   ```

## 📚 开发指南

### 添加新的 PHP 扩展

1. 编辑 `Dockerfile.php`
2. 添加扩展安装命令
3. 重新构建镜像: `docker-compose build php`

### 自定义 Nginx 配置

1. 编辑 `nginx/conf.d/default.conf`
2. 重启 Nginx: `docker-compose restart nginx`

### 数据库管理

- **phpMyAdmin**: http://localhost:8080
- **命令行**: `docker-compose exec mysql mysql -u root -p`

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## �� 致谢

感谢所有开源项目的贡献者！
