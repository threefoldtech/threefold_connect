FROM node:22 AS frontend-builder

COPY frontend /frontend
WORKDIR /frontend
RUN yarn install --frozen-lockfile && yarn build


FROM python:3.11-alpine AS backend-builder

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    POETRY_VERSION=1.8.3 \
    POETRY_HOME="/opt/poetry" \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_VIRTUALENVS_CREATE=true

RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    python3-dev \
    linux-headers \
    curl \
    make

RUN curl -sSL https://install.python-poetry.org | python3 -

ENV PATH="$POETRY_HOME/bin:$PATH"

WORKDIR /app
COPY backend/pyproject.toml backend/poetry.lock* ./

RUN poetry install --only main --no-root --no-directory

COPY backend/ ./

RUN poetry install --only main


FROM nginx:1.27-alpine AS runtime

RUN apk add --no-cache \
    libffi \
    openssl \
    libgcc \
    libstdc++ \
    sqlite-libs

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    VIRTUAL_ENV=/app/.venv \
    PATH="/usr/local/bin:/app/.venv/bin:$PATH" \
    LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

COPY --from=backend-builder /usr/local/bin/python3.11 /usr/local/bin/python3.11
COPY --from=backend-builder /usr/local/bin/python3 /usr/local/bin/python3
COPY --from=backend-builder /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=backend-builder /usr/local/lib/libpython3.11.so.1.0 /usr/local/lib/libpython3.11.so.1.0
COPY --from=backend-builder /usr/local/lib/libpython3.so /usr/local/lib/libpython3.so

COPY --from=backend-builder /app/.venv /app/.venv
COPY --from=backend-builder /app /usr/share/nginx/backend
COPY --from=frontend-builder /frontend/dist /var/www/html/frontend

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY services.sh /services.sh
RUN chmod +x /services.sh

WORKDIR /usr/share/nginx/backend/

EXPOSE 5000

CMD ["/services.sh"]
