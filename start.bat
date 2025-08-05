@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: LNMP Docker 环境启动脚本 (Windows版本)
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
echo %BLUE%    LNMP Docker 环境管理脚本    %NC%
echo %BLUE%================================%NC%
goto :eof

:: 检查Docker是否安装
:check_docker
docker --version >nul 2>&1
if errorlevel 1 (
    call :print_error "Docker 未安装，请先安装 Docker"
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    call :print_error "Docker Compose 未安装，请先安装 Docker Compose"
    exit /b 1
)
goto :eof

:: 创建必要的目录
:create_directories
call :print_message "创建必要的目录..."

if not exist "nginx\conf.d" mkdir "nginx\conf.d"
if not exist "nginx\ssl" mkdir "nginx\ssl"
if not exist "nginx\logs" mkdir "nginx\logs"
if not exist "php" mkdir "php"
if not exist "mysql\master-data" mkdir "mysql\master-data"
if not exist "mysql\slave-data" mkdir "mysql\slave-data"
if not exist "mysql\conf" mkdir "mysql\conf"
if not exist "mysql\logs" mkdir "mysql\logs"
if not exist "www" mkdir "www"
if not exist "redis\data" mkdir "redis\data"
if not exist "redis\conf" mkdir "redis\conf"
if not exist "mongodb\data" mkdir "mongodb\data"
if not exist "mongodb\logs" mkdir "mongodb\logs"
if not exist "kafka\zookeeper\data" mkdir "kafka\zookeeper\data"
if not exist "kafka\zookeeper\logs" mkdir "kafka\zookeeper\logs"
if not exist "kafka\kafka\data" mkdir "kafka\kafka\data"
if not exist "kafka\kafka\logs" mkdir "kafka\kafka\logs"
if not exist "rabbitmq\data" mkdir "rabbitmq\data"
if not exist "rabbitmq\logs" mkdir "rabbitmq\logs"

call :print_message "目录创建完成"
goto :eof

:: 启动服务
:start_services
call :print_message "启动 LNMP 服务..."

:: 检查是否存在.env文件
if not exist ".env" (
    call :print_warning "未找到 .env 文件，将使用默认配置"
    call :print_message "建议运行 select-version.bat 进行配置"
)

docker-compose up -d --build

if errorlevel 1 (
    call :print_error "服务启动失败"
    exit /b 1
) else (
    call :print_message "服务启动成功！"
    call :print_message "访问地址:"
    
    :: 从.env文件读取端口配置
    if exist ".env" (
        for /f "tokens=2 delims==" %%a in ('findstr "NGINX_PORT" .env') do set "NGINX_PORT=%%a"
        for /f "tokens=2 delims==" %%a in ('findstr "PMA_PORT" .env') do set "PMA_PORT=%%a"
        for /f "tokens=2 delims==" %%a in ('findstr "REDIS_COMMANDER_PORT" .env') do set "REDIS_COMMANDER_PORT=%%a"
        for /f "tokens=2 delims==" %%a in ('findstr "RABBITMQ_MANAGEMENT_PORT" .env') do set "RABBITMQ_MANAGEMENT_PORT=%%a"
        if "!NGINX_PORT!"=="" set "NGINX_PORT=80"
        if "!PMA_PORT!"=="" set "PMA_PORT=8080"
        if "!REDIS_COMMANDER_PORT!"=="" set "REDIS_COMMANDER_PORT=8081"
        if "!RABBITMQ_MANAGEMENT_PORT!"=="" set "RABBITMQ_MANAGEMENT_PORT=15672"
        echo   - 网站: http://localhost:!NGINX_PORT!
        echo   - phpMyAdmin: http://localhost:!PMA_PORT!
        echo   - PHP信息: http://localhost:!NGINX_PORT!/phpinfo.php
        echo   - Redis管理: http://localhost:!REDIS_COMMANDER_PORT!
        echo   - RabbitMQ管理: http://localhost:!RABBITMQ_MANAGEMENT_PORT!
    ) else (
        echo   - 网站: http://localhost
        echo   - phpMyAdmin: http://localhost:8080
        echo   - PHP信息: http://localhost/phpinfo.php
        echo   - Redis管理: http://localhost:8081
        echo   - RabbitMQ管理: http://localhost:15672
    )
)
goto :eof

:: 停止服务
:stop_services
call :print_message "停止 LNMP 服务..."
docker-compose down
call :print_message "服务已停止"
goto :eof

:: 重启服务
:restart_services
call :print_message "重启 LNMP 服务..."
docker-compose down
docker-compose up -d --build
call :print_message "服务重启完成"
goto :eof

:: 查看日志
:show_logs
call :print_message "显示服务日志..."
docker-compose logs -f
goto :eof

:: 查看服务状态
:show_status
call :print_message "服务状态:"
docker-compose ps
goto :eof

:: 进入容器
:enter_container
if "%~1"=="" (
    call :print_error "请指定服务名称 (nginx^|php^|mysql^|phpmyadmin)"
    exit /b 1
)

call :print_message "进入 %~1 容器..."
docker-compose exec %~1 sh
goto :eof

:: 备份数据库
:backup_database
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "backup_file=mysql_backup_%dt:~0,8%_%dt:~8,6%.sql"
call :print_message "备份数据库到 %backup_file%..."
docker-compose exec mysql mysqldump -u root -proot123456 lnmp_db > "%backup_file%"
call :print_message "数据库备份完成: %backup_file%"
goto :eof

:: 清理数据
:clean_data
call :print_warning "这将删除所有数据，包括数据库！"
set /p "confirm=确定要继续吗？(y/N): "
if /i "!confirm!"=="y" (
    call :print_message "清理数据..."
    docker-compose down -v
    if exist "mysql\data" rmdir /s /q "mysql\data"
    if exist "nginx\logs" rmdir /s /q "nginx\logs"
    call :print_message "数据清理完成"
) else (
    call :print_message "操作已取消"
)
goto :eof

:: 显示帮助信息
:show_help
echo 用法: %~nx0 [命令]
echo.
echo 命令:
echo   start     启动所有服务
echo   stop      停止所有服务
echo   restart   重启所有服务
echo   status    查看服务状态
echo   logs      查看服务日志
echo   enter     进入指定容器 (用法: %~nx0 enter [service])
echo   backup    备份数据库
echo   clean     清理所有数据
echo   help      显示此帮助信息
echo.
echo 示例:
echo   %~nx0 start
echo   %~nx0 enter php
echo   %~nx0 backup
goto :eof

:: 主函数
:main
call :print_header

:: 检查Docker
call :check_docker
if errorlevel 1 exit /b 1

:: 创建目录
call :create_directories

:: 处理命令行参数
if "%~1"=="" goto :start
if "%~1"=="start" goto :start
if "%~1"=="stop" goto :stop
if "%~1"=="restart" goto :restart
if "%~1"=="status" goto :status
if "%~1"=="logs" goto :logs
if "%~1"=="enter" goto :enter
if "%~1"=="backup" goto :backup
if "%~1"=="clean" goto :clean
if "%~1"=="help" goto :help
if "%~1"=="--help" goto :help
if "%~1"=="-h" goto :help

call :print_error "未知命令: %~1"
call :show_help
exit /b 1

:start
call :start_services
goto :end

:stop
call :stop_services
goto :end

:restart
call :restart_services
goto :end

:status
call :show_status
goto :end

:logs
call :show_logs
goto :end

:enter
call :enter_container "%~2"
goto :end

:backup
call :backup_database
goto :end

:clean
call :clean_data
goto :end

:help
call :show_help
goto :end

:end
pause 