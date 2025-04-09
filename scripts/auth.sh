#!/bin/bash

# Простой скрипт авторизации в Telegram API
# Запрашивает только то, что действительно нужно

# Настройки по умолчанию
API_URL="https://tg-api.itpovar.ru"
USERNAME="admin"
PASSWORD="changeThisPassword"
PHONE="+79952997565"  # Ваш номер

# Цветной вывод
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода статуса
print_status() {
  curl -s -u $USERNAME:$PASSWORD $API_URL/status
}

# Проверяем текущий статус авторизации
echo -e "${BLUE}Проверка статуса авторизации...${NC}"
STATUS=$(print_status)
echo $STATUS

if echo $STATUS | grep -q '"authorized": true'; then
  echo -e "${GREEN}Вы уже авторизованы в Telegram.${NC}"
  exit 0
fi

# Отправка кода
echo -e "${BLUE}Отправка кода на телефон $PHONE...${NC}"
SEND_CODE_RESPONSE=$(curl -s -u $USERNAME:$PASSWORD -X POST \
  -H "Content-Type: application/json" \
  -d "{\"phone\": \"$PHONE\"}" \
  $API_URL/login/send_code)

echo $SEND_CODE_RESPONSE

# Извлекаем phone_code_hash
if echo $SEND_CODE_RESPONSE | grep -q '"phone_code_hash"'; then
  PHONE_CODE_HASH=$(echo $SEND_CODE_RESPONSE | grep -o '"phone_code_hash": "[^"]*' | cut -d'"' -f4)
  echo -e "${GREEN}Код отправлен на номер $PHONE${NC}"
else
  echo -e "${RED}Ошибка при отправке кода!${NC}"
  exit 1
fi

# Запрос кода подтверждения
echo -e "${BLUE}Введите код подтверждения из Telegram:${NC}"
read CODE

# Отправка кода подтверждения
echo -e "${BLUE}Подтверждение кода...${NC}"
VERIFY_CODE_RESPONSE=$(curl -s -u $USERNAME:$PASSWORD -X POST \
  -H "Content-Type: application/json" \
  -d "{\"phone\": \"$PHONE\", \"code\": \"$CODE\", \"phone_code_hash\": \"$PHONE_CODE_HASH\"}" \
  $API_URL/login/verify_code)

echo $VERIFY_CODE_RESPONSE

# Проверяем, нужна ли 2FA
if echo $VERIFY_CODE_RESPONSE | grep -q '"status": "2fa_needed"'; then
  echo -e "${BLUE}Требуется двухфакторная аутентификация.${NC}"
  echo -e "${BLUE}Введите пароль 2FA:${NC}"
  read -s PASSWORD_2FA

  # Отправка пароля 2FA
  echo -e "${BLUE}Отправка пароля 2FA...${NC}"
  TFA_RESPONSE=$(curl -s -u $USERNAME:$PASSWORD -X POST \
    -H "Content-Type: application/json" \
    -d "{\"password\": \"$PASSWORD_2FA\"}" \
    $API_URL/login/2fa)
  
  echo $TFA_RESPONSE
  
  if echo $TFA_RESPONSE | grep -q '"status": "success"'; then
    echo -e "${GREEN}Авторизация успешно завершена!${NC}"
  else
    echo -e "${RED}Ошибка при подтверждении 2FA!${NC}"
    exit 1
  fi
elif echo $VERIFY_CODE_RESPONSE | grep -q '"status": "success"'; then
  echo -e "${GREEN}Авторизация успешно завершена!${NC}"
else
  echo -e "${RED}Ошибка при подтверждении кода!${NC}"
  exit 1
fi

# Проверяем финальный статус авторизации
echo -e "${BLUE}Проверка итогового статуса...${NC}"
FINAL_STATUS=$(print_status)
echo $FINAL_STATUS

if echo $FINAL_STATUS | grep -q '"authorized": true'; then
  echo -e "${GREEN}АПИ успешно подключено к Telegram!${NC}"
else
  echo -e "${RED}Что-то пошло не так. API не авторизован.${NC}"
fi
