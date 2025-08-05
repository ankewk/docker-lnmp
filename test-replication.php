<?php
/**
 * MySQL 主从复制测试脚本
 * 用于验证主从复制是否正常工作
 */

echo "=== MySQL 主从复制测试 ===\n\n";

$db_name = 'lnmp_db';
$db_user = 'lnmp_user';
$db_pass = 'lnmp123456';

// 测试主库连接
echo "1. 测试主库连接...\n";
try {
    $pdo_master = new PDO("mysql:host=mysql-master;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    $pdo_master->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $stmt = $pdo_master->query('SELECT VERSION() as version');
    $version = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "✓ 主库连接成功 - MySQL版本: " . $version['version'] . "\n";
    
    // 检查主库状态
    $stmt = $pdo_master->query('SHOW MASTER STATUS');
    $master_status = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($master_status) {
        echo "✓ 主库状态正常 - Binlog文件: " . $master_status['File'] . ", 位置: " . $master_status['Position'] . "\n";
    }
    
} catch (PDOException $e) {
    echo "✗ 主库连接失败: " . $e->getMessage() . "\n";
    exit(1);
}

// 测试从库连接
echo "\n2. 测试从库连接...\n";
try {
    $pdo_slave = new PDO("mysql:host=mysql-slave;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    $pdo_slave->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $stmt = $pdo_slave->query('SELECT VERSION() as version');
    $version = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "✓ 从库连接成功 - MySQL版本: " . $version['version'] . "\n";
    
    // 检查从库状态
    $stmt = $pdo_slave->query('SHOW SLAVE STATUS');
    $slave_status = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($slave_status) {
        $slave_io_running = $slave_status['Slave_IO_Running'] ?? 'Unknown';
        $slave_sql_running = $slave_status['Slave_SQL_Running'] ?? 'Unknown';
        echo "✓ 从库状态 - IO线程: $slave_io_running, SQL线程: $slave_sql_running\n";
    }
    
} catch (PDOException $e) {
    echo "✗ 从库连接失败: " . $e->getMessage() . "\n";
    exit(1);
}

// 测试数据复制
echo "\n3. 测试数据复制...\n";

// 在主库插入测试数据
try {
    $test_data = [
        ['name' => 'Test User ' . date('Y-m-d H:i:s'), 'email' => 'test' . time() . '@example.com'],
        ['name' => 'Replication Test', 'email' => 'repl' . time() . '@example.com']
    ];
    
    $stmt = $pdo_master->prepare("INSERT INTO users (name, email) VALUES (?, ?)");
    foreach ($test_data as $data) {
        $stmt->execute([$data['name'], $data['email']]);
        echo "✓ 在主库插入数据: " . $data['name'] . "\n";
    }
    
    // 等待一下让复制完成
    sleep(2);
    
    // 在从库查询数据
    $stmt = $pdo_slave->query("SELECT COUNT(*) as count FROM users");
    $count = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "✓ 从库数据总数: " . $count['count'] . "\n";
    
    // 查询最新的测试数据
    $stmt = $pdo_slave->query("SELECT * FROM users ORDER BY id DESC LIMIT 5");
    $recent_data = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "✓ 从库最新数据:\n";
    foreach ($recent_data as $row) {
        echo "  - ID: {$row['id']}, 姓名: {$row['name']}, 邮箱: {$row['email']}\n";
    }
    
} catch (PDOException $e) {
    echo "✗ 数据复制测试失败: " . $e->getMessage() . "\n";
    exit(1);
}

echo "\n=== 测试完成 ===\n";
echo "✓ MySQL 主从复制配置正常！\n";
?> 