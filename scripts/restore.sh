#!/usr/bin/env bash
set -euo pipefail

FILE="${1:?Usage: ./scripts/restore.sh backups/file.sql}"

docker exec -i shop_mysql mysql -uapp -papp_pass < "$FILE"
echo "Restored from: $FILE"