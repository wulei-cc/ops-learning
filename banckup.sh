
# ====== 配置区 ======
BACKUP_DIR="/home/wulei/backups"
DB_USER="root"
DB_PASSWORD="WP000000"
DB_NAME="wordpress"
KEEP_DAYS=7               # 保留天数

# ====== 创建备份目录 ======
mkdir -p $BACKUP_DIR

# ====== 执行备份 ======
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$(date +%Y%m%d_%H%M%S).sql.gz"
mysqldump -u$DB_USER -p$DB_PASSWORD $DB_NAME | gzip > $BACKUP_FILE

# ====== 检查备份是否成功 ======
if [ $? -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') 备份成功: $BACKUP_FILE" >> $BACKUP_DIR/backup.log
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') 备份失败!" >> $BACKUP_DIR/backup.log
fi

# ====== 删除7天前的旧备份 ======
find $BACKUP_DIR -name "*.sql.gz" -mtime +$KEEP_DAYS -delete
