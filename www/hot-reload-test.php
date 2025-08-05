<?php
/**
 * 热加载测试页面
 * 用于验证代码文件热加载功能
 */

$current_time = date('Y-m-d H:i:s');
$timestamp = time();
$random_color = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7', '#DDA0DD'][array_rand([0,1,2,3,4,5])];

// 检查开发环境配置
$opcache_enabled = ini_get('opcache.enable');
$display_errors = ini_get('display_errors');
?>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🔥 热加载测试页面</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        .timestamp { background: <?php echo $random_color; ?>; color: white; padding: 15px; border-radius: 5px; text-align: center; margin: 20px 0; }
        .status { padding: 5px 10px; border-radius: 15px; font-size: 0.9em; }
        .success { background: #d4edda; color: #155724; }
        .warning { background: #fff3cd; color: #856404; }
        .error { background: #f8d7da; color: #721c24; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .btn { display: inline-block; padding: 10px 15px; background: #007bff; color: white; text-decoration: none; border-radius: 3px; margin: 5px; }
    </style>
    <script>
        // 自动刷新页面（每10秒）
        setTimeout(function() { location.reload(); }, 10000);
    </script>
</head>
<body>
    <div class="container">
        <h1>🔥 热加载测试页面</h1>
        
        <div class="timestamp">
            <strong>当前时间:</strong> <?php echo $current_time; ?><br>
            <strong>Unix时间戳:</strong> <?php echo $timestamp; ?>
        </div>
        
        <div class="section">
            <h3>📊 服务器信息</h3>
            <p><strong>容器ID:</strong> <?php echo gethostname(); ?></p>
            <p><strong>PHP版本:</strong> <?php echo PHP_VERSION; ?></p>
            <p><strong>服务器软件:</strong> <?php echo $_SERVER['SERVER_SOFTWARE'] ?? 'Nginx'; ?></p>
        </div>
        
        <div class="section">
            <h3>⚙️ 开发环境配置</h3>
            <p><strong>OPcache启用:</strong> 
                <span class="status <?php echo $opcache_enabled ? 'warning' : 'success'; ?>">
                    <?php echo $opcache_enabled ? '启用' : '禁用'; ?>
                </span>
            </p>
            <p><strong>显示错误:</strong> 
                <span class="status <?php echo $display_errors ? 'success' : 'error'; ?>">
                    <?php echo $display_errors ? '启用' : '禁用'; ?>
                </span>
            </p>
        </div>
        
        <div class="section">
            <h3>🧪 测试说明</h3>
            <ol>
                <li>修改此文件的内容（比如改变颜色或文字）</li>
                <li>保存文件</li>
                <li>刷新页面或等待自动刷新（10秒）</li>
                <li>查看变化是否立即生效</li>
            </ol>
        </div>
        
        <div class="section">
            <h3>🔗 快速链接</h3>
            <a href="index.php" class="btn">🏠 返回首页</a>
            <a href="phpinfo.php" class="btn">ℹ️ PHP信息</a>
            <a href="grpc-test.php" class="btn">🚀 gRPC测试</a>
        </div>
        
        <p style="text-align: center; color: #666; margin-top: 30px;">
            <strong>⏰ 页面将在10秒后自动刷新</strong>
        </p>
    </div>
</body>
</html> 