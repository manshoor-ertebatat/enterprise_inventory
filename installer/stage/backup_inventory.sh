#!/bin/bash

PROJECT="$HOME/enterprise_inventory"
BACKUP_DIR="$PROJECT/backups"
DB_FILE="$PROJECT/instance/data.db"

mkdir -p "$BACKUP_DIR"

if [ ! -f "$DB_FILE" ]; then
    echo "خطا: فایل دیتابیس پیدا نشد: $DB_FILE"
    exit 1
fi

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
cp "$DB_FILE" "$BACKUP_DIR/inventory_backup_$DATE.db"

# فقط 30 بکاپ آخر نگه داشته شود
ls -1t "$BACKUP_DIR"/inventory_backup_*.db 2>/dev/null | tail -n +31 | xargs -r rm -f

echo "بکاپ با موفقیت ساخته شد:"
echo "$BACKUP_DIR/inventory_backup_$DATE.db"
