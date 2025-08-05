#!/bin/bash

# LNMP 负载均衡器管理脚本
# 作者: Docker LNMP
# 版本: 1.0

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
    echo -e "${BLUE}    LNMP 负载均衡器管理工具    ${NC}"
    echo -e "${BLUE}================================${NC}"
}

# 检查Docker是否运行
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker 未运行，请先启动 Docker"
        exit 1
    fi
}

# 检查Docker Compose是否可用
check_compose() {
    if ! docker-compose version > /dev/null 2>&1; then
        print_error "Docker Compose 未安装或不可用"
        exit 1
    fi
}

# 启动负载均衡器
start_lb() {
    print_message "启动负载均衡器..."
    docker-compose up -d nginx-loadbalancer nginx-backend
    print_message "负载均衡器已启动"
    print_message "访问地址: http://localhost:8889"
    print_message "健康检查: http://localhost:8889/health"
}

# 停止负载均衡器
stop_lb() {
    print_message "停止负载均衡器..."
    docker-compose stop nginx-loadbalancer nginx-backend
    print_message "负载均衡器已停止"
}

# 重启负载均衡器
restart_lb() {
    print_message "重启负载均衡器..."
    docker-compose restart nginx-loadbalancer nginx-backend
    print_message "负载均衡器已重启"
}

# 查看负载均衡器状态
status_lb() {
    print_message "负载均衡器状态:"
    echo ""
    
    # 检查容器状态
    echo "容器状态:"
    docker-compose ps nginx-loadbalancer nginx-backend
    
    echo ""
    echo "负载均衡器日志 (最近10行):"
    docker-compose logs --tail=10 nginx-loadbalancer
    
    echo ""
    echo "后端服务器日志 (最近10行):"
    docker-compose logs --tail=10 nginx-backend
}

# 测试负载均衡
test_lb() {
    print_message "测试负载均衡功能..."
    
    # 测试健康检查
    echo "1. 测试健康检查:"
    curl -s http://localhost:8889/health | jq . 2>/dev/null || curl -s http://localhost:8889/health
    
    echo ""
    echo "2. 测试负载均衡 (连续5次请求):"
    for i in {1..5}; do
        echo "请求 $i:"
        curl -s http://localhost:8889/lb-test.php | jq . 2>/dev/null || curl -s http://localhost:8889/lb-test.php
        echo ""
        sleep 1
    done
}

# 查看负载均衡器配置
config_lb() {
    print_message "负载均衡器配置:"
    echo ""
    echo "配置文件: nginx/loadbalancer.conf"
    echo ""
    cat nginx/loadbalancer.conf
}

# 查看负载均衡器统计
stats_lb() {
    print_message "负载均衡器统计信息:"
    echo ""
    
    # 获取容器统计信息
    echo "容器资源使用情况:"
    docker stats --no-stream nginx-loadbalancer nginx-backend
    
    echo ""
    echo "网络连接数:"
    docker exec nginx-loadbalancer nginx -T 2>/dev/null | grep -E "(active connections|server accepts handled requests)" || echo "无法获取连接统计"
}

# 进入负载均衡器容器
enter_lb() {
    print_message "进入负载均衡器容器..."
    docker-compose exec nginx-loadbalancer sh
}

# 进入后端服务器容器
enter_backend() {
    print_message "进入后端服务器容器..."
    docker-compose exec nginx-backend sh
}

# 查看负载均衡器日志
logs_lb() {
    local service=${1:-nginx-loadbalancer}
    print_message "查看 $service 日志..."
    docker-compose logs -f $service
}

# 重新加载负载均衡器配置
reload_lb() {
    print_message "重新加载负载均衡器配置..."
    docker-compose exec nginx-loadbalancer nginx -s reload
    print_message "配置已重新加载"
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [命令]"
    echo ""
    echo "可用命令:"
    echo "  start     启动负载均衡器"
    echo "  stop      停止负载均衡器"
    echo "  restart   重启负载均衡器"
    echo "  status    查看负载均衡器状态"
    echo "  test      测试负载均衡功能"
    echo "  config    查看负载均衡器配置"
    echo "  stats     查看负载均衡器统计"
    echo "  enter     进入负载均衡器容器"
    echo "  backend   进入后端服务器容器"
    echo "  logs      查看负载均衡器日志"
    echo "  reload    重新加载配置"
    echo "  help      显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 start"
    echo "  $0 status"
    echo "  $0 test"
}

# 主函数
main() {
    check_docker
    check_compose
    
    case "${1:-help}" in
        start)
            start_lb
            ;;
        stop)
            stop_lb
            ;;
        restart)
            restart_lb
            ;;
        status)
            status_lb
            ;;
        test)
            test_lb
            ;;
        config)
            config_lb
            ;;
        stats)
            stats_lb
            ;;
        enter)
            enter_lb
            ;;
        backend)
            enter_backend
            ;;
        logs)
            logs_lb $2
            ;;
        reload)
            reload_lb
            ;;
        help|*)
            print_header
            show_help
            ;;
    esac
}

# 执行主函数
main "$@" 