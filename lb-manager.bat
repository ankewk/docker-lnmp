@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: LNMP 负载均衡器管理脚本 (Windows版本)
:: 作者: Docker LNMP
:: 版本: 1.0

:: 颜色定义
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

:: 打印带颜色的消息
:print_message
echo %GREEN%[INFO]%NC% %~1
goto :eof

:print_warning
echo %YELLOW%[WARNING]%NC% %~1
goto :eof

:print_error
echo %RED%[ERROR]%NC% %~1
goto :eof

:print_header
echo %BLUE%================================%NC%
echo %BLUE%    LNMP 负载均衡器管理工具    %NC%
echo %BLUE%================================%NC%
goto :eof

:: 检查Docker是否运行
:check_docker
docker info >nul 2>&1
if errorlevel 1 (
    call :print_error "Docker 未运行，请先启动 Docker"
    exit /b 1
)
goto :eof

:: 检查Docker Compose是否可用
:check_compose
docker-compose version >nul 2>&1
if errorlevel 1 (
    call :print_error "Docker Compose 未安装或不可用"
    exit /b 1
)
goto :eof

:: 启动负载均衡器
:start_lb
call :print_message "启动负载均衡器..."
docker-compose up -d nginx-loadbalancer nginx-backend
call :print_message "负载均衡器已启动"
call :print_message "访问地址: http://localhost:8889"
call :print_message "健康检查: http://localhost:8889/health"
goto :eof

:: 停止负载均衡器
:stop_lb
call :print_message "停止负载均衡器..."
docker-compose stop nginx-loadbalancer nginx-backend
call :print_message "负载均衡器已停止"
goto :eof

:: 重启负载均衡器
:restart_lb
call :print_message "重启负载均衡器..."
docker-compose restart nginx-loadbalancer nginx-backend
call :print_message "负载均衡器已重启"
goto :eof

:: 查看负载均衡器状态
:status_lb
call :print_message "负载均衡器状态:"
echo.
echo 容器状态:
docker-compose ps nginx-loadbalancer nginx-backend
echo.
echo 负载均衡器日志 (最近10行):
docker-compose logs --tail=10 nginx-loadbalancer
echo.
echo 后端服务器日志 (最近10行):
docker-compose logs --tail=10 nginx-backend
goto :eof

:: 测试负载均衡
:test_lb
call :print_message "测试负载均衡功能..."
echo.
echo 1. 测试健康检查:
curl -s http://localhost:8889/health
echo.
echo 2. 测试负载均衡 (连续5次请求):
for /l %%i in (1,1,5) do (
    echo 请求 %%i:
    curl -s http://localhost:8889/lb-test.php
    echo.
    timeout /t 1 /nobreak >nul
)
goto :eof

:: 查看负载均衡器配置
:config_lb
call :print_message "负载均衡器配置:"
echo.
echo 配置文件: nginx/loadbalancer.conf
echo.
type nginx\loadbalancer.conf
goto :eof

:: 查看负载均衡器统计
:stats_lb
call :print_message "负载均衡器统计信息:"
echo.
echo 容器资源使用情况:
docker stats --no-stream nginx-loadbalancer nginx-backend
goto :eof

:: 进入负载均衡器容器
:enter_lb
call :print_message "进入负载均衡器容器..."
docker-compose exec nginx-loadbalancer sh
goto :eof

:: 进入后端服务器容器
:enter_backend
call :print_message "进入后端服务器容器..."
docker-compose exec nginx-backend sh
goto :eof

:: 查看负载均衡器日志
:logs_lb
set "service=%~1"
if "%service%"=="" set "service=nginx-loadbalancer"
call :print_message "查看 %service% 日志..."
docker-compose logs -f %service%
goto :eof

:: 重新加载负载均衡器配置
:reload_lb
call :print_message "重新加载负载均衡器配置..."
docker-compose exec nginx-loadbalancer nginx -s reload
call :print_message "配置已重新加载"
goto :eof

:: 显示帮助信息
:show_help
echo 用法: %0 [命令]
echo.
echo 可用命令:
echo   start     启动负载均衡器
echo   stop      停止负载均衡器
echo   restart   重启负载均衡器
echo   status    查看负载均衡器状态
echo   test      测试负载均衡功能
echo   config    查看负载均衡器配置
echo   stats     查看负载均衡器统计
echo   enter     进入负载均衡器容器
echo   backend   进入后端服务器容器
echo   logs      查看负载均衡器日志
echo   reload    重新加载配置
echo   help      显示此帮助信息
echo.
echo 示例:
echo   %0 start
echo   %0 status
echo   %0 test
goto :eof

:: 主函数
:main
call :check_docker
if errorlevel 1 exit /b 1
call :check_compose
if errorlevel 1 exit /b 1

set "command=%~1"
if "%command%"=="" set "command=help"

if "%command%"=="start" call :start_lb
if "%command%"=="stop" call :stop_lb
if "%command%"=="restart" call :restart_lb
if "%command%"=="status" call :status_lb
if "%command%"=="test" call :test_lb
if "%command%"=="config" call :config_lb
if "%command%"=="stats" call :stats_lb
if "%command%"=="enter" call :enter_lb
if "%command%"=="backend" call :enter_backend
if "%command%"=="logs" call :logs_lb %2
if "%command%"=="reload" call :reload_lb
if "%command%"=="help" (
    call :print_header
    call :show_help
)
goto :eof

:: 执行主函数
call :main %* 