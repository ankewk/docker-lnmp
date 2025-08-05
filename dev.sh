#!/bin/bash

# 开发模式管理脚本
# 支持代码热加载和开发环境优化

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印函数
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
    echo -e "${BLUE}=== $1 ===${NC}"
}

# 检查Docker是否运行
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker未运行，请先启动Docker"
        exit 1
    fi
}

# 启动开发环境
start_dev() {
    print_header "启动开发环境"
    check_docker
    
    # 创建必要的目录
    mkdir -p logs/php logs/nginx dev-tools tmp/php
    
    # 启动开发环境
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev up -d
    
    print_message "开发环境已启动"
    print_message "访问地址: http://localhost:8888"
    print_message "负载均衡器: http://localhost:8889"
    print_message "文件监控已启用"
}

# 停止开发环境
stop_dev() {
    print_header "停止开发环境"
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml down
    print_message "开发环境已停止"
}

# 重启开发环境
restart_dev() {
    print_header "重启开发环境"
    stop_dev
    start_dev
}

# 查看开发环境状态
status_dev() {
    print_header "开发环境状态"
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml ps
    
    echo ""
    print_message "服务状态:"
    echo "  - Nginx后端: http://localhost:8888"
    echo "  - 负载均衡器: http://localhost:8889"
    echo "  - phpMyAdmin: http://localhost:8080"
    echo "  - Redis管理: http://localhost:8081"
    echo "  - RabbitMQ管理: http://localhost:15672"
}

# 查看文件变化日志
logs_dev() {
    print_header "文件变化日志"
    if [ -f "dev-tools/file-changes.log" ]; then
        tail -f dev-tools/file-changes.log
    else
        print_warning "文件变化日志不存在，请先启动开发环境"
    fi
}

# 进入PHP容器
enter_php() {
    print_message "进入PHP容器..."
    docker-compose exec php sh
}

# 进入Nginx容器
enter_nginx() {
    print_message "进入Nginx容器..."
    docker-compose exec nginx-backend sh
}

# 查看PHP错误日志
php_logs() {
    print_header "PHP错误日志"
    if [ -f "logs/php/error.log" ]; then
        tail -f logs/php/error.log
    else
        print_warning "PHP错误日志不存在"
    fi
}

# 查看Nginx访问日志
nginx_logs() {
    print_header "Nginx访问日志"
    if [ -f "logs/nginx/access.log" ]; then
        tail -f logs/nginx/access.log
    else
        print_warning "Nginx访问日志不存在"
    fi
}

# 清理开发环境
clean_dev() {
    print_header "清理开发环境"
    read -p "确定要清理所有开发数据吗？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose -f docker-compose.yml -f docker-compose.dev.yml down -v
        rm -rf logs dev-tools tmp
        print_message "开发环境已清理"
    else
        print_message "取消清理操作"
    fi
}

# 文件监控测试
test_watcher() {
    print_header "测试文件监控"
    print_message "创建测试文件..."
    echo "<?php echo 'Test file created at $(date)'; ?>" > www/test-watcher.php
    print_message "测试文件已创建: www/test-watcher.php"
    print_message "请查看 dev-tools/file-changes.log 确认文件监控是否正常工作"
}

# 健康检查
health_check() {
    print_header "健康检查"
    
    # 检查Nginx
    if curl -f http://localhost:8888 > /dev/null 2>&1; then
        print_message "✓ Nginx后端服务正常"
    else
        print_error "✗ Nginx后端服务异常"
    fi
    
    # 检查负载均衡器
    if curl -f http://localhost:8889/health > /dev/null 2>&1; then
        print_message "✓ 负载均衡器正常"
    else
        print_error "✗ 负载均衡器异常"
    fi
    
    # 检查PHP
    if curl -f http://localhost:8888/phpinfo.php > /dev/null 2>&1; then
        print_message "✓ PHP服务正常"
    else
        print_error "✗ PHP服务异常"
    fi
}

# 显示帮助信息
show_help() {
    print_header "开发环境管理脚本"
    echo "用法: $0 [命令]"
    echo ""
    echo "可用命令:"
    echo "  start     启动开发环境"
    echo "  stop      停止开发环境"
    echo "  restart   重启开发环境"
    echo "  status    查看服务状态"
    echo "  logs      查看文件变化日志"
    echo "  php-logs  查看PHP错误日志"
    echo "  nginx-logs 查看Nginx访问日志"
    echo "  enter-php 进入PHP容器"
    echo "  enter-nginx 进入Nginx容器"
    echo "  health    健康检查"
    echo "  test-watcher 测试文件监控"
    echo "  clean     清理开发环境"
    echo "  help      显示此帮助信息"
    echo ""
    echo "开发环境特性:"
    echo "  - 代码热加载（文件修改自动生效）"
    echo "  - 文件变化监控"
    echo "  - 开发模式PHP配置"
    echo "  - 详细错误日志"
    echo "  - Xdebug调试支持"
}

# 主函数
case "${1:-help}" in
    start)
        start_dev
        ;;
    stop)
        stop_dev
        ;;
    restart)
        restart_dev
        ;;
    status)
        status_dev
        ;;
    logs)
        logs_dev
        ;;
    php-logs)
        php_logs
        ;;
    nginx-logs)
        nginx_logs
        ;;
    enter-php)
        enter_php
        ;;
    enter-nginx)
        enter_nginx
        ;;
    health)
        health_check
        ;;
    test-watcher)
        test_watcher
        ;;
    clean)
        clean_dev
        ;;
    help|*)
        show_help
        ;;
esac 