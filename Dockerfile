FROM python:3.11-slim

WORKDIR /app

# Обновляем pip и устанавливаем wheel перед установкой других пакетов
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "app.api:app", "--host", "0.0.0.0", "--port", "8000"]