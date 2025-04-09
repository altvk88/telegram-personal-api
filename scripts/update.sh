#!/bin/bash

# Скрипт для обновления Telegram API на сервере

echo "Обновление Telegram User API..."

# Переходим в директорию проекта
cd /opt/telegram-user-api

# Сохраняем текущую версию .env
cp .env .env.backup

# Обновляем код из репозитория
git fetch
git reset --hard origin/main
git pull

# Восстанавливаем .env
mv .env.backup .env

# Перезапускаем контейнер
docker-compose down
docker-compose up -d --build

echo "Обновление завершено!"
echo "API доступен по адресу: https://tg-api.itpovar.ru"
