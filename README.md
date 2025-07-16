# Telegram User API

API для отправки сообщений через личный аккаунт Telegram с интеграцией n8n.

## Функции

- Отправка текстовых сообщений в личные и групповые чаты
- Отправка файлов и изображений
- Работа с контактами (username/номер телефона/ID чата)
- Отправка в групповые чаты и каналы
- Интеграция с n8n для использования в автоматизации

## Быстрая установка

```bash
# Клонируем репозиторий
git clone https://github.com/altvk88/telegram-personal-api.git
cd telegram-personal-api

# Делаем скрипт установки исполняемым
chmod +x scripts/install.sh

# Запускаем установку
sudo ./scripts/install.sh
```

Скрипт установки автоматически:
- Настроит необходимое окружение
- Настроит Nginx для проксирования на API
- Настроит SSL с помощью Let's Encrypt
- Запустит Docker контейнер с API

## Ручная установка

Если вы хотите выполнить установку вручную:

1. Клонируем репозиторий
```bash
git clone [https://github.com/CreatmanCEO/telegram-personal-api.git](https://github.com/altvk88/telegram-personal-api.git)
cd telegram-personal-api
```

2. Настраиваем переменные окружения
```bash
cp .env.example .env
nano .env  # Отредактируйте настройки при необходимости
```

3. Запускаем Docker контейнер
```bash
docker-compose up -d
```

4. Настраиваем Nginx
```bash
sudo cp nginx/tg.platva.ru.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/tg.platva.ru.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

5. Настраиваем SSL (опционально)
```bash
sudo certbot --nginx -d tg.platva.ru
```

## Авторизация в Telegram

После настройки API вам необходимо авторизоваться в Telegram:

1. Проверка статуса авторизации
```bash
curl -u admin:ваш_пароль https://tg.platva.ru/status
```

2. Отправка кода авторизации
```bash
curl -u admin:ваш_пароль -X POST \
  -H "Content-Type: application/json" \
  -d '{"phone": "+79XXXXXXXXX"}' \
  https://tg-api.itpovar.ru/login/send_code
```

3. Подтверждение кода
```bash
curl -u admin:ваш_пароль -X POST \
  -H "Content-Type: application/json" \
  -d '{"phone": "+79XXXXXXXXX", "code": "12345", "phone_code_hash": "hash_из_предыдущего_ответа"}' \
  https://tg.platva.ru/login/verify_code
```

4. Подтверждение 2FA (если требуется)
```bash
curl -u admin:ваш_пароль -X POST \
  -H "Content-Type: application/json" \
  -d '{"password": "ваш_пароль_2fa"}' \
  https://tg-api.itpovar.ru/login/2fa
```

## Примеры использования API

### Отправка текстового сообщения
```bash
curl -u admin:ваш_пароль -X POST \
  -H "Content-Type: application/json" \
  -d '{"recipient": "@username", "text": "Привет от API!"}' \
  https://tg-api.itpovar.ru/send/text
```

### Отправка файла
```bash
curl -u admin:ваш_пароль -X POST \
  -F "recipient=@username" \
  -F "caption=Мой файл" \
  -F "file=@/path/to/file.jpg" \
  https://tg.platva.ru/send/file
```

### Получение списка контактов
```bash
curl -u admin:ваш_пароль https:/tg.platva.ru/contacts
```

## Обновление

Для обновления API вы можете:

1. Использовать скрипт обновления
```bash
cd /opt/telegram-user-api
chmod +x scripts/update.sh
./scripts/update.sh
```

2. Или обновить вручную
```bash
cd /opt/telegram-user-api
git pull
docker-compose down
docker-compose up -d --build
```

## Интеграция с n8n

Для интеграции с n8n см. [инструкцию по интеграции](docs/n8n-integration.md).

Пример workflow доступен в [examples/n8n-workflow.json](examples/n8n-workflow.json).

## Документация

- [API Reference](docs/api-reference.md) - полная документация по API
- [Интеграция с n8n](docs/n8n-integration.md) - руководство по интеграции с n8n

## Особенности и решение проблем

- **Сессия**: Сессия Telegram сохраняется в Docker volume, поэтому она не будет потеряна при перезапуске контейнера.
- **Единая сессия**: Данная реализация использует одну постоянную сессию, что решает проблему с выходом из аккаунта на других устройствах.
- **Современный Python**: Используется Python 3.11, что решает проблемы с устаревшими библиотеками.
- **Поддержка кириллицы**: Все сообщения корректно обрабатывают кириллицу и спецсимволы.

## Лицензия

MIT
