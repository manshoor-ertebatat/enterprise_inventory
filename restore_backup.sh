#!/usr/bin/env bash
set -e

PROJECT_DIR="$HOME/enterprise_inventory"
DB_PATH="$PROJECT_DIR/instance/data.db"
BACKUP_DIR="$PROJECT_DIR/instance/backups"

cd "$PROJECT_DIR"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "پوشه بکاپ پیدا نشد:"
    echo "$BACKUP_DIR"
    exit 1
fi

mapfile -t BACKUPS < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.db" -printf "%f\n" | sort -r)

if [ "${#BACKUPS[@]}" -eq 0 ]; then
    echo "هیچ فایل بکاپی پیدا نشد."
    exit 1
fi

echo
echo "بکاپ‌های موجود:"
echo

for i in "${!BACKUPS[@]}"; do
    printf "%d) %s\n" "$((i+1))" "${BACKUPS[$i]}"
done

echo
read -rp "شماره بکاپ موردنظر برای بازیابی را وارد کنید: " CHOICE

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "${#BACKUPS[@]}" ]; then
    echo "شماره واردشده معتبر نیست."
    exit 1
fi

SELECTED="$BACKUP_DIR/${BACKUPS[$((CHOICE-1))]}"

echo
echo "بکاپ انتخاب‌شده:"
echo "$SELECTED"
read -rp "هشدار: اطلاعات فعلی جایگزین می‌شود. ادامه می‌دهید؟ (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "عملیات لغو شد."
    exit 0
fi

EMERGENCY="$BACKUP_DIR/before_restore_$(date +%Y-%m-%d_%H%M%S).db"

echo "در حال ساخت بکاپ اضطراری از دیتابیس فعلی..."
cp "$DB_PATH" "$EMERGENCY"

echo "در حال توقف برنامه..."
docker compose stop

echo "در حال بازیابی بکاپ..."
cp "$SELECTED" "$DB_PATH"

echo "در حال اجرای دوباره برنامه..."
docker compose up -d

echo
echo "بازیابی با موفقیت انجام شد."
echo "بکاپ اضطراری فعلی:"
echo "$EMERGENCY"
