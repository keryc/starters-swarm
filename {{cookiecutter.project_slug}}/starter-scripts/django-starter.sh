#!/bin/bash

SERVICES_FILES='./starter-files/services-files/django'
CONFIG_FILES='./starter-files/config-files/django'

BACKEND='./backend'

pip3 install pipenv
pipenv install django gunicorn

pipenv run django-admin startproject backend; mkdir $BACKEND/nginx
pipenv run pip freeze > $BACKEND/requirements.txt

curl https://www.gitignore.io/api/django > $BACKEND/.gitignore

cat ./starter-files/nginx-files/backend/default.conf  >> $BACKEND/nginx/default.conf 

cp ./starter-files/docker-files/django/Dockerfile $BACKEND/Dockerfile


read -p 'ADMIN (USERNAME): ' ADMIN_USERNAME
read -p 'ADMIN (PASSWORD): ' ADMIN_PASSWORD
cat ./starter-files/shell-files/django/entrypoint.sh | sed 's/$ADMIN_USERNAME/'$ADMIN_USERNAME'/g' | sed 's/$ADMIN_PASSWORD/'$ADMIN_PASSWORD'/g' >> $BACKEND/entrypoint.sh
chmod +x $BACKEND/entrypoint.sh
			
cp ./starter-files/shell-files/wait-for-it.sh $BACKEND/wait-for-it.sh
			
cat $SERVICES_FILES/server-dev.env >> $BACKEND/server-dev.env
cat $SERVICES_FILES/server-prod.env >> $BACKEND/server-prod.env

cat $SERVICES_FILES/dev/base.yml >> $BACKEND/docker-compose.yml
cat $SERVICES_FILES/prod/base.yml >> $BACKEND/docker-compose-prod.yml

# Split django configuration into states
mkdir $BACKEND/backend/settings
touch $BACKEND/backend/settings/__init__.py
cp $BACKEND/backend/settings.py $BACKEND/backend/settings/base.py
sudo rm $BACKEND/backend/settings.py


#Creation basic config developer and production
cat $CONFIG_FILES/base.py >> $BACKEND/backend/settings/development.py
cat $CONFIG_FILES/base.py >> $BACKEND/backend/settings/production.py

cat $CONFIG_FILES/dev/staticfiles.py >> $BACKEND/backend/settings/development.py
cat $CONFIG_FILES/prod/staticfiles.py >> $BACKEND/backend/settings/production.py

mkdir $BACKEND/media; touch $BACKEND/media/.gitkeep
mkdir $BACKEND/static; touch $BACKEND/static/.gitkeep

echo "**************************************"
while true; do
read -p 'ADD DATABASE (postgresql or mysql): ' db

case $db in
	"postgresql")
		cat $SERVICES_FILES/dev/postgres.yml >> $BACKEND/docker-compose.yml
		cat $SERVICES_FILES/prod/postgres.yml >> $BACKEND/docker-compose-prod.yml

		cat $SERVICES_FILES/dev/django.yml >> $BACKEND/docker-compose.yml
	   	cat $SERVICES_FILES/prod/django.yml >> $BACKEND/docker-compose-prod.yml
	    			
	    echo "install psycopg2..."
	    pipenv install psycopg2-binary
				    
	    echo "config databases in settings..."
		cat $CONFIG_FILES/database-postgres.py >> $BACKEND/backend/settings/development.py
		cat $CONFIG_FILES/database-postgres.py >> $BACKEND/backend/settings/production.py

		pipenv run pip freeze > $BACKEND/requirements.txt
	    break;
	;;
	"mysql")				
		cat $SERVICES_FILES/dev/mysql.yml >> $BACKEND/docker-compose.yml
		cat $SERVICES_FILES/prod/mysql.yml >> $BACKEND/docker-compose-prod.yml
					
		cat $SERVICES_FILES/dev/django.yml >> $BACKEND/docker-compose.yml
	   	cat $SERVICES_FILES/prod/django.yml >> $BACKEND/docker-compose-prod.yml
				    
	    echo "install mysqlclient..."
	    sudo apt-get install libmysqlclient-dev
	    pipenv install mysqlclient

	    echo "config databases in settings..."
		cat $CONFIG_FILES/database-mysql.py >> $BACKEND/backend/settings/development.py
		cat $CONFIG_FILES/database-mysql.py >> $BACKEND/backend/settings/production.py

		pipenv run pip freeze > $BACKEND/requirements.txt
		break;
	;;
