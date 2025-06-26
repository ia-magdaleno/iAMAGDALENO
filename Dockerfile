FROM python:3.11-slim
WORKDIR /app

# Instala utilidades necesarias
RUN apt-get update && \
    apt-get install -y cron postgresql-client && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copia el código fuente y scripts
COPY app ./app
COPY scripts/backup_db.sh /usr/local/bin/backup_db.sh
RUN chmod +x /usr/local/bin/backup_db.sh && \
    echo "0 3 * * * /usr/local/bin/backup_db.sh" > /etc/cron.d/backup_cron && \
    crontab /etc/cron.d/backup_cron

CMD ["sh", "-c", "cron && uvicorn app.main:app --host 0.0.0.0 --port 8000"]
