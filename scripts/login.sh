#!/bin/bash

# Скрипт для интерактивной авторизации в Telegram API

# Настройки
API_URL="https://tg-api.itpovar.ru"
USERNAME="admin"

# Запрашиваем пароль администратора
echo "Введите пароль администратора (по умолчанию 'changeThisPassword'):"
read -s PASSWORD
echo ""

if [ -z "$PASSWORD" ]; then
  PASSWORD="changeThisPassword"
fi

# Проверяем текущий статус авторизации
echo "Проверка статуса авторизации..."
STATUS=$(curl -s -u $USERNAME:$PASSWORD $API_URL/status)
AUTHORIZED=$(echo $STATUS | grep -o '"authorized": true' | wc -l)

if [ $AUTHORIZED -gt 0 ]; then
  echo "Вы уже авторизованы в Telegram."
  exit 0
fi

# Запрос номера телефона
echo "Введите номер телефона (в формате +79XXXXXXXXX):"
read PHONE

# Отправка кода
echo "Отправка кода на телефон $PHONE..."
SEND_CODE_RESPONSE=$(curl -s -u $USERNAME:$PASSWORD -X POST \
  -H "Content-Type: application/json" \
  -d "{\"phone\": \"$PHONE\"}" \
  $API_URL/login/send_code)

# Извлекаем phone_code_hash
PHONE_CODE_HASH=$(echo $SEND_CODE_RESPONSE | grep -o '"phone_code_hash": "[^"]*' | cut -d'"' -f4)

if [ -z "$PHONE_CODE_HASH" ]; then
  echo "Ошибка при отправке кода:"
  echo $SEND_CODE_RESPONSE
  exit 1
fi

echo "Код отправлен. Проверьте ваш телефон."

# Запрос кода подтверждения
echo "Введите код подтверждения из SMS:"
read CODE

# Отправка кода подтверждения
echo "Подтверждение кода..."
VERIFY_CODE_RESPONSE=$(curl -s -u $USERNAME:$PASSWORD -X POST \
  -H "Content-Type: application/json" \
  -d "{\"phone\": \"$PHONE\", \"code\": \"$CODE\", \"phone_code_hash\": \"$PHONE_CODE_HASH\"}" \
  $API_URL/login/verify_code)

# Проверяем, нужна ли 2FA
NEED_2FA=$(echo $VERIFY_CODE_RESPONSE | grep -o '"status": "2fa_needed"' | wc -l)

if [ $NEED_2FA -gt 0 ]; then
  echo "Требуется двухфакторная аутентификация."
  echo "Введите пароль 2FA:"
  read -s PASSWORD_2FA

  # Отправка пароля 2FA
  echo "Отправка пароля 2FA..."
  TFA_RESPONSE=$(curl -s -u $USERNAME:$PASSWORD -X POST \
    -H "Content-Type: application/json" \
    -d "{\"password\": \"$PASSWORD_2FA\"}" \
    $API_URL/login/2fa)

  # Проверяем результат 2FA
  SUCCESS_2FA=$(echo $TFA_RESPONSE | grep -o '"status": "success"' | wc -l)
  
  if [ $SUCCESS_2FA -gt 0 ]; then
    echo "Авторизация успешно завершена!"
  else
    echo "Ошибка при подтверждении 2FA:"
    echo $TFA_RESPONSE
    exit 1
  fi
else
  # Проверяем результат подтверждения кода
  SUCCESS=$(echo $VERIFY_CODE_RESPONSE | grep -o '"status": "success"' | wc -l)
  
  if [ $SUCCESS -gt 0 ]; then
    echo "Авторизация успешно завершена!"
  else
    echo "Ошибка при подтверждении кода:"
    echo $VERIFY_CODE_RESPONSE
    exit 1
  fi
fi

# Проверяем финальный статус авторизации
echo "Проверка итогового статуса..."
FINAL_STATUS=$(curl -s -u $USERNAME:$PASSWORD $API_URL/status)
echo $FINAL_STATUS

echo ""
echo "Теперь API готов к использованию!"
