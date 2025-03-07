#!/bin/bash
set -e

cd /taiga

# Wait for database
until PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -c '\q' 2>/dev/null; do
  echo "Waiting for database to be available..."
  sleep 5
done

# Start Taiga
docker-compose up -d

# Keep container running to prevent Render from restarting
tail -f /dev/null
