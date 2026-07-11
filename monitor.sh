# ====== 配置区 ======
CPU_THRESHOLD=80          # CPU 告警阈值 80%
MEM_THRESHOLD=80          # 内存告警阈值 80%
DISK_THRESHOLD=80         # 磁盘告警阈值 80%
LOG_FILE="/var/log/server_monitor.log"
ALERT_EMAIL="2182094084@qq.com"   # 改成你自己的邮箱

# ====== 获取当前资源使用率 ======
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F. '{print $1}')
MEM_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

# ====== 记录日志 ======
echo "$(date '+%Y-%m-%d %H:%M:%S') CPU:${CPU_USAGE}% MEM:${MEM_USAGE}% DISK:${DISK_USAGE}%" >> $LOG_FILE

# ====== 检查并告警 ======
if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
    echo "$(date) [告警] CPU使用率超过阈值: ${CPU_USAGE}%" >> $LOG_FILE
    echo "服务器 $(hostname) CPU使用率 ${CPU_USAGE}%，超过阈值 ${CPU_THRESHOLD}%" | mail -s "[告警] CPU使用率过高" $ALERT_EMAIL
fi

if [ "$MEM_USAGE" -gt "$MEM_THRESHOLD" ]; then
    echo "$(date) [告警] 内存使用率超过阈值: ${MEM_USAGE}%" >> $LOG_FILE
    echo "服务器 $(hostname) 内存使用率 ${MEM_USAGE}%，超过阈值 ${MEM_THRESHOLD}%" | mail -s "[告警] 内存使用率过高" $ALERT_EMAIL
fi

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "$(date) [告警] 磁盘使用率超过阈值: ${DISK_USAGE}%" >> $LOG_FILE
    echo "服务器 $(hostname) 磁盘使用率 ${DISK_USAGE}%，超过阈值 ${DISK_THRESHOLD}%" | mail -s "[告警] 磁盘使用率过高" $ALERT_EMAIL
fi
