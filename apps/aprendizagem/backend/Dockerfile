# Dockerfile multi-stage para produção otimizada
FROM python:3.11-slim as builder

# Instala dependências do sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Configura ambiente Python
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# Cria diretório da aplicação
WORKDIR /app

# Copia arquivos de dependências
COPY pyproject.toml ./
COPY requirements.txt* ./

# Instala dependências
RUN pip install --upgrade pip
RUN pip install -e .

# === Stage final ===
FROM python:3.11-slim

# Instala apenas dependências runtime
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Cria usuário não-root
RUN useradd --create-home --shell /bin/bash appuser

# Cria diretório da aplicação
WORKDIR /app

# Copia dependências instaladas
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copia código da aplicação
COPY app/ ./app/
COPY tests/ ./tests/

# Configuração de ambiente
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONPATH="/app"

# Muda para usuário não-root
RUN chown -R appuser:appuser /app
USER appuser

# Expõe porta
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/v1/health || exit 1

# Comando de inicialização
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]