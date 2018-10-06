#!/bin/bash

while true; do
read -p """
CREATE PROJECT:
	* Django (New)(1)
	* Django (Exists)(2)

	Insert option: """ db 

case $db in
	"1")

		read -p '
NAME OF PROJECT: ' NAME

		if [ ! -d $NAME ]; then
			read -p '
ADMIN (USERNAME): ' ADMIN_USERNAME

			read -p '
ADMIN (PASSWORD): ' ADMIN_PASSWORD

			while true; do
			read -p '
ADD LETSENCRYPT AUTOMATIC (y/N): ' drf

			case $drf in
				[yY][eE][sS]|[yY])
				    LETSENCRYPT="yes"
				    read -p 'LETSENCRYPT_EMAIL: ' LETSENCRYPT_EMAIL
					read -p 'LETSENCRYPT_HOST: ' LETSENCRYPT_HOST
					while true; do
						read -p 'LETSENCRYPT TEST  (y/N): ' drf

						case $drf in
							[yY][eE][sS]|[yY])
								LETSENCRYPT_TEST="true"
							    break;
							;;
							[nN])
								LETSENCRYPT_TEST="false"
							    break;
							;;
					esac
					done
				    break;
				;;
				[nN])
					LETSENCRYPT="no"
				    break;
				;;
			esac
			done

			#Install virtualenv and install django, gunicorn
			sudo pip install virtualenv
			cd projects; virtualenv -p python3 temp-env
			source temp-env/bin/activate
			pip install django gunicorn

			#Create project django and copy backups files important!
			django-admin startproject $NAME
			cd $NAME; pip freeze > requirements.txt

			mkdir nginx; cat ../../starter-files/nginx-files/backend/default.conf | sed 's/$NAME/'$NAME'/g' >> ./nginx/default.conf 

			cp ../../starter-files/docker-files/django/Dockerfile ./Dockerfile



			cat ../../starter-files/shell-files/django/entrypoint.sh | sed 's/$ADMIN_USERNAME/'$ADMIN_USERNAME'/g' | sed 's/$ADMIN_PASSWORD/'$ADMIN_PASSWORD'/g' >> ./entrypoint.sh
			chmod +x ./entrypoint.sh
			
			cp ../../starter-files/shell-files/django/wait-for-it.sh ./wait-for-it.sh


	    	cp ../../starter-files/services-files/django/dev/base.yml ./docker-compose-dev.yml

	    	if [ $LETSENCRYPT == 'yes' ];then
	    		cp ../../starter-files/services-files/django/prod/base-letsencrypt.yml ./docker-compose-prod.yml
	    		cat ../../starter-files/services-files/django/prod/nginx-letsencrypt.yml | sed 's/$NAME/'$NAME'/g' | sed 's/$LETSENCRYPT_EMAIL/'$LETSENCRYPT_EMAIL'/' | sed 's/$LETSENCRYPT_HOST/'$LETSENCRYPT_HOST'/' | sed 's/$LETSENCRYPT_TEST/'$LETSENCRYPT_TEST'/' >> ./docker-compose-prod.yml
			else
				cp ../../starter-files/services-files/django/prod/base.yml ./docker-compose-prod.yml
				cat ../../starter-files/services-files/django/prod/nginx.yml | sed 's/$NAME/'$NAME'/g' >> ./docker-compose-prod.yml
			fi

	    	cat ../../starter-files/services-files/django/server-dev.env | sed 's/$NAME/'$NAME'/g' >> ./server-dev.env
	    	cat ../../starter-files/services-files/django/server-prod.env | sed 's/$NAME/'$NAME'/g' >> ./server-prod.env


	    	# Split django configuration into states
			mkdir $NAME/settings
			touch $NAME/settings/__init__.py
			cp $NAME/settings.py $NAME/settings/base.py
			sudo rm $NAME/settings.py


			#Creation basic config developer and production
			cat ../../starter-files/config-files/django/base.py >> $NAME/settings/development.py
			cat ../../starter-files/config-files/django/base.py >> $NAME/settings/production.py

			cat ../../starter-files/config-files/django/dev/staticfiles.py >> $NAME/settings/development.py
			cat ../../starter-files/config-files/django/prod/staticfiles.py >> $NAME/settings/production.py

			mkdir ./media; touch ./media/.gitkeep
			mkdir ./static; touch ./static/.gitkeep

			echo "**************************************"
			while true; do
			read -p 'ADD DATABASE (postgres or mysql): ' db

			case $db in
				"postgres")
					cat ../../starter-files/services-files/django/dev/postgres.yml | sed 's/$NAME/'$NAME'/g' >> ./docker-compose-dev.yml
					cat ../../starter-files/services-files/django/prod/postgres.yml | sed 's/$NAME/'$NAME'/g' >> ./docker-compose-prod.yml

					cat ../../starter-files/services-files/django/dev/django.yml | sed 's/$NAME/'$NAME'/g' >> ./docker-compose-dev.yml
	    			cat ../../starter-files/services-files/django/prod/django.yml | sed 's/$NAME/'$NAME'/g' >> ./docker-compose-prod.yml



				    echo "install psycopg2..."
				    pip install psycopg2
				    
				    echo "config databases in settings..."
					cat ../../starter-files/config-files/django/database-postgres.py >> $NAME/settings/development.py
					cat ../../starter-files/config-files/django/database-postgres.py >> $NAME/settings/production.py

					pip freeze > requirements.txt
				    break;
				;;
				"mysql")				
					cat ../../starter-files/services-files/django/dev/mysql.yml | sed 's/$NAME/'$NAME'/g' >> ./docker-compose-dev.yml
					cat ../../starter-files/services-files/django/prod/mysql.yml | sed 's/$NAME/'$NAME'/g' >> ./docker-compose-prod.yml

					cat ../../starter-files/services-files/django/dev/django.yml | sed 's/$NAME/'$NAME'/g' >> ./docker-compose-dev.yml
	    			cat ../../starter-files/services-files/django/prod/django.yml | sed 's/$NAME/'$NAME'/g' >> ./docker-compose-prod.yml
				    
				    echo "install mysqlclient..."
				    sudo apt-get install libmysqlclient-dev
				    pip install mysqlclient

				    echo "config databases in settings..."
					cat ../../starter-files/config-files/django/database-mysql.py >> $NAME/settings/development.py
					cat ../../starter-files/config-files/django/database-mysql.py >> $NAME/settings/production.py

					pip freeze > requirements.txt
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
				    pip install djangorestframework
				    pip install django-cors-headers

				    echo "add 'rest_framework' and 'corsheaders' to your INSTALLED_APPS setting..."
					cat ../../starter-files/config-files/django/djangorestframework.py >> $NAME/settings/development.py
					cat ../../starter-files/config-files/django/djangorestframework.py >> $NAME/settings/production.py

					pip freeze > requirements.txt
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
				    pip install celery
				    pip install django-celery-results

				    cat ../../starter-files/config-files/django/celeryconfig.py >> $NAME/settings/development.py
					cat ../../starter-files/config-files/django/celeryconfig.py >> $NAME/settings/production.py

					cat ../../starter-files/config-files/django/celeryinit.py >> $NAME/__init__.py

					cat ../../starter-files/config-files/django/celeryfile.py | sed 's/$NAME/'$NAME'/g' >> $NAME/celery.py   

				    pip freeze > requirements.txt

				    echo "add service 'celery_worker' to docker-compose-dev.yml"
					cat ../../starter-files/services-files/django/dev/rabbitmq.yml | sed 's/$NAME/'$NAME'/g' >> ./docker-compose-dev.yml
					cat ../../starter-files/services-files/django/prod/rabbitmq.yml | sed 's/$NAME/'$NAME'/g' >> ./docker-compose-prod.yml


					cat ../../starter-files/services-files/django/dev/celery_worker.yml | sed 's/$NAME/'$NAME'/g' >> ./docker-compose-dev.yml
					cat ../../starter-files/services-files/django/prod/celery_worker.yml | sed 's/$NAME/'$NAME'/g' >> ./docker-compose-prod.yml

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
				    pip install django-celery-beat
				    echo "creating dockerignore..."
					echo "celerybeat.pid" >> ./.dockerignore
					echo "add 'django_celery_results' to your INSTALLED_APPS setting..."
					
					cat ../../starter-files/config-files/django/celerybeatconfig.py >> $NAME/settings/development.py
					cat ../../starter-files/config-files/django/celerybeatconfig.py >> $NAME/settings/production.py

					pip freeze > requirements.txt

					echo "add service 'celery_worker' to docker-compose-dev.yml"
					cat ../../starter-files/services-files/django/dev/celery_beat.yml | sed 's/$NAME/'$NAME'/g' >> ./docker-compose-dev.yml
					cat ../../starter-files/services-files/django/prod/celery_beat.yml | sed 's/$NAME/'$NAME'/g' >> ./docker-compose-prod.yml
				    break;
				;;
				[nN])
				    break;
				;;
			esac
			done

			cd ../../projects/;sudo rm -R temp-env

	    else
	    	echo "Django Directory Exists."	
		fi
		

	    break;
	;;
	"2")
	    echo "Coming Soon."
	    break;
	;;
esac
done