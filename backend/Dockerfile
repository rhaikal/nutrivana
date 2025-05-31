# Gunakan image resmi Python
FROM python:3.11-slim-bullseye

# Set working directory
WORKDIR /backend

# Install system dependencies (untuk PostgreSQL)
RUN apt-get update && apt-get install -y \
    libpq-dev gcc python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements terlebih dahulu untuk optimasi cache Docker
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

COPY . .

# Expose port (default FastAPI/Uvicorn: 8000)
EXPOSE 8000

CMD ["/wait-for-it.sh", "postgres:5432", "--timeout=60", "--strict", "--", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]