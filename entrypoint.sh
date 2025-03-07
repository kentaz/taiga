#!/bin/bash
set -e

cd /taiga

echo "Checking environment..."
env | grep -E 'POSTGRES|TAIGA' | sort

echo "Starting Taiga in Render.com environment..."

# Modify the docker-compose.yml to use external database
cat > docker-compose.yml <<EOF
version: '3.5'

services:
  taiga-back:
    image: taigaio/taiga-back:6.0.0
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_HOST: ${POSTGRES_HOST}
      TAIGA_SECRET_KEY: "${TAIGA_SECRET_KEY}"
      TAIGA_SITES_DOMAIN: "${TAIGA_SITES_DOMAIN}"
      TAIGA_SITES_SCHEME: "${TAIGA_SITES_SCHEME}"
    ports:
      - 8000:8000

  taiga-front:
    image: taigaio/taiga-front:6.0.0
    environment:
      TAIGA_URL: "https://${TAIGA_SITES_DOMAIN}"
      TAIGA_WEBSOCKETS_URL: "wss://${TAIGA_SITES_DOMAIN}"
    ports:
      - 80:80

  taiga-events:
    image: taigaio/taiga-events:6.0.0
    environment:
      TAIGA_SECRET_KEY: "${TAIGA_SECRET_KEY}"
    ports:
      - 8888:8888

  taiga-gateway:
    image: taigaio/taiga-gateway:6.0.0
    ports:
      - 443:443
EOF

# Start Taiga services
docker-compose up -d

# Initialize the database if necessary
echo "Running database migrations..."
docker-compose exec -T taiga-back python manage.py migrate

echo "Taiga is now running!"

# Keep container running
tail -f /dev/null
