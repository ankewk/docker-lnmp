@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: gRPC 测试脚本 (Windows版本)
:: 用于验证 gRPC 和 Composer 功能

echo === gRPC 和 Composer 测试 ===
echo.

:: 检查 Docker 容器状态
echo 1. 检查 PHP 容器状态...
docker-compose ps php | findstr "Up" >nul
if errorlevel 1 (
    echo ✗ PHP 容器未运行
    echo 请先启动服务: docker-compose up -d
    pause
    exit /b 1
) else (
    echo ✓ PHP 容器运行正常
)

echo.
echo 2. 检查 gRPC 扩展...
docker-compose exec php php -m | findstr /i "grpc protobuf" || echo gRPC 扩展未安装

echo.
echo 3. 检查 Composer...
docker-compose exec php composer --version || echo Composer 未安装

echo.
echo 4. 测试 gRPC 项目...
if exist "www\grpc" (
    echo ✓ gRPC 项目目录存在
    if exist "www\grpc\hello.proto" (echo    - hello.proto: 存在) else (echo    - hello.proto: 不存在)
    if exist "www\grpc\server.php" (echo    - server.php: 存在) else (echo    - server.php: 不存在)
    if exist "www\grpc\client.php" (echo    - client.php: 存在) else (echo    - client.php: 不存在)
    if exist "www\grpc\composer.json" (echo    - composer.json: 存在) else (echo    - composer.json: 不存在)
) else (
    echo ✗ gRPC 项目目录不存在
)

echo.
echo 5. 检查 Web 测试页面...
if exist "www\grpc-test.php" (
    echo ✓ gRPC 测试页面存在
    echo    访问地址: http://localhost:8888/grpc-test.php
) else (
    echo ✗ gRPC 测试页面不存在
)

echo.
echo 6. 测试 Composer 安装...
docker-compose exec php sh -c "cd /var/www/html/grpc && composer install --no-interaction" >nul 2>&1
if errorlevel 1 (
    echo ⚠ Composer 依赖安装失败或未配置
) else (
    echo ✓ Composer 依赖安装成功
)

echo.
echo === 测试完成 ===
echo.
echo 下一步操作:
echo 1. 访问 http://localhost:8888/grpc-test.php 查看详细状态
echo 2. 进入容器测试 gRPC: docker-compose exec php sh
echo 3. 启动 gRPC 服务器: php www/grpc/server.php
echo 4. 运行 gRPC 客户端: php www/grpc/client.php
pause 