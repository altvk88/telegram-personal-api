#!/bin/bash

# Скрипт для использования уже запрошенного кода Telegram
# Использует существующий phone_code_hash без запроса нового кода

# Фиксированные данные
API_URL="https://tg-api.itpovar.ru"
USERNAME="admin"
PASSWORD="changeThisPassword"
PHONE="+79952997565"
PHONE_CODE_HASH="b2387c3327ba766c84"

# Запрос кода подтверждения
echo "Введите код подтверждения из Telegram:"
read CODE

# Отправка кода подтверждения
echo "Подтверждение кода..."
VERIFY_CODE_RESPONSE=$(curl -s -u $USERNAME:$PASSWORD -X POST \
  -H "Content-Type: application/json" \
  -d "{\"phone\": \"$PHONE\", \"code\": \"$CODE\", \"phone_code_hash\": \"$PHONE_CODE_HASH\"}" \
  $API_URL/login/verify_code)

echo $VERIFY_CODE_RESPONSE

# Проверяем, нужна ли 2FA
if echo $VERIFY_CODE_RESPONSE | grep -q '"status": "2fa_needed"'; then
  echo "Требуется двухфакторная аутентификация."
  echo "Введите пароль 2FA:"
  read -s PASSWORD_2FA

  # Отправка пароля 2FA
  echo "Отправка пароля 2FA..."
  TFA_RESPONSE=$(curl -s -u $USERNAME:$PASSWORD -X POST \
    -H "Content-Type: application/json" \
    -d "{\"password\": \"$PASSWORD_2FA\"}" \
    $API_URL/login/2fa)
  
  echo $TFA_RESPONSE
  
  if echo $TFA_RESPONSE | grep -q '"status": "success"'; then
    echo "Авторизация успешно завершена!"
  else
    echo "Ошибка при подтверждении 2FA:"
    echo $TFA_RESPONSE
    exit 1
  fi
elif echo $VERIFY_CODE_RESPONSE | grep -q '"status": "success"'; then
  echo "Авторизация успешно завершена!"
else
  echo "Ошибка при подтверждении кода:"
  echo $VERIFY_CODE_RESPONSE
  exit 1
fi

# Проверяем финальный статус авторизации
echo "Проверка итогового статуса..."
FINAL_STATUS=$(curl -s -u $USERNAME:$PASSWORD $API_URL/status)
echo $FINAL_STATUS

if echo $FINAL_STATUS | grep -q '"authorized": true'; then
  echo "API успешно авторизован!"
else
  echo "API не авторизован. Что-то пошло не так."
fi
