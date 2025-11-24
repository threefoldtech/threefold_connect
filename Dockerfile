FROM node:16 AS builder

COPY frontend /frontend
WORKDIR /frontend
RUN yarn install --frozen-lockfile && yarn build

# COPY example /example
# WORKDIR /example
# RUN yarn install --frozen-lockfile && yarn build

COPY wizard /wizard
WORKDIR /wizard
RUN yarn install --frozen-lockfile && yarn build


FROM nginx:1.25
COPY backend/requirements.txt requirements.txt

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    gcc \
    libssl-dev \
    python3-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install --break-system-packages uwsgi==2.0.26
RUN pip3 install --break-system-packages --upgrade pip
# Install stellar-sdk first to get compatible yarl version
RUN pip3 install --break-system-packages stellar-sdk==9.1.0
# Increase timeout and retries for slow network connections
RUN pip3 install --break-system-packages \
    --default-timeout=100 \
    --retries=5 \
    -r requirements.txt --ignore-installed

COPY --from=builder /frontend/dist /var/www/html/frontend
# COPY --from=builder /example/dist /var/www/html/example
COPY --from=builder /wizard/dist /var/www/html/wizard

COPY backend/ /usr/share/nginx/backend

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY services.sh /services.sh
RUN chmod +x /services.sh
WORKDIR /usr/share/nginx/backend/

CMD ["/services.sh"]
