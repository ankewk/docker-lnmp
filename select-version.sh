#!/bin/bash

# LNMP 版本选择脚本
# 作者: Docker LNMP
# 版本: 1.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}    LNMP 版本选择工具    ${NC}"
    echo -e "${BLUE}================================${NC}"
}

# 显示PHP版本选择菜单
select_php_version() {
    echo ""
    echo "请选择 PHP 版本:"
    echo "1) PHP 7.4 (已停止支持)"
    echo "2) PHP 8.0 (安全支持到 2024-11-26)"
    echo "3) PHP 8.1 (安全支持到 2025-11-25)"
    echo "4) PHP 8.2 (安全支持到 2026-12-08) [推荐]"
    echo "5) PHP 8.3 (安全支持到 2027-11-27)"
    echo ""
    
    read -p "请输入选择 (1-5, 默认4): " php_choice
    
    case $php_choice in
        1) PHP_VERSION="7.4-fpm-alpine" ;;
        2) PHP_VERSION="8.0-fpm-alpine" ;;
        3) PHP_VERSION="8.1-fpm-alpine" ;;
        4|"") PHP_VERSION="8.2-fpm-alpine" ;;
        5) PHP_VERSION="8.3-fpm-alpine" ;;
        *) print_error "无效选择，使用默认版本 PHP 8.2"; PHP_VERSION="8.2-fpm-alpine" ;;
    esac
    
    print_message "已选择 PHP 版本: $PHP_VERSION"
}

# 显示MySQL版本选择菜单
select_mysql_version() {
    echo ""
    echo "请选择 MySQL 版本:"
    echo "1) MySQL 5.7 (已停止支持)"
    echo "2) MySQL 8.0 (安全支持到 2026-04-30) [推荐]"
    echo "3) MySQL 8.1 (安全支持到 2027-10-21)"
    echo ""
    
    read -p "请输入选择 (1-3, 默认2): " mysql_choice
    
    case $mysql_choice in
        1) MYSQL_VERSION="5.7" ;;
        2|"") MYSQL_VERSION="8.0" ;;
        3) MYSQL_VERSION="8.1" ;;
        *) print_error "无效选择，使用默认版本 MySQL 8.0"; MYSQL_VERSION="8.0" ;;
    esac
    
    print_message "已选择 MySQL 版本: $MYSQL_VERSION"
}

# 配置端口
configure_ports() {
    echo ""
    echo "端口配置 (按回车使用默认值):"
    
    read -p "Nginx 后端端口 (默认8888): " nginx_port
    NGINX_PORT=${nginx_port:-8888}
    
    read -p "Nginx 负载均衡器端口 (默认8889): " nginx_lb_port
    NGINX_LB_PORT=${nginx_lb_port:-8889}
    
    read -p "MySQL Master 端口 (默认33306): " mysql_master_port
    MYSQL_MASTER_PORT=${mysql_master_port:-33306}
    read -p "MySQL Slave 端口 (默认33307): " mysql_slave_port
    MYSQL_SLAVE_PORT=${mysql_slave_port:-33307}
    
    read -p "phpMyAdmin 端口 (默认8080): " pma_port
    PMA_PORT=${pma_port:-8080}
    
    print_message "端口配置完成"
}

# 配置数据库
configure_database() {
    echo ""
    echo "数据库配置 (按回车使用默认值):"
    
    read -p "MySQL Root 密码 (默认root123456): " root_password
    MYSQL_ROOT_PASSWORD=${root_password:-root123456}
    
    read -p "数据库名称 (默认lnmp_db): " db_name
    MYSQL_DATABASE=${db_name:-lnmp_db}
    
    read -p "数据库用户 (默认lnmp_user): " db_user
    MYSQL_USER=${db_user:-lnmp_user}
    
    read -p "数据库密码 (默认lnmp123456): " db_password
    MYSQL_PASSWORD=${db_password:-lnmp123456}
    
    print_message "数据库配置完成"
}

# 配置Redis
configure_redis() {
    echo ""
    echo "Redis配置 (按回车使用默认值):"
    
    read -p "Redis密码 (默认redis123456): " redis_password
    REDIS_PASSWORD=${redis_password:-redis123456}
    
    read -p "Redis端口 (默认6379): " redis_port
    REDIS_PORT=${redis_port:-6379}
    
    print_message "Redis配置完成"
}

# 配置MongoDB
configure_mongodb() {
    echo ""
    echo "MongoDB配置 (按回车使用默认值):"
    
    read -p "MongoDB Root用户 (默认admin): " mongo_user
    MONGO_ROOT_USER=${mongo_user:-admin}
    
    read -p "MongoDB Root密码 (默认mongodb123456): " mongo_password
    MONGO_ROOT_PASSWORD=${mongo_password:-mongodb123456}
    
    read -p "MongoDB数据库 (默认lnmp_mongo): " mongo_db
    MONGO_DATABASE=${mongo_db:-lnmp_mongo}
    
    read -p "MongoDB端口 (默认27017): " mongo_port
    MONGO_PORT=${mongo_port:-27017}
    
    print_message "MongoDB配置完成"
}

