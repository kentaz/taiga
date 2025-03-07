#!/bin/bash
set -e

# Update conf.json with actual domain
sed -i "s/TAIGA_SITES_DOMAIN/${TAIGA_SITES_DOMAIN}/g" /opt/taiga-front-dist/dist/conf.json

# Wait for database
until PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -c '\q' 2>/dev/null; do
  echo "Waiting for database to be available..."
  sleep 5
done

# Run migrations
cd /opt/taiga-back
source venv/bin/activate
python manage.py migrate
python manage.py collectstatic --noinput

# Create admin user if it doesn't exist
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'admin') if not User.objects.filter(username='admin').exists() else None" | python manage.py shell

# Start all services using supervisord
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
