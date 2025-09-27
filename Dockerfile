FROM python:3.11-slim
WORKDIR /app

# Build deps if mysqlclient needed (safe default)
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential default-libmysqlclient-dev && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
ENV PORT=8080
EXPOSE 8080
CMD ["python3","app.py"]
