<?php
/**
 * gRPC 客户端示例
 * 演示如何连接到 gRPC 服务器
 */

require_once __DIR__ . '/vendor/autoload.php';

use Grpc\Channel;
use Hello\GreeterClient;
use Hello\HelloRequest;

// 创建 gRPC 客户端
$channel = new Channel('localhost:50051', []);
$client = new GreeterClient('localhost:50051', [
    'credentials' => \Grpc\ChannelCredentials::createInsecure(),
]);

// 创建请求
$request = new HelloRequest();
$request->setName('World');
$request->setMessage('This is a test message from gRPC client!');

try {
    // 发送请求
    list($response, $status) = $client->SayHello($request)->wait();
    
    if ($status->code === \Grpc\STATUS_OK) {
        echo "gRPC 响应:\n";
        echo "消息: " . $response->getMessage() . "\n";
        echo "时间戳: " . $response->getTimestamp() . "\n";
        echo "服务器信息: " . $response->getServerInfo() . "\n";
    } else {
        echo "gRPC 错误: " . $status->details . "\n";
    }
} catch (Exception $e) {
    echo "连接错误: " . $e->getMessage() . "\n";
}

$channel->close();
?> 