# 配置RabbitMQ
configure_rabbitmq() {
    echo ""
    echo "RabbitMQ配置 (按回车使用默认值):"
    
    read -p "RabbitMQ用户 (默认admin): " rabbitmq_user
    RABBITMQ_USER=${rabbitmq_user:-admin}
    
    read -p "RabbitMQ密码 (默认rabbitmq123456): " rabbitmq_password
    RABBITMQ_PASSWORD=${rabbitmq_password:-rabbitmq123456}
    
    read -p "RabbitMQ端口 (默认5672): " rabbitmq_port
    RABBITMQ_PORT=${rabbitmq_port:-5672}
    
    read -p "RabbitMQ管理端口 (默认15672): " rabbitmq_management_port
    RABBITMQ_MANAGEMENT_PORT=${rabbitmq_management_port:-15672}
    
    print_message "RabbitMQ配置完成"
}

# 生成.env文件
generate_env_file() {
    cat > .env << EOF
# LNMP Docker 环境配置文件
# 生成时间: $(date)

# PHP 版本选择
PHP_VERSION=$PHP_VERSION

# MySQL 版本选择
MYSQL_VERSION=$MYSQL_VERSION

# 端口配置
NGINX_PORT=$NGINX_PORT
NGINX_SSL_PORT=443
NGINX_LB_PORT=$NGINX_LB_PORT
NGINX_LB_SSL_PORT=444
MYSQL_MASTER_PORT=$MYSQL_MASTER_PORT
MYSQL_SLAVE_PORT=$MYSQL_SLAVE_PORT
PMA_PORT=$PMA_PORT

# 数据库配置
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_DATABASE=$MYSQL_DATABASE
MYSQL_USER=$MYSQL_USER
MYSQL_PASSWORD=$MYSQL_PASSWORD

# Redis配置
REDIS_VERSION=7-alpine
REDIS_PASSWORD=$REDIS_PASSWORD
REDIS_PORT=$REDIS_PORT
REDIS_COMMANDER_USER=admin
REDIS_COMMANDER_PASSWORD=$REDIS_PASSWORD
REDIS_COMMANDER_PORT=8081

# MongoDB配置
MONGODB_VERSION=7
MONGO_ROOT_USER=$MONGO_ROOT_USER
MONGO_ROOT_PASSWORD=$MONGO_ROOT_PASSWORD
MONGO_DATABASE=$MONGO_DATABASE
MONGO_PORT=$MONGO_PORT

# Kafka配置
KAFKA_VERSION=7.4.0
KAFKA_PORT=9092
ZOOKEEPER_PORT=2181

# RabbitMQ配置
RABBITMQ_VERSION=3-management-alpine
RABBITMQ_USER=$RABBITMQ_USER
RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD
RABBITMQ_VHOST=/
RABBITMQ_PORT=$RABBITMQ_PORT
RABBITMQ_MANAGEMENT_PORT=$RABBITMQ_MANAGEMENT_PORT
EOF

    print_message ".env 文件已生成"
}

# 显示配置摘要
show_summary() {
    echo ""
    echo -e "${BLUE}配置摘要:${NC}"
    echo "=================="
    echo "PHP 版本: $PHP_VERSION"
    echo "MySQL 版本: $MYSQL_VERSION"
    echo "Nginx 后端端口: $NGINX_PORT"
    echo "Nginx 负载均衡器端口: $NGINX_LB_PORT"
    echo "MySQL Master 端口: $MYSQL_MASTER_PORT"
    echo "MySQL Slave 端口: $MYSQL_SLAVE_PORT"
    echo "phpMyAdmin 端口: $PMA_PORT"
    echo "数据库名称: $MYSQL_DATABASE"
    echo "数据库用户: $MYSQL_USER"
    echo "Redis 端口: $REDIS_PORT"
    echo "MongoDB 端口: $MONGO_PORT"
    echo "Kafka 端口: $KAFKA_PORT"
    echo "RabbitMQ 端口: $RABBITMQ_PORT"
    echo "RabbitMQ 管理端口: $RABBITMQ_MANAGEMENT_PORT"
    echo "=================="
    echo ""
}

# 主函数
main() {
    print_header
    
    # 检查是否已存在.env文件
    if [ -f ".env" ]; then
        print_warning "检测到已存在的 .env 文件"
        read -p "是否要覆盖现有配置？(y/N): " overwrite
        if [[ ! $overwrite =~ ^[Yy]$ ]]; then
            print_message "操作已取消"
            exit 0
        fi
    fi
    
    # 选择版本
    select_php_version
    select_mysql_version
    
    # 配置端口
    configure_ports
    
    # 配置数据库
    configure_database
    
    # 配置Redis
    configure_redis
    
    # 配置MongoDB
    configure_mongodb
    
    # 配置RabbitMQ
    configure_rabbitmq
    
    # 显示摘要
    show_summary
    
    # 确认生成
    read -p "确认生成配置文件？(Y/n): " confirm
    if [[ $confirm =~ ^[Nn]$ ]]; then
        print_message "操作已取消"
        exit 0
    fi
    
    # 生成.env文件
    generate_env_file
    
    print_message "配置完成！现在可以运行 ./start.sh 启动服务"
}

# 执行主函数
main "$@" 