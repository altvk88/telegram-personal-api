# API Reference

## Основная информация

Все запросы к API требуют HTTP Basic аутентификации.
Базовый URL: `https://tg-api.itpovar.ru`

## Авторизация

### Проверка статуса авторизации

```
GET /status
```

**Ответ при успешной авторизации:**
```json
{
  "authorized": true,
  "user": {
    "id": 12345678,
    "first_name": "Имя",
    "last_name": "Фамилия",
    "username": "username",
    "phone": "+79123456789"
  }
}
```

**Ответ при отсутствии авторизации:**
```json
{
  "authorized": false
}
```

### Отправка кода авторизации

```
POST /login/send_code
```

**Параметры запроса:**
```json
{
  "phone": "+79123456789"
}
```

**Ответ:**
```json
{
  "status": "code_sent",
  "phone_code_hash": "hash_для_подтверждения"
}
```

### Подтверждение кода

```
POST /login/verify_code
```

**Параметры запроса:**
```json
{
  "phone": "+79123456789",
  "code": "12345",
  "phone_code_hash": "hash_из_предыдущего_ответа"
}
```

**Ответ при успешной авторизации:**
```json
{
  "status": "success"
}
```

**Ответ при необходимости 2FA:**
```json
{
  "status": "2fa_needed"
}
```

### Подтверждение 2FA

```
POST /login/2fa
```

**Параметры запроса:**
```json
{
  "password": "your_2fa_password"
}
```

**Ответ:**
```json
{
  "status": "success"
}
```

## Сообщения

### Отправка текста

```
POST /send/text
```

**Параметры запроса:**
```json
{
  "recipient": "@username",  // или ID чата или номер телефона
  "text": "Текст сообщения",
  "parse_mode": "html"  // опционально, поддерживает "html" или "markdown"
}
```

**Ответ:**
```json
{
  "status": "success",
  "message_id": 123456,
  "date": "2025-04-09T15:10:57+00:00"
}
```

### Отправка файла

```
POST /send/file
```

**Форма запроса:**
- `recipient`: @username или ID чата или номер телефона
- `caption`: Текстовое описание файла (опционально)
- `file`: Файл для отправки

**Ответ:**
```json
{
  "status": "success",
  "message_id": 123456,
  "date": "2025-04-09T15:10:57+00:00"
}
```

## Контакты

### Получение списка контактов

```
GET /contacts
```

**Ответ:**
```json
{
  "contacts": [
    {
      "id": 12345678,
      "name": "Контакт 1",
      "type": "user",
      "username": "username1"
    },
    {
      "id": 87654321,
      "name": "Группа 1",
      "type": "group"
    },
    {
      "id": 11223344,
      "name": "Канал 1",
      "type": "channel",
      "username": "channel1"
    }
  ]
}
```

## Коды ошибок

- `401 Unauthorized`: Неверные учетные данные HTTP Basic аутентификации
- `401 Не авторизован в Telegram`: Требуется авторизация в Telegram API
- `404 Получатель не найден`: Указанный получатель не найден
- `500 Ошибка при отправке сообщения/файла`: Ошибка при выполнении операции
