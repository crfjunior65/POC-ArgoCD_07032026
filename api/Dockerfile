# Estágio 1: Build
FROM python:3.9-slim AS builder

WORKDIR /build

# Instala dependências de build
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copia e instala dependências
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Estágio 2: Runtime (imagem final)
FROM python:3.9-slim

WORKDIR /app

# Copia apenas as dependências instaladas do estágio builder
COPY --from=builder /root/.local /root/.local

# Ajusta PATH para encontrar os pacotes instalados
ENV PATH=/root/.local/bin:$PATH

# Copia a aplicação
COPY app.py .

# Expõe a porta
EXPOSE 8000

# Comando de execução
CMD ["python", "app.py"]