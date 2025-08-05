#!/bin/bash

# LNMP Docker 环境启动脚本
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
    echo -e "${BLUE}    LNMP Docker 环境管理脚本    ${NC}"
    echo -e "${BLUE}================================${NC}"
}

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
}

# 创建必要的目录
create_directories() {
    print_message "创建必要的目录..."
    
    mkdir -p nginx/conf.d
    mkdir -p nginx/ssl
    mkdir -p nginx/logs
    mkdir -p php
    mkdir -p mysql/master-data
    mkdir -p mysql/slave-data
    mkdir -p mysql/conf
    mkdir -p mysql/logs
    mkdir -p www
    mkdir -p redis/data
    mkdir -p redis/conf
    mkdir -p mongodb/data
    mkdir -p mongodb/logs
    mkdir -p kafka/zookeeper/data
    mkdir -p kafka/zookeeper/logs
    mkdir -p kafka/kafka/data
    mkdir -p kafka/kafka/logs
    mkdir -p rabbitmq/data
    mkdir -p rabbitmq/logs
    
    print_message "目录创建完成"
}

# 启动服务
start_services() {
    print_message "启动 LNMP 服务..."
    
    # 检查是否存在.env文件
    if [ ! -f ".env" ]; then
        print_warning "未找到 .env 文件，将使用默认配置"
        print_message "建议运行 ./select-version.sh 进行配置"
    fi
    
    docker-compose up -d --build
    
    if [ $? -eq 0 ]; then
        print_message "服务启动成功！"
        print_message "访问地址:"
        
        # 从.env文件读取端口配置
        if [ -f ".env" ]; then
            source .env
            echo "  - 网站: http://localhost:${NGINX_PORT:-80}"
            echo "  - phpMyAdmin: http://localhost:${PMA_PORT:-8080}"
            echo "  - PHP信息: http://localhost:${NGINX_PORT:-80}/phpinfo.php"
            echo "  - Redis管理: http://localhost:${REDIS_COMMANDER_PORT:-8081}"
            echo "  - RabbitMQ管理: http://localhost:${RABBITMQ_MANAGEMENT_PORT:-15672}"
        else
            echo "  - 网站: http://localhost"
            echo "  - phpMyAdmin: http://localhost:8080"
            echo "  - PHP信息: http://localhost/phpinfo.php"
            echo "  - Redis管理: http://localhost:8081"
            echo "  - RabbitMQ管理: http://localhost:15672"
        fi
    else
        print_error "服务启动失败"
        exit 1
    fi
}

# 停止服务
stop_services() {
    print_message "停止 LNMP 服务..."
    docker-compose down
    print_message "服务已停止"
}

# 重启服务
restart_services() {
    print_message "重启 LNMP 服务..."
    docker-compose down
    docker-compose up -d --build
    print_message "服务重启完成"
}

# 查看日志
show_logs() {
    print_message "显示服务日志..."
    docker-compose logs -f
}

# 查看服务状态
show_status() {
    print_message "服务状态:"
    docker-compose ps
}

# 进入容器
enter_container() {
    local service=$1
    if [ -z "$service" ]; then
        print_error "请指定服务名称 (nginx|php|mysql|phpmyadmin)"
        exit 1
    fi
    
    print_message "进入 $service 容器..."
    docker-compose exec $service sh
}

# 备份数据库
backup_database() {
    local backup_file="mysql_backup_$(date +%Y%m%d_%H%M%S).sql"
    print_message "备份数据库到 $backup_file..."
    docker-compose exec mysql mysqldump -u root -proot123456 lnmp_db > "$backup_file"
    print_message "数据库备份完成: $backup_file"
}

# 清理数据
clean_data() {
    print_warning "这将删除所有数据，包括数据库！"
    read -p "确定要继续吗？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_message "清理数据..."
        docker-compose down -v
        rm -rf mysql/data/*
        rm -rf nginx/logs/*
        print_message "数据清理完成"
    else
        print_message "操作已取消"
    fi
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  start     启动所有服务"
    echo "  stop      停止所有服务"
    echo "  restart   重启所有服务"
    echo "  status    查看服务状态"
    echo "  logs      查看服务日志"
    echo "  enter     进入指定容器 (用法: $0 enter [service])"
    echo "  backup    备份数据库"
    echo "  clean     清理所有数据"
    echo "  help      显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 start"
    echo "  $0 enter php"
    echo "  $0 backup"
}

# 主函数
main() {
    print_header
    
    # 检查Docker
    check_docker
    
    # 创建目录
    create_directories
    
    case "${1:-start}" in
        start)
            start_services
            ;;
        stop)
            stop_services
            ;;
        restart)
            restart_services
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        enter)
            enter_container "$2"
            ;;
        backup)
            backup_database
            ;;
        clean)
            clean_data
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@" 