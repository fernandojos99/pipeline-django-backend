#!/bin/sh
set -e

echo "Running Django migrations..."
python manage.py migrate --noinput

# Solo cuando este en modo inicial (de preferencia solo una vez)
if [ "$LOAD_FIXTURES" = "true" ]; then
  echo "Loading initial data..."
  python manage.py loaddata datos.json
fi

echo "Starting supervisord..."
exec "$@"
