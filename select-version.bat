@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: LNMP 版本选择脚本 (Windows版本)
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
echo %BLUE%    LNMP 版本选择工具    %NC%
echo %BLUE%================================%NC%
goto :eof

:: 显示PHP版本选择菜单
:select_php_version
echo.
echo 请选择 PHP 版本:
echo 1) PHP 7.4 (已停止支持)
echo 2) PHP 8.0 (安全支持到 2024-11-26)
echo 3) PHP 8.1 (安全支持到 2025-11-25)
echo 4) PHP 8.2 (安全支持到 2026-12-08) [推荐]
echo 5) PHP 8.3 (安全支持到 2027-11-27)
echo.
set /p "php_choice=请输入选择 (1-5, 默认4): "

if "%php_choice%"=="1" set "PHP_VERSION=7.4-fpm-alpine"
if "%php_choice%"=="2" set "PHP_VERSION=8.0-fpm-alpine"
if "%php_choice%"=="3" set "PHP_VERSION=8.1-fpm-alpine"
if "%php_choice%"=="4" set "PHP_VERSION=8.2-fpm-alpine"
if "%php_choice%"=="" set "PHP_VERSION=8.2-fpm-alpine"
if "%php_choice%"=="5" set "PHP_VERSION=8.3-fpm-alpine"

if not defined PHP_VERSION (
    call :print_error "无效选择，使用默认版本 PHP 8.2"
    set "PHP_VERSION=8.2-fpm-alpine"
)

call :print_message "已选择 PHP 版本: %PHP_VERSION%"
goto :eof

:: 显示MySQL版本选择菜单
:select_mysql_version
echo.
echo 请选择 MySQL 版本:
echo 1) MySQL 5.7 (已停止支持)
echo 2) MySQL 8.0 (安全支持到 2026-04-30) [推荐]
echo 3) MySQL 8.1 (安全支持到 2027-10-21)
echo.
set /p "mysql_choice=请输入选择 (1-3, 默认2): "

if "%mysql_choice%"=="1" set "MYSQL_VERSION=5.7"
if "%mysql_choice%"=="2" set "MYSQL_VERSION=8.0"
if "%mysql_choice%"=="" set "MYSQL_VERSION=8.0"
if "%mysql_choice%"=="3" set "MYSQL_VERSION=8.1"

if not defined MYSQL_VERSION (
    call :print_error "无效选择，使用默认版本 MySQL 8.0"
    set "MYSQL_VERSION=8.0"
)

call :print_message "已选择 MySQL 版本: %MYSQL_VERSION%"
goto :eof

:: 配置端口
:configure_ports
echo.
echo 端口配置 (按回车使用默认值):
set /p "nginx_port=Nginx 后端端口 (默认8888): "
if "%nginx_port%"=="" set "NGINX_PORT=8888" else set "NGINX_PORT=%nginx_port%"

set /p "nginx_lb_port=Nginx 负载均衡器端口 (默认8889): "
if "%nginx_lb_port%"=="" set "NGINX_LB_PORT=8889" else set "NGINX_LB_PORT=%nginx_lb_port%"

set /p "mysql_master_port=MySQL Master 端口 (默认33306): "
if "%mysql_master_port%"=="" set "MYSQL_MASTER_PORT=33306" else set "MYSQL_MASTER_PORT=%mysql_master_port%"
set /p "mysql_slave_port=MySQL Slave 端口 (默认33307): "
if "%mysql_slave_port%"=="" set "MYSQL_SLAVE_PORT=33307" else set "MYSQL_SLAVE_PORT=%mysql_slave_port%"

set /p "pma_port=phpMyAdmin 端口 (默认8080): "
if "%pma_port%"=="" set "PMA_PORT=8080" else set "PMA_PORT=%pma_port%"

call :print_message "端口配置完成"
goto :eof

:: 配置数据库
:configure_database
echo.
echo 数据库配置 (按回车使用默认值):
set /p "root_password=MySQL Root 密码 (默认root123456): "
if "%root_password%"=="" set "MYSQL_ROOT_PASSWORD=root123456" else set "MYSQL_ROOT_PASSWORD=%root_password%"

set /p "db_name=数据库名称 (默认lnmp_db): "
if "%db_name%"=="" set "MYSQL_DATABASE=lnmp_db" else set "MYSQL_DATABASE=%db_name%"

