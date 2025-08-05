@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 开发模式管理脚本 (Windows版本)
:: 支持代码热加载和开发环境优化

:: 颜色定义
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

:: 打印函数
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
echo %BLUE%=== %~1 ===%NC%
goto :eof

:: 检查Docker是否运行
:check_docker
docker info >nul 2>&1
if errorlevel 1 (
    call :print_error "Docker未运行，请先启动Docker"
    exit /b 1
)
goto :eof

:: 启动开发环境
:start_dev
call :print_header "启动开发环境"
call :check_docker

:: 创建必要的目录
if not exist "logs\php" mkdir logs\php
if not exist "logs\nginx" mkdir logs\nginx
if not exist "dev-tools" mkdir dev-tools
if not exist "tmp\php" mkdir tmp\php

:: 启动开发环境
docker-compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev up -d

call :print_message "开发环境已启动"
call :print_message "访问地址: http://localhost:8888"
call :print_message "负载均衡器: http://localhost:8889"
call :print_message "文件监控已启用"
goto :eof

:: 停止开发环境
:stop_dev
call :print_header "停止开发环境"
docker-compose -f docker-compose.yml -f docker-compose.dev.yml down
call :print_message "开发环境已停止"
goto :eof

:: 重启开发环境
:restart_dev
call :print_header "重启开发环境"
call :stop_dev
call :start_dev
goto :eof

:: 查看开发环境状态
:status_dev
call :print_header "开发环境状态"
docker-compose -f docker-compose.yml -f docker-compose.dev.yml ps

echo.
call :print_message "服务状态:"
echo   - Nginx后端: http://localhost:8888
echo   - 负载均衡器: http://localhost:8889
echo   - phpMyAdmin: http://localhost:8080
echo   - Redis管理: http://localhost:8081
echo   - RabbitMQ管理: http://localhost:15672
goto :eof

:: 查看文件变化日志
:logs_dev
call :print_header "文件变化日志"
if exist "dev-tools\file-changes.log" (
    type dev-tools\file-changes.log
) else (
    call :print_warning "文件变化日志不存在，请先启动开发环境"
)
goto :eof

:: 进入PHP容器
:enter_php
call :print_message "进入PHP容器..."
docker-compose exec php sh
goto :eof

:: 进入Nginx容器
:enter_nginx
call :print_message "进入Nginx容器..."
docker-compose exec nginx-backend sh
goto :eof

:: 查看PHP错误日志
:php_logs
call :print_header "PHP错误日志"
if exist "logs\php\error.log" (
    type logs\php\error.log
) else (
    call :print_warning "PHP错误日志不存在"
)
goto :eof

:: 查看Nginx访问日志
:nginx_logs
call :print_header "Nginx访问日志"
if exist "logs\nginx\access.log" (
    type logs\nginx\access.log
) else (
    call :print_warning "Nginx访问日志不存在"
)
goto :eof

:: 清理开发环境
:clean_dev
call :print_header "清理开发环境"
set /p confirm="确定要清理所有开发数据吗？(y/N): "
if /i "!confirm!"=="y" (
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml down -v
    if exist "logs" rmdir /s /q logs
    if exist "dev-tools" rmdir /s /q dev-tools
    if exist "tmp" rmdir /s /q tmp
    call :print_message "开发环境已清理"
) else (
    call :print_message "取消清理操作"
)
goto :eof

:: 文件监控测试
:test_watcher
call :print_header "测试文件监控"
call :print_message "创建测试文件..."
echo ^<?php echo 'Test file created at %date% %time%'; ?^> > www\test-watcher.php
call :print_message "测试文件已创建: www\test-watcher.php"
call :print_message "请查看 dev-tools\file-changes.log 确认文件监控是否正常工作"
goto :eof

:: 健康检查
:health_check
call :print_header "健康检查"

:: 检查Nginx
curl -f http://localhost:8888 >nul 2>&1
if errorlevel 1 (
    call :print_error "✗ Nginx后端服务异常"
) else (
    call :print_message "✓ Nginx后端服务正常"
)

:: 检查负载均衡器
curl -f http://localhost:8889/health >nul 2>&1
if errorlevel 1 (
    call :print_error "✗ 负载均衡器异常"
) else (
    call :print_message "✓ 负载均衡器正常"
)

:: 检查PHP
curl -f http://localhost:8888/phpinfo.php >nul 2>&1
if errorlevel 1 (
    call :print_error "✗ PHP服务异常"
) else (
    call :print_message "✓ PHP服务正常"
)
goto :eof

:: 显示帮助信息
:show_help
call :print_header "开发环境管理脚本"
echo 用法: %0 [命令]
echo.
echo 可用命令:
echo   start     启动开发环境
echo   stop      停止开发环境
echo   restart   重启开发环境
echo   status    查看服务状态
echo   logs      查看文件变化日志
echo   php-logs  查看PHP错误日志
echo   nginx-logs 查看Nginx访问日志
echo   enter-php 进入PHP容器
echo   enter-nginx 进入Nginx容器
echo   health    健康检查
echo   test-watcher 测试文件监控
echo   clean     清理开发环境
echo   help      显示此帮助信息
echo.
echo 开发环境特性:
echo   - 代码热加载（文件修改自动生效）
echo   - 文件变化监控
echo   - 开发模式PHP配置
echo   - 详细错误日志
echo   - Xdebug调试支持
goto :eof

:: 主函数
if "%1"=="" goto show_help
if "%1"=="start" goto start_dev
if "%1"=="stop" goto stop_dev
if "%1"=="restart" goto restart_dev
if "%1"=="status" goto status_dev
if "%1"=="logs" goto logs_dev
if "%1"=="php-logs" goto php_logs
if "%1"=="nginx-logs" goto nginx_logs
if "%1"=="enter-php" goto enter_php
if "%1"=="enter-nginx" goto enter_nginx
if "%1"=="health" goto health_check
if "%1"=="test-watcher" goto test_watcher
if "%1"=="clean" goto clean_dev
if "%1"=="help" goto show_help
goto show_help 