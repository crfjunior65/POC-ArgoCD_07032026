FROM python:3.9-slim

WORKDIR /app

# Instala dependências de sistema mínimas para o Postgres
RUN apt-get update && apt-get install -y \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copia e instala dependências Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia a aplicação
COPY app.py .

# Expõe a porta
EXPOSE 8000

# Comando de execução
CMD ["python", "app.py"]