set /p "db_user=数据库用户 (默认lnmp_user): "
if "%db_user%"=="" set "MYSQL_USER=lnmp_user" else set "MYSQL_USER=%db_user%"

set /p "db_password=数据库密码 (默认lnmp123456): "
if "%db_password%"=="" set "MYSQL_PASSWORD=lnmp123456" else set "MYSQL_PASSWORD=%db_password%"

call :print_message "数据库配置完成"
goto :eof

:: 配置Redis
:configure_redis
echo.
echo Redis配置 (按回车使用默认值):
set /p "redis_password=Redis密码 (默认redis123456): "
if "%redis_password%"=="" set "REDIS_PASSWORD=redis123456" else set "REDIS_PASSWORD=%redis_password%"

set /p "redis_port=Redis端口 (默认6379): "
if "%redis_port%"=="" set "REDIS_PORT=6379" else set "REDIS_PORT=%redis_port%"

call :print_message "Redis配置完成"
goto :eof

:: 配置MongoDB
:configure_mongodb
echo.
echo MongoDB配置 (按回车使用默认值):
set /p "mongo_user=MongoDB Root用户 (默认admin): "
if "%mongo_user%"=="" set "MONGO_ROOT_USER=admin" else set "MONGO_ROOT_USER=%mongo_user%"

set /p "mongo_password=MongoDB Root密码 (默认mongodb123456): "
if "%mongo_password%"=="" set "MONGO_ROOT_PASSWORD=mongodb123456" else set "MONGO_ROOT_PASSWORD=%mongo_password%"

set /p "mongo_db=MongoDB数据库 (默认lnmp_mongo): "
if "%mongo_db%"=="" set "MONGO_DATABASE=lnmp_mongo" else set "MONGO_DATABASE=%mongo_db%"

set /p "mongo_port=MongoDB端口 (默认27017): "
if "%mongo_port%"=="" set "MONGO_PORT=27017" else set "MONGO_PORT=%mongo_port%"

call :print_message "MongoDB配置完成"
goto :eof

:: 配置RabbitMQ
:configure_rabbitmq
echo.
echo RabbitMQ配置 (按回车使用默认值):
set /p "rabbitmq_user=RabbitMQ用户 (默认admin): "
if "%rabbitmq_user%"=="" set "RABBITMQ_USER=admin" else set "RABBITMQ_USER=%rabbitmq_user%"

set /p "rabbitmq_password=RabbitMQ密码 (默认rabbitmq123456): "
if "%rabbitmq_password%"=="" set "RABBITMQ_PASSWORD=rabbitmq123456" else set "RABBITMQ_PASSWORD=%rabbitmq_password%"

set /p "rabbitmq_port=RabbitMQ端口 (默认5672): "
if "%rabbitmq_port%"=="" set "RABBITMQ_PORT=5672" else set "RABBITMQ_PORT=%rabbitmq_port%"

set /p "rabbitmq_management_port=RabbitMQ管理端口 (默认15672): "
if "%rabbitmq_management_port%"=="" set "RABBITMQ_MANAGEMENT_PORT=15672" else set "RABBITMQ_MANAGEMENT_PORT=%rabbitmq_management_port%"

call :print_message "RabbitMQ配置完成"
goto :eof

