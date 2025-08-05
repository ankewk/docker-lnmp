#!/bin/bash

# 等待主库启动
echo "等待主库启动..."
sleep 30

# 获取主库的binlog信息
MASTER_LOG_FILE=$(mysql -h mysql-master -u root -p${MYSQL_ROOT_PASSWORD:-root123456} -e "SHOW MASTER STATUS\G" | grep File | awk '{print $2}')
MASTER_LOG_POS=$(mysql -h mysql-master -u root -p${MYSQL_ROOT_PASSWORD:-root123456} -e "SHOW MASTER STATUS\G" | grep Position | awk '{print $2}')

echo "主库日志文件: $MASTER_LOG_FILE"
echo "主库日志位置: $MASTER_LOG_POS"

# 配置从库复制
mysql -u root -p${MYSQL_ROOT_PASSWORD:-root123456} << EOF
STOP SLAVE;
CHANGE MASTER TO 
    MASTER_HOST='mysql-master',
    MASTER_PORT=3306,
    MASTER_USER='repl',
    MASTER_PASSWORD='repl123456',
    MASTER_LOG_FILE='$MASTER_LOG_FILE',
    MASTER_LOG_POS=$MASTER_LOG_POS;
START SLAVE;
SHOW SLAVE STATUS\G
EOF

echo "从库复制配置完成" 