<?php
/**
 * gRPC 测试页面
 * 检查 gRPC 和 Composer 功能
 */

// 检查扩展状态
$grpc_installed = extension_loaded('grpc');
$protobuf_installed = extension_loaded('protobuf');
$composer_available = file_exists(__DIR__ . '/vendor/autoload.php');

// 获取版本信息
$grpc_version = $grpc_installed ? phpversion('grpc') : '未安装';
$protobuf_version = $protobuf_installed ? phpversion('protobuf') : '未安装';
?>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>gRPC & Composer 测试</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        .status { padding: 10px; margin: 10px 0; border-radius: 4px; }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        .warning { background: #fff3cd; color: #856404; }
        .code { background: #f8f9fa; padding: 10px; border-radius: 4px; font-family: monospace; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 gRPC & Composer 测试</h1>
        
        <h2>📡 gRPC 扩展状态</h2>
        <div class="status <?php echo $grpc_installed ? 'success' : 'error'; ?>">
            gRPC 扩展: <?php echo $grpc_installed ? '已安装' : '未安装'; ?> (<?php echo $grpc_version; ?>)
        </div>
        <div class="status <?php echo $protobuf_installed ? 'success' : 'error'; ?>">
            Protobuf 扩展: <?php echo $protobuf_installed ? '已安装' : '未安装'; ?> (<?php echo $protobuf_version; ?>)
        </div>
        
        <h2>📦 Composer 状态</h2>
        <div class="status <?php echo $composer_available ? 'success' : 'warning'; ?>">
            Composer autoload: <?php echo $composer_available ? '可用' : '不可用'; ?>
        </div>
        
        <h2>💡 使用示例</h2>
        <div class="code">
# 启动 gRPC 服务器
php www/grpc/server.php

# 运行 gRPC 客户端
php www/grpc/client.php

# Composer 命令
composer install
composer require grpc/grpc
        </div>
        
        <h2>🔗 文件链接</h2>
        <ul>
            <li><a href="grpc/hello.proto">Protobuf 定义文件</a></li>
            <li><a href="grpc/server.php">gRPC 服务器</a></li>
            <li><a href="grpc/client.php">gRPC 客户端</a></li>
            <li><a href="grpc/composer.json">Composer 配置</a></li>
        </ul>
    </div>
</body>
</html> 