#!/bin/bash

# Скрипт для подтверждения кода Telegram, когда код уже был запрошен

# Настройки
API_URL="https://tg.platva.ru"
USERNAME="admin"

# Запрашиваем пароль администратора
echo "Введите пароль администратора (по умолчанию 'changeThisPassword'):"
read -s PASSWORD
echo ""

if [ -z "$PASSWORD" ]; then
  PASSWORD="changeThisPassword"
fi

# Запрос номера телефона
echo "Введите номер телефона (в формате +79XXXXXXXXX):"
read PHONE

# Запрос hash из предыдущего ответа
echo "Введите phone_code_hash из предыдущего ответа:"
read PHONE_CODE_HASH

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
VERIFY_SUCCESS=$(echo $VERIFY_CODE_RESPONSE | grep -o '"status": "success"' | wc -l)
VERIFY_ERROR=$(echo $VERIFY_CODE_RESPONSE | grep -o '"status": "error"' | wc -l)

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
  ERROR_2FA=$(echo $TFA_RESPONSE | grep -o '"status": "error"' | wc -l)
  
  if [ $SUCCESS_2FA -gt 0 ]; then
    echo "Авторизация успешно завершена!"
  elif [ $ERROR_2FA -gt 0 ]; then
    ERROR_MESSAGE=$(echo $TFA_RESPONSE | grep -o '"message": "[^"]*' | cut -d'"' -f4)
    echo "Ошибка при подтверждении 2FA: $ERROR_MESSAGE"
    exit 1
  else
    echo "Неизвестный ответ при подтверждении 2FA:"
    echo $TFA_RESPONSE
    exit 1
  fi
elif [ $VERIFY_SUCCESS -gt 0 ]; then
  echo "Авторизация успешно завершена!"
elif [ $VERIFY_ERROR -gt 0 ]; then
  ERROR_MESSAGE=$(echo $VERIFY_CODE_RESPONSE | grep -o '"message": "[^"]*' | cut -d'"' -f4)
  echo "Ошибка при подтверждении кода: $ERROR_MESSAGE"
  exit 1
else
  echo "Неизвестный ответ при подтверждении кода:"
  echo $VERIFY_CODE_RESPONSE
  exit 1
fi

# Проверяем финальный статус авторизации
echo "Проверка итогового статуса..."
FINAL_STATUS=$(curl -s -u $USERNAME:$PASSWORD $API_URL/status)
FINAL_AUTHORIZED=$(echo $FINAL_STATUS | grep -o '"authorized": true' | wc -l)

if [ $FINAL_AUTHORIZED -gt 0 ]; then
  echo "Статус: авторизован"
  echo "Теперь API готов к использованию!"
else
  echo "Статус: не авторизован"
  echo "Проверьте данные ответа:"
  echo $FINAL_STATUS
fi
