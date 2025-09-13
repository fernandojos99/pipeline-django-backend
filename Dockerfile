# ---------------------------
# Stage 1: Builder
# ---------------------------
FROM python:3.11-slim AS builder

WORKDIR /app

# Instalar dependencias del sistema necesarias para instalar paquetes Python
RUN apt-get update && apt-get install -y --no-install-recommends gcc libffi-dev libssl-dev

# Copiar y instalar dependencias de Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt --prefix=/install

# Copiar todo el código del proyecto
COPY . .

# ---------------------------
# Stage 2: Runtime
# ---------------------------
FROM python:3.11-slim AS runtime

WORKDIR /app

# Copiar solo las dependencias instaladas en el stage builder
COPY --from=builder /install /usr/local

# Copiar solo el código de la app
COPY --from=builder /app /app

# Instalar supervisor (solo lo necesario para correrlo)
RUN apt-get update && apt-get install -y --no-install-recommends supervisor \
    && rm -rf /var/lib/apt/lists/*

# Copiar configuración de supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Exponer puerto (para Gunicorn)
EXPOSE 8000

# Ejecutar supervisord
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
