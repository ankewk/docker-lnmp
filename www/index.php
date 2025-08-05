<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LNMP Docker 环境</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 2.5em;
            font-weight: 300;
        }
        .header p {
            margin: 10px 0 0 0;
            opacity: 0.9;
            font-size: 1.1em;
        }
        .content {
            padding: 30px;
        }
        .section {
            margin-bottom: 30px;
            padding: 20px;
            border: 1px solid #e1e5e9;
            border-radius: 8px;
            background: #f8f9fa;
        }
        .section h2 {
            margin-top: 0;
            color: #495057;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        .info-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid #667eea;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .status {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: bold;
        }
        .status.success {
            background: #d4edda;
            color: #155724;
        }
        .status.error {
            background: #f8d7da;
            color: #721c24;
        }
        .code {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 4px;
            padding: 15px;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
            overflow-x: auto;
        }
        .footer {
            text-align: center;
            padding: 20px;
            background: #f8f9fa;
            border-top: 1px solid #e1e5e9;
            color: #6c757d;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 LNMP Docker 环境</h1>
            <p>Linux + Nginx + MySQL + PHP <?php echo PHP_VERSION; ?> + Docker Compose</p>
        </div>
        
        <div class="content">
            <div class="section">
                <h2>📊 系统信息</h2>
                <div class="info-grid">
                    <div class="info-card">
                        <h3>PHP 信息</h3>
                        <p><strong>版本:</strong> <?php echo PHP_VERSION; ?></p>
                        <p><strong>服务器:</strong> <?php echo $_SERVER['SERVER_SOFTWARE'] ?? 'Nginx'; ?></p>
                        <p><strong>时间:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
                        <p><strong>时区:</strong> <?php echo date_default_timezone_get(); ?></p>
                    </div>
                    
                    <div class="info-card">
                        <h3>服务器信息</h3>
                        <p><strong>主机名:</strong> <?php echo gethostname(); ?></p>
                        <p><strong>IP地址:</strong> <?php echo $_SERVER['SERVER_ADDR'] ?? 'N/A'; ?></p>
                        <p><strong>端口:</strong> <?php echo $_SERVER['SERVER_PORT'] ?? '80'; ?></p>
                        <p><strong>请求方法:</strong> <?php echo $_SERVER['REQUEST_METHOD']; ?></p>
                    </div>
                </div>
            </div>

            <div class="section">
                <h2>🗄️ MySQL 主从复制连接测试</h2>
                <div class="info-grid">
                    <?php
                    $db_name = 'lnmp_db';
                    $db_user = 'lnmp_user';
                    $db_pass = 'lnmp123456';
                    
                    // 测试主库连接
                    try {
                        $pdo_master = new PDO("mysql:host=mysql-master;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
                        $pdo_master->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
                        
                        // 获取主库版本和状态
                        $stmt = $pdo_master->query('SELECT VERSION() as version');
                        $version = $stmt->fetch(PDO::FETCH_ASSOC);
                        
                        $stmt = $pdo_master->query('SHOW MASTER STATUS');
                        $master_status = $stmt->fetch(PDO::FETCH_ASSOC);
                        
                        echo '<div class="info-card">';
                        echo '<h3>MySQL Master 连接状态</h3>';
                        echo '<p><span class="status success">✓ 连接成功</span></p>';
                        echo '<p><strong>主机:</strong> mysql-master:3306</p>';
                        echo '<p><strong>数据库:</strong> ' . $db_name . '</p>';
                        echo '<p><strong>MySQL版本:</strong> ' . $version['version'] . '</p>';
                        if ($master_status) {
                            echo '<p><strong>Binlog文件:</strong> ' . $master_status['File'] . '</p>';
                            echo '<p><strong>Binlog位置:</strong> ' . $master_status['Position'] . '</p>';
                        }
                        echo '</div>';
                        
                    } catch (PDOException $e) {
                        echo '<div class="info-card">';
                        echo '<h3>MySQL Master 连接状态</h3>';
                        echo '<p><span class="status error">✗ 连接失败</span></p>';
                        echo '<p><strong>错误信息:</strong> ' . $e->getMessage() . '</p>';
                        echo '</div>';
                    }
                    
                    // 测试从库连接
                    try {
                        $pdo_slave = new PDO("mysql:host=mysql-slave;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
                        $pdo_slave->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
                        
                        // 获取从库版本和状态
                        $stmt = $pdo_slave->query('SELECT VERSION() as version');
                        $version = $stmt->fetch(PDO::FETCH_ASSOC);
                        
                        $stmt = $pdo_slave->query('SHOW SLAVE STATUS');
                        $slave_status = $stmt->fetch(PDO::FETCH_ASSOC);
                        
                        echo '<div class="info-card">';
                        echo '<h3>MySQL Slave 连接状态</h3>';
                        echo '<p><span class="status success">✓ 连接成功</span></p>';
                        echo '<p><strong>主机:</strong> mysql-slave:3307</p>';
                        echo '<p><strong>数据库:</strong> ' . $db_name . '</p>';
                        echo '<p><strong>MySQL版本:</strong> ' . $version['version'] . '</p>';
                        if ($slave_status) {
                            $slave_io_running = $slave_status['Slave_IO_Running'] ?? 'Unknown';
                            $slave_sql_running = $slave_status['Slave_SQL_Running'] ?? 'Unknown';
                            echo '<p><strong>IO线程状态:</strong> ' . $slave_io_running . '</p>';
                            echo '<p><strong>SQL线程状态:</strong> ' . $slave_sql_running . '</p>';
                        }
                        echo '</div>';
                        
                    } catch (PDOException $e) {
                        echo '<div class="info-card">';
                        echo '<h3>MySQL Slave 连接状态</h3>';
                        echo '<p><span class="status error">✗ 连接失败</span></p>';
                        echo '<p><strong>错误信息:</strong> ' . $e->getMessage() . '</p>';
                        echo '</div>';
                    }
                    ?>
                </div>
            </div>

            <div class="section">
                <h2>🔧 PHP 扩展信息</h2>
                <div class="code">
                    <?php
                    $extensions = [
                        'pdo_mysql' => 'MySQL PDO 驱动',
                        'mysqli' => 'MySQLi 扩展',
                        'gd' => 'GD 图像处理',
                        'mbstring' => '多字节字符串',
                        'curl' => 'cURL 扩展',
                        'json' => 'JSON 支持',
                        'openssl' => 'OpenSSL 加密',
                        'zip' => 'ZIP 压缩',
                        'xml' => 'XML 解析',
                        'opcache' => 'OPcache 缓存',
                        'redis' => 'Redis 扩展',
                        'mongodb' => 'MongoDB 扩展'
                    ];
                    
                    echo "<h3>已安装的扩展:</h3>";
                    foreach ($extensions as $ext => $desc) {
                        $status = extension_loaded($ext) ? '✓' : '✗';
                        $color = extension_loaded($ext) ? 'green' : 'red';
                        echo "<p style='color: $color;'>$status $desc ($ext)</p>";
                    }
                    ?>
                </div>
            </div>

            <div class="section">
                <h2>🔗 服务连接测试</h2>
                <div class="info-grid">
                    <?php
                    // Redis 连接测试
                    // Redis 连接测试
                    if (extension_loaded('redis')) {
                        try {
                            $redis_class = 'Redis';
                            $redis = new $redis_class();
                            $redis->connect('redis', 6379);
                            $redis->auth('redis123456');
                            $redis->set('test', 'Hello Redis!');
                            $test_value = $redis->get('test');
                            
                            echo '<div class="info-card">';
                            echo '<h3>Redis 连接状态</h3>';
                            echo '<p><span class="status success">✓ 连接成功</span></p>';
                            echo '<p><strong>主机:</strong> redis:6379</p>';
                            echo '<p><strong>测试值:</strong> ' . $test_value . '</p>';
                            echo '</div>';
                        } catch (Exception $e) {
                            echo '<div class="info-card">';
                            echo '<h3>Redis 连接状态</h3>';
                            echo '<p><span class="status error">✗ 连接失败</span></p>';
                            echo '<p><strong>错误信息:</strong> ' . $e->getMessage() . '</p>';
                            echo '</div>';
                        }
                    } else {
                        echo '<div class="info-card">';
                        echo '<h3>Redis 连接状态</h3>';
                        echo '<p><span class="status error">✗ Redis扩展未安装</span></p>';
                        echo '</div>';
                    }
                    
                    // MongoDB 连接测试
                    if (extension_loaded('mongodb')) {
                        try {
                            $mongo_class = 'MongoDB\Client';
                            $mongo = new $mongo_class("mongodb://admin:mongodb123456@mongodb:27017");
                            $database = $mongo->selectDatabase('lnmp_mongo');
                            $collection = $database->selectCollection('test');
                            $collection->insertOne(['message' => 'Hello MongoDB!']);
                            
                            echo '<div class="info-card">';
                            echo '<h3>MongoDB 连接状态</h3>';
                            echo '<p><span class="status success">✓ 连接成功</span></p>';
                            echo '<p><strong>主机:</strong> mongodb:27017</p>';
                            echo '<p><strong>数据库:</strong> lnmp_mongo</p>';
                            echo '</div>';
                        } catch (Exception $e) {
                            echo '<div class="info-card">';
                            echo '<h3>MongoDB 连接状态</h3>';
                            echo '<p><span class="status error">✗ 连接失败</span></p>';
                            echo '<p><strong>错误信息:</strong> ' . $e->getMessage() . '</p>';
                            echo '</div>';
                        }
                    } else {
                        echo '<div class="info-card">';
                        echo '<h3>MongoDB 连接状态</h3>';
                        echo '<p><span class="status error">✗ MongoDB扩展未安装</span></p>';
                        echo '</div>';
                    }
                    ?>
                </div>
            </div>

            <div class="section">
                <h2>⚖️ 负载均衡器信息</h2>
                <div class="info-grid">
                    <div class="info-card">
                        <h3>负载均衡器状态</h3>
                        <p><strong>端口:</strong> 8889</p>
                        <p><strong>算法:</strong> 轮询 (Round Robin)</p>
                        <p><strong>后端服务器:</strong> nginx-backend:80</p>
                        <p><strong>健康检查:</strong> <a href="http://localhost:8889/health" target="_blank">http://localhost:8889/health</a></p>
                        <p><strong>测试页面:</strong> <a href="http://localhost:8889/lb-test.php" target="_blank">http://localhost:8889/lb-test.php</a></p>
                    </div>
                    
                    <div class="info-card">
                        <h3>访问地址</h3>
                        <ul>
                            <li><strong>负载均衡器:</strong> <a href="http://localhost:8889" target="_blank">http://localhost:8889</a></li>
                            <li><strong>后端服务器:</strong> <a href="http://localhost:8888" target="_blank">http://localhost:8888</a></li>
                            <li><strong>健康检查:</strong> <a href="http://localhost:8889/health" target="_blank">http://localhost:8889/health</a></li>
                        </ul>
                    </div>
                </div>
            </div>

            <div class="section">
                <h2>🚀 gRPC & Composer 支持</h2>
                <div class="info-grid">
                    <div class="info-card">
                        <h3>gRPC 扩展状态</h3>
                        <?php
                        $grpc_installed = extension_loaded('grpc');
                        $protobuf_installed = extension_loaded('protobuf');
                        ?>
                        <p><strong>gRPC 扩展:</strong> <span class="status <?php echo $grpc_installed ? 'success' : 'error'; ?>"><?php echo $grpc_installed ? '✓ 已安装' : '✗ 未安装'; ?></span></p>
                        <p><strong>Protobuf 扩展:</strong> <span class="status <?php echo $protobuf_installed ? 'success' : 'error'; ?>"><?php echo $protobuf_installed ? '✓ 已安装' : '✗ 未安装'; ?></span></p>
                        <p><strong>测试页面:</strong> <a href="grpc-test.php" target="_blank">grpc-test.php</a></p>
                    </div>
                    
                    <div class="info-card">
                        <h3>Composer 状态</h3>
                        <?php
                        $composer_available = file_exists(__DIR__ . '/vendor/autoload.php');
                        ?>
                        <p><strong>Composer:</strong> <span class="status <?php echo $composer_available ? 'success' : 'warning'; ?>"><?php echo $composer_available ? '✓ 可用' : '⚠ 需要安装'; ?></span></p>
                        <p><strong>gRPC 项目:</strong> <a href="grpc/" target="_blank">grpc/</a></p>
                        <p><strong>示例文件:</strong></p>
                        <ul>
                            <li><a href="grpc/hello.proto" target="_blank">hello.proto</a></li>
                            <li><a href="grpc/server.php" target="_blank">server.php</a></li>
                            <li><a href="grpc/client.php" target="_blank">client.php</a></li>
                        </ul>
                    </div>
                    
                    <div class="info-card">
                        <h3>使用命令</h3>
                        <div class="code">
# 启动 gRPC 服务器
php www/grpc/server.php

# 运行 gRPC 客户端
php www/grpc/client.php

# Composer 命令
composer install
composer require grpc/grpc
                        </div>
                    </div>
                </div>
            </div>

            <div class="section">
                <h2>📝 使用说明</h2>
                <div class="info-grid">
                    <div class="info-card">
                        <h3>启动服务</h3>
                        <div class="code">
docker-compose up -d
                        </div>
                    </div>
                    
                    <div class="info-card">
                        <h3>停止服务</h3>
                        <div class="code">
docker-compose down
                        </div>
                    </div>
                    
                    <div class="info-card">
                        <h3>查看日志</h3>
                        <div class="code">
docker-compose logs -f
                        </div>
                    </div>
                    
                    <div class="info-card">
                        <h3>访问地址</h3>
                        <ul>
                                                    <li>网站: <a href="http://localhost" target="_blank">http://localhost</a></li>
                        <li>phpMyAdmin: <a href="http://localhost:8080" target="_blank">http://localhost:8080</a></li>
                        <li>gRPC 测试: <a href="grpc-test.php" target="_blank">grpc-test.php</a></li>
                        <li>热加载测试: <a href="hot-reload-test.php" target="_blank">hot-reload-test.php</a></li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>LNMP Docker 环境 | 基于 Docker Compose 构建</p>
        </div>
    </div>
</body>
</html> 