#!/bin/bash

while $(echo "from django.db import connections
from django.db.utils import OperationalError
db_conn = connections['default']
try:
    c = db_conn.cursor()
except OperationalError:
    connected = 'true'
else:
    connected = 'false'
print(connected)" | python manage.py shell); do
  >&2 echo "Database is unavailable - sleeping"
  sleep 5
done

>&2 echo "Database is up - executing command"

echo "[run] go to project folder"
cd /home/app/server

echo "[run] Migrate DB"
python manage.py migrate --noinput

if $DEBUG; then
   	echo "[norun] Collect static files"
else
	echo "[run] Collect static files"
	python manage.py collectstatic --noinput
fi

echo "[run] Fixtures"
python manage.py loaddata ./*/fixtures/*.json

echo "[run] create superuser"
echo "from django.contrib.auth.models import User
if not User.objects.filter(username='$ADMIN_USERNAME').count():
    User.objects.create_superuser('$ADMIN_USERNAME', '$ADMIN_USERNAME@example.com', '$ADMIN_PASSWORD')
" | python manage.py shell