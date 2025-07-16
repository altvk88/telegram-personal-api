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

# Установка необходимых пакетов
echo "Установка необходимых пакетов..."
apt-get install -y git curl nginx certbot python3-certbot-nginx

# Проверка наличия Docker
echo "Проверка Docker..."
if ! command -v docker &> /dev/null; then
    echo "Docker не установлен. Устанавливаем Docker..."
    # Используйте официальный способ установки Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
else
    echo "Docker уже установлен."
fi

# Проверка наличия Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose не установлен. Устанавливаем Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose уже установлен."
fi

# Настройка переменных окружения
echo "Настройка переменных окружения..."
if [ -f .env.example ]; then
    cp .env.example .env
    echo "Файл .env создан из .env.example"
else
    echo "ВНИМАНИЕ: Файл .env.example не найден. Проверьте, что вы находитесь в корневой директории проекта."
    exit 1
fi

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
if [ -f nginx/tg.platva.ru.conf ]; then
    cp nginx/tg.platva.ru.conf /etc/nginx/sites-available/
    ln -sf /etc/nginx/sites-available/tg.platva.ru.conf /etc/nginx/sites-enabled/
    nginx -t

    if [ $? -ne 0 ]; then
        echo "Ошибка в конфигурации Nginx. Исправьте ошибки и перезапустите скрипт."
        exit 1
    fi

    systemctl restart nginx
else
    echo "ВНИМАНИЕ: Файл nginx/tg.platva.ru.conf не найден. Проверьте, что вы находитесь в корневой директории проекта."
    exit 1
fi

# Настройка SSL
echo "Хотите настроить SSL для домена tg.platva.ru? (y/n)"
read setup_ssl

if [ "$setup_ssl" == "y" ] || [ "$setup_ssl" == "Y" ]; then
    certbot --nginx -d tg.platva.ru
    
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
echo "API доступен по адресу: https://tg.platva.ru"
echo ""
echo "Для авторизации в Telegram выполните следующие команды:"
echo "1. Проверьте статус авторизации:"
echo "   curl -u admin:$new_password https://tg.platva.ru/status"
echo ""
echo "2. Отправьте код на телефон (если не авторизованы):"
echo "   curl -u admin:$new_password -X POST -H \"Content-Type: application/json\" -d '{\"phone\": \"+79XXXXXXXXX\"}' https://tg.platva.ru/login/send_code"
echo ""
echo "3. Введите код из SMS:"
echo "   curl -u admin:$new_password -X POST -H \"Content-Type: application/json\" -d '{\"phone\": \"+79XXXXXXXXX\", \"code\": \"12345\", \"phone_code_hash\": \"hash_из_предыдущего_ответа\"}' https://tg-api.itpovar.ru/login/verify_code"
echo ""
echo "4. При необходимости введите пароль 2FA:"
echo "   curl -u admin:$new_password -X POST -H \"Content-Type: application/json\" -d '{\"password\": \"ваш_пароль_2fa\"}' https://tg.platva.ru/login/2fa"
