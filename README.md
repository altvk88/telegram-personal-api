# Telegram User API

API для отправки сообщений через личный аккаунт Telegram с интеграцией n8n.

## Функции

- Отправка текстовых сообщений
- Отправка файлов и изображений
- Работа с контактами (username/номер телефона)
- Отправка в групповые чаты
- Интеграция с n8n

## Установка и запуск

1. Клонировать репозиторий
```bash
git clone https://github.com/CreatmanCEO/telegram-personal-api.git
cd telegram-personal-api
```

2. Запустить Docker контейнер
```bash
docker-compose up -d
```

3. Авторизоваться в Telegram API (примеры curl запросов в разделе API)

## API Endpoints

### Авторизация
- GET /status - Проверка статуса авторизации
- POST /login/send_code - Отправка кода
- POST /login/verify_code - Подтверждение кода
- POST /login/2fa - Подтверждение 2FA

### Сообщения
- POST /send/text - Отправка текста
- POST /send/file - Отправка файла

### Контакты
- GET /contacts - Получение списка контактов

## Примеры использования

### Проверка статуса авторизации
```bash
curl -u admin:changeThisPassword https://tg-api.itpovar.ru/status
```

### Отправка кода авторизации
```bash
curl -u admin:changeThisPassword -X POST -H "Content-Type: application/json" \
  -d '{"phone": "+79XXXXXXXXX"}' \
  https://tg-api.itpovar.ru/login/send_code
```

### Подтверждение кода
```bash
curl -u admin:changeThisPassword -X POST -H "Content-Type: application/json" \
  -d '{"phone": "+79XXXXXXXXX", "code": "12345", "phone_code_hash": "hash_из_предыдущего_ответа"}' \
  https://tg-api.itpovar.ru/login/verify_code
```

### Отправка сообщения
```bash
curl -u admin:changeThisPassword -X POST -H "Content-Type: application/json" \
  -d '{"recipient": "@username", "text": "Привет от API!"}' \
  https://tg-api.itpovar.ru/send/text
```