<?php
/**
 * gRPC 服务器示例
 * 演示如何使用 gRPC 和 Protobuf
 */

require_once __DIR__ . '/vendor/autoload.php';

use Grpc\Server;
use Hello\GreeterInterface;
use Hello\HelloRequest;
use Hello\HelloReply;

class GreeterService implements GreeterInterface
{
    public function SayHello(\Hello\HelloRequest $request): \Hello\HelloReply
    {
        $reply = new HelloReply();
        $reply->setMessage("Hello, " . $request->getName() . "! " . $request->getMessage());
        $reply->setTimestamp(date('Y-m-d H:i:s'));
        $reply->setServerInfo("PHP gRPC Server - " . PHP_VERSION);
        
        return $reply;
    }
    
    public function SayHelloStream(\Hello\HelloRequest $request, \Grpc\ServerCallWriter $writer): void
    {
        for ($i = 1; $i <= 5; $i++) {
            $reply = new HelloReply();
            $reply->setMessage("Stream Hello #{$i}, " . $request->getName() . "! " . $request->getMessage());
            $reply->setTimestamp(date('Y-m-d H:i:s'));
            $reply->setServerInfo("PHP gRPC Stream Server - " . PHP_VERSION);
            
            $writer->write($reply);
            sleep(1);
        }
        
        $writer->finish();
    }
}

// 创建 gRPC 服务器
$server = new Server();
$server->addHttp2Port('0.0.0.0:50051');
$server->handle(new GreeterService());

echo "gRPC 服务器启动在端口 50051...\n";
$server->run();
?> 