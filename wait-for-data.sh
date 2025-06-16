#!/bin/bash

DATA_DIR=$1
shift
REQUIRED_FILES="users.csv publics.csv friends.csv followers.csv public_subs.csv"

echo "[wait-for-data] Ожидание генерации файлов в $DATA_DIR..."

while true; do
  all_present=true
  for f in $REQUIRED_FILES; do
    if [ ! -f "$DATA_DIR/$f" ]; then
      all_present=false
      echo "Жду $DATA_DIR/$f ..."
      break
    fi
  done
  if [ "$all_present" = true ]; then
    break
  fi
  sleep 1
done

echo "[wait-for-data] Все файлы csv найдены. Продолжаю работу."
exec "$@"
