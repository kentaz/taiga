#!/bin/bash
set -e

# First-time setup
if [ ! -f "/data/setup_done" ]; then
  echo "Running first-time setup..."
  
  # Wait for database
  until PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -c '\q'; do
    echo "Waiting for database..."
    sleep 5
  done
  
  # Initialize database
  docker-compose exec -T taiga-back python manage.py migrate
  docker-compose exec -T taiga-back python manage.py loaddata initial_project_templates
  docker-compose exec -T taiga-back python manage.py loaddata initial_user
  
  # Create admin user
  docker-compose exec -T taiga-back python manage.py createsuperuser --username=admin --email=admin@example.com --noinput
  docker-compose exec -T taiga-back python manage.py changepassword admin << EOF
admin123
admin123
EOF
  
  # Mark setup as done
  touch /data/setup_done
fi

# Start Taiga
docker-compose up
