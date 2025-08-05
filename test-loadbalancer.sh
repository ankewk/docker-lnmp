#!/bin/bash

# 负载均衡器测试脚本
# 用于验证负载均衡器是否正常工作

echo "=== 负载均衡器测试 ==="
echo ""

# 检查负载均衡器是否运行
echo "1. 检查负载均衡器状态..."
if curl -s http://localhost:8889/health > /dev/null 2>&1; then
    echo "✓ 负载均衡器运行正常"
else
    echo "✗ 负载均衡器未运行或无法访问"
    echo "请先启动负载均衡器: ./lb-manager.sh start"
    exit 1
fi

echo ""
echo "2. 测试健康检查端点..."
curl -s http://localhost:8889/health | jq . 2>/dev/null || curl -s http://localhost:8889/health
echo ""

echo "3. 测试负载均衡功能 (10次请求)..."
echo "注意观察 container_id 是否相同:"
echo ""

for i in {1..10}; do
    echo "请求 $i:"
    response=$(curl -s http://localhost:8889/lb-test.php)
    echo "$response" | jq -r '.container_id, .timestamp, .request_count' 2>/dev/null || echo "$response"
    echo ""
    sleep 0.5
done

echo "4. 测试后端服务器直接访问..."
echo "后端服务器 (端口 8888):"
curl -s http://localhost:8888/lb-test.php | jq -r '.container_id, .timestamp' 2>/dev/null || curl -s http://localhost:8888/lb-test.php
echo ""

echo "5. 比较负载均衡器和后端服务器..."
echo "负载均衡器 (端口 8889):"
curl -s http://localhost:8889/lb-test.php | jq -r '.container_id, .timestamp' 2>/dev/null || curl -s http://localhost:8889/lb-test.php
echo ""

echo "=== 测试完成 ==="
echo "如果负载均衡器正常工作，你应该看到:"
echo "- 健康检查返回正常状态"
echo "- 负载均衡器将请求转发到后端服务器"
echo "- 两个端口的 container_id 应该相同" 