esac
done
echo "**************************************"
while true; do
read -p 'ADD DJANGO REST FRAMEWORK (y/N): ' drf

case $drf in
	[yY][eE][sS]|[yY])
	    echo "install djangorestframework..."
	    pipenv install djangorestframework
	    pipenv install django-cors-headers

	    echo "add 'rest_framework' and 'corsheaders' to your INSTALLED_APPS setting..."
		cat $CONFIG_FILES/djangorestframework.py >> $BACKEND/backend/settings/development.py
		cat $CONFIG_FILES/djangorestframework.py >> $BACKEND/backend/settings/production.py

		pipenv run pip freeze > $BACKEND/requirements.txt
	    break;
	;;
	[nN])
	    break;
	;;
esac
done
echo "**************************************"
while true; do
read -p 'ADD CELERY (y/N): ' drf

case $drf in
	[yY][eE][sS]|[yY])
	    echo "install celery and django-celery-results..."
	    pipenv install celery
	    pipenv install django-celery-results

	    cat $CONFIG_FILES/celeryconfig.py >> $BACKEND/backend/settings/development.py
		cat $CONFIG_FILES/celeryconfig.py >> $BACKEND/backend/settings/production.py

		cat $CONFIG_FILES/celeryinit.py >> $BACKEND/backend/__init__.py

		cat $CONFIG_FILES/celeryfile.py >> $BACKEND/backend/celery.py   

	    pipenv run pip freeze > $BACKEND/requirements.txt

	    echo "add service 'celery_worker' to docker-compose.yml"
		cat $SERVICES_FILES/dev/rabbitmq.yml >> $BACKEND/docker-compose.yml
		cat $SERVICES_FILES/prod/rabbitmq.yml >> $BACKEND/docker-compose-prod.yml
					
		cat $SERVICES_FILES/dev/celery_worker.yml >> $BACKEND/docker-compose.yml
		cat $SERVICES_FILES/prod/celery_worker.yml >> $BACKEND/docker-compose-prod.yml
					
		curl https://www.gitignore.io/api/django,node > $BACKEND/.gitignore

	    break;
	;;
	[nN])
	    break;
	;;
esac
done
echo "**************************************"
while true; do
read -p 'ADD CELERY BEAT (y/N): ' drf

case $drf in
	[yY][eE][sS]|[yY])
	    echo "install django-celery-beat..."
	    pipenv install django-celery-beat
	    echo "creating dockerignore..."
		echo "celerybeat.pid" >> $BACKEND/.dockerignore
		echo "add 'django_celery_results' to your INSTALLED_APPS setting..."
					
		cat $CONFIG_FILES/celerybeatconfig.py >> $BACKEND/backend/settings/development.py
		cat $CONFIG_FILES/celerybeatconfig.py >> $BACKEND/backend/settings/production.py

		pipenv run pip freeze > $BACKEND/requirements.txt

		echo "add service 'celery_worker' to docker-compose.yml"
		cat $SERVICES_FILES/dev/celery_beat.yml >> $BACKEND/docker-compose.yml
		cat $SERVICES_FILES/prod/celery_beat.yml >> $BACKEND/docker-compose-prod.yml
					
	    break;
	;;
	[nN])
	    break;
	;;
esac
done
			
cp ./starter-files/shell-files/initial-docker-ubuntu16.04.sh ./initial-docker-ubuntu16.04.sh
