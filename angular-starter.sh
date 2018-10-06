#!/bin/bash

while true; do
read -p """
CREATE PROJECT:
	* Angular.Io (New)(1)
	* Angular.Io (Exists)(2)

	Insert option: """ db 

case $db in
	"1")
		read -p '
NAME OF PROJECT: ' NAME

		if [ ! -d $NAME ]; then
			
			while true; do
			read -p 'ADD LETSENCRYPT AUTOMATIC (y/N): ' drf

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

			sudo npm install -g @angular/cli
			cd projects; ng new $NAME; cd $NAME

			mkdir nginx; cp ../../starter-files/nginx-files/frontend/default.conf ./nginx/default.conf

			cp ../../starter-files/docker-files/angular/Dockerfile ./Dockerfile
			
			cp ../../starter-files/services-files/angular/base.yml ./docker-compose-dev.yml
	    	
	    	cat ../../starter-files/services-files/angular/dev/angular.yml | sed 's/$NAME/'$NAME'/' >> ./docker-compose-dev.yml

	    	cp ../../starter-files/services-files/angular/base.yml ./docker-compose-prod.yml
	    	cat ../../starter-files/services-files/angular/prod/angular.yml | sed 's/$NAME/'$NAME'/' >> ./docker-compose-prod.yml

			if [ $LETSENCRYPT == 'yes' ];then
	    		cp ../../starter-files/services-files/angular/base-letsencrypt.yml ./docker-compose-prod-letsencrypt.yml
	    		cat ../../starter-files/services-files/angular/prod/angular-letsencrypt.yml | sed 's/$NAME/'$NAME'/' | sed 's/$LETSENCRYPT_EMAIL/'$LETSENCRYPT_EMAIL'/' | sed 's/$LETSENCRYPT_HOST/'$LETSENCRYPT_HOST'/' | sed 's/$LETSENCRYPT_TEST/'$LETSENCRYPT_TEST'/' >> ./docker-compose-prod-letsencrypt.yml	
			fi

	    else
	    	echo "$NAME Directory Exists."	
		fi
		

	    break;
	;;
	"2")
	    echo "Coming Soon."
	    break;
	;;
esac
done