:: 生成.env文件
:generate_env_file
echo # LNMP Docker 环境配置文件 > .env
echo # 生成时间: %date% %time% >> .env
echo. >> .env
echo # PHP 版本选择 >> .env
echo PHP_VERSION=%PHP_VERSION% >> .env
echo. >> .env
echo # MySQL 版本选择 >> .env
echo MYSQL_VERSION=%MYSQL_VERSION% >> .env
echo. >> .env
echo # 端口配置 >> .env
echo NGINX_PORT=%NGINX_PORT% >> .env
echo NGINX_SSL_PORT=443 >> .env
echo NGINX_LB_PORT=%NGINX_LB_PORT% >> .env
echo NGINX_LB_SSL_PORT=444 >> .env
echo MYSQL_MASTER_PORT=%MYSQL_MASTER_PORT% >> .env
echo MYSQL_SLAVE_PORT=%MYSQL_SLAVE_PORT% >> .env
echo PMA_PORT=%PMA_PORT% >> .env
echo. >> .env
echo # 数据库配置 >> .env
echo MYSQL_ROOT_PASSWORD=%MYSQL_ROOT_PASSWORD% >> .env
echo MYSQL_DATABASE=%MYSQL_DATABASE% >> .env
echo MYSQL_USER=%MYSQL_USER% >> .env
echo MYSQL_PASSWORD=%MYSQL_PASSWORD% >> .env
echo. >> .env
echo # Redis配置 >> .env
echo REDIS_VERSION=7-alpine >> .env
echo REDIS_PASSWORD=%REDIS_PASSWORD% >> .env
echo REDIS_PORT=%REDIS_PORT% >> .env
echo REDIS_COMMANDER_USER=admin >> .env
echo REDIS_COMMANDER_PASSWORD=%REDIS_PASSWORD% >> .env
echo REDIS_COMMANDER_PORT=8081 >> .env
echo. >> .env
echo # MongoDB配置 >> .env
echo MONGODB_VERSION=7 >> .env
echo MONGO_ROOT_USER=%MONGO_ROOT_USER% >> .env
echo MONGO_ROOT_PASSWORD=%MONGO_ROOT_PASSWORD% >> .env
echo MONGO_DATABASE=%MONGO_DATABASE% >> .env
echo MONGO_PORT=%MONGO_PORT% >> .env
echo. >> .env
echo # Kafka配置 >> .env
echo KAFKA_VERSION=7.4.0 >> .env
echo KAFKA_PORT=9092 >> .env
echo ZOOKEEPER_PORT=2181 >> .env
echo. >> .env
echo # RabbitMQ配置 >> .env
echo RABBITMQ_VERSION=3-management-alpine >> .env
echo RABBITMQ_USER=%RABBITMQ_USER% >> .env
echo RABBITMQ_PASSWORD=%RABBITMQ_PASSWORD% >> .env
echo RABBITMQ_VHOST=/ >> .env
echo RABBITMQ_PORT=%RABBITMQ_PORT% >> .env
echo RABBITMQ_MANAGEMENT_PORT=%RABBITMQ_MANAGEMENT_PORT% >> .env

call :print_message ".env 文件已生成"
goto :eof

:: 显示配置摘要
:show_summary
echo.
echo %BLUE%配置摘要:%NC%
echo ==================
echo PHP 版本: %PHP_VERSION%
echo MySQL 版本: %MYSQL_VERSION%
echo Nginx 后端端口: %NGINX_PORT%
echo Nginx 负载均衡器端口: %NGINX_LB_PORT%
echo MySQL Master 端口: %MYSQL_MASTER_PORT%
echo MySQL Slave 端口: %MYSQL_SLAVE_PORT%
echo phpMyAdmin 端口: %PMA_PORT%
echo 数据库名称: %MYSQL_DATABASE%
echo 数据库用户: %MYSQL_USER%
echo Redis 端口: %REDIS_PORT%
echo MongoDB 端口: %MONGO_PORT%
echo Kafka 端口: 9092
echo RabbitMQ 端口: %RABBITMQ_PORT%
echo RabbitMQ 管理端口: %RABBITMQ_MANAGEMENT_PORT%
echo ==================
echo.
goto :eof

:: 主函数
:main
call :print_header

:: 检查是否已存在.env文件
if exist ".env" (
    call :print_warning "检测到已存在的 .env 文件"
    set /p "overwrite=是否要覆盖现有配置？(y/N): "
    if /i not "!overwrite!"=="y" (
        call :print_message "操作已取消"
        goto :end
    )
)

:: 选择版本
call :select_php_version
call :select_mysql_version

:: 配置端口
call :configure_ports

:: 配置数据库
call :configure_database

:: 配置Redis
call :configure_redis

:: 配置MongoDB
call :configure_mongodb

:: 配置RabbitMQ
call :configure_rabbitmq

:: 显示摘要
call :show_summary

:: 确认生成
set /p "confirm=确认生成配置文件？(Y/n): "
if /i "!confirm!"=="n" (
    call :print_message "操作已取消"
    goto :end
)

:: 生成.env文件
call :generate_env_file

call :print_message "配置完成！现在可以运行 start.bat 启动服务"

:end
pause 