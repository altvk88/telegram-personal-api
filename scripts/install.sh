#!/bin/bash

# Скрипт для установки и настройки Telegram API на сервере

# Проверка запуска от root
if [ "$(id -u)" -ne 0 ]; then
    echo "Этот скрипт должен быть запущен с правами root" 
    exit 1
fi

echo "Начинаем установку Telegram User API..."

# Обновление пакетов
echo "Обновление пакетов..."
apt-get update
apt-get upgrade -y

# Установка необходимых пакетов
echo "Установка необходимых пакетов..."
apt-get install -y git docker.io docker-compose curl nginx certbot python3-certbot-nginx

# Настройка директории
echo "Настройка директорий..."
mkdir -p /opt/telegram-user-api
cd /opt/telegram-user-api

# Копирование .env.example в .env
echo "Настройка переменных окружения..."
cp .env.example .env

# Предлагаем изменить пароль
echo "Рекомендуется изменить пароль администратора в файле .env"
echo "Хотите изменить пароль сейчас? (y/n)"
read change_password

if [ "$change_password" == "y" ] || [ "$change_password" == "Y" ]; then
    echo "Введите новый пароль для администратора:"
    read new_password
    # Заменяем пароль в .env
    sed -i "s/ADMIN_PASSWORD=changeThisPassword/ADMIN_PASSWORD=$new_password/g" .env
    echo "Пароль успешно изменен!"
fi

# Настройка Nginx
echo "Настройка Nginx..."
cp nginx/tg-api.itpovar.ru.conf /etc/nginx/sites-available/
ln -sf /etc/nginx/sites-available/tg-api.itpovar.ru.conf /etc/nginx/sites-enabled/
nginx -t

if [ $? -ne 0 ]; then
    echo "Ошибка в конфигурации Nginx. Исправьте ошибки и перезапустите скрипт."
    exit 1
fi

systemctl restart nginx

# Настройка SSL
echo "Хотите настроить SSL для домена tg-api.itpovar.ru? (y/n)"
read setup_ssl

if [ "$setup_ssl" == "y" ] || [ "$setup_ssl" == "Y" ]; then
    certbot --nginx -d tg-api.itpovar.ru
    
    if [ $? -ne 0 ]; then
        echo "Ошибка при настройке SSL. Проверьте DNS и доступность домена."
        exit 1
    fi
    
    echo "SSL успешно настроен!"
fi

# Запуск Docker контейнера
echo "Запуск Docker контейнера..."
docker-compose up -d --build

echo "Установка завершена!"
echo "API доступен по адресу: https://tg-api.itpovar.ru"
echo ""
echo "Для авторизации в Telegram выполните следующие команды:"
echo "1. Проверьте статус авторизации:"
echo "   curl -u admin:$new_password https://tg-api.itpovar.ru/status"
echo ""
echo "2. Отправьте код на телефон (если не авторизованы):"
echo "   curl -u admin:$new_password -X POST -H \"Content-Type: application/json\" -d '{\"phone\": \"+79XXXXXXXXX\"}' https://tg-api.itpovar.ru/login/send_code"
echo ""
echo "3. Введите код из SMS:"
echo "   curl -u admin:$new_password -X POST -H \"Content-Type: application/json\" -d '{\"phone\": \"+79XXXXXXXXX\", \"code\": \"12345\", \"phone_code_hash\": \"hash_из_предыдущего_ответа\"}' https://tg-api.itpovar.ru/login/verify_code"
echo ""
echo "4. При необходимости введите пароль 2FA:"
echo "   curl -u admin:$new_password -X POST -H \"Content-Type: application/json\" -d '{\"password\": \"ваш_пароль_2fa\"}' https://tg-api.itpovar.ru/login/2fa"
