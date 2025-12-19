#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-backups}"
TS="$(date +%F_%H-%M-%S)"
mkdir -p "$OUT_DIR"

# Полный дамп (включая процедуры/функции/триггеры)
docker exec shop_mysql mysqldump -uapp -papp_pass \
  --databases shop_analytics --routines --triggers --events \
  > "${OUT_DIR}/shop_analytics_full_${TS}.sql"

# Чистка старых бэкапов (например, старше 14 дней)
find "$OUT_DIR" -type f -name "*.sql" -mtime +14 -delete

echo "Backup created: ${OUT_DIR}/shop_analytics_full_${TS}.sql"
