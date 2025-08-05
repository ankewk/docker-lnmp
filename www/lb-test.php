<?php
/**
 * 负载均衡测试页面
 * 用于验证负载均衡器是否正常工作
 */

// 获取服务器信息
$server_info = [
    'timestamp' => date('Y-m-d H:i:s'),
    'server_name' => $_SERVER['SERVER_NAME'] ?? 'unknown',
    'server_addr' => $_SERVER['SERVER_ADDR'] ?? 'unknown',
    'remote_addr' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
    'http_host' => $_SERVER['HTTP_HOST'] ?? 'unknown',
    'http_x_real_ip' => $_SERVER['HTTP_X_REAL_IP'] ?? 'unknown',
    'http_x_forwarded_for' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? 'unknown',
    'http_x_forwarded_proto' => $_SERVER['HTTP_X_FORWARDED_PROTO'] ?? 'unknown',
    'container_id' => gethostname(),
    'php_version' => PHP_VERSION,
    'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'unknown'
];

// 生成唯一的会话标识
session_start();
if (!isset($_SESSION['lb_session_id'])) {
    $_SESSION['lb_session_id'] = uniqid('lb_', true);
}

$server_info['session_id'] = $_SESSION['lb_session_id'];
$server_info['request_count'] = $_SESSION['request_count'] = ($_SESSION['request_count'] ?? 0) + 1;

// 设置响应头
header('Content-Type: application/json');
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');

// 输出JSON格式的服务器信息
echo json_encode($server_info, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?> 