#!/bin/bash

while true; do
read -p """
CREATE PROJECT:
	* StencilJs (Ionic-Pwa) (New) (1)
	* StencilJs (Ionic-Pwa) (Exists) (2)

	Insert option: """ db 

case $db in
	"1")
		BASEDIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

		cd projects

		read -p '
GROUP (Leave blank to not insert in group): ' GROUP
		GROUP="${GROUP,,}"
		if [[ ! -z "$GROUP" ]]; then
			mkdir -p "$GROUP" && cd "$GROUP";
		fi

		read -p '
NAME OF PROJECT: ' NAME
		NAME="${NAME,,}"

		if [ ! -d 'projects/'$NAME'' ]; then
			npm init stencil ionic-pwa -y --name $NAME;cd $NAME

			mkdir nginx; cp $BASEDIR/starter-files/nginx-files/frontend/default.conf ./nginx/default.conf

			cp $BASEDIR/starter-files/docker-files/stenciljs/Dockerfile ./Dockerfile

	    	cp $BASEDIR/starter-files/services-files/stenciljs/base.yml ./docker-compose.yml
	    	cat $BASEDIR/starter-files/services-files/stenciljs/dev/stenciljs.yml >> ./docker-compose.yml
	    	
	    	while true; do
			read -p '
REVERSE PROXY WITH LETSENCRYPT (nginx or traefik): ' proxy
			
			read -p 'REVERSE PROXY HOST: ' REVERSE_PROXY_HOST

			case $proxy in
				"nginx")
					read -p 'REVERSE PROXY EMAIL: ' REVERSE_PROXY_EMAIL
					cp $BASEDIR/starter-files/services-files/stenciljs/base-nginx.yml ./docker-compose-prod.yml
	    			cat $BASEDIR/starter-files/services-files/stenciljs/prod/stenciljs-nginx.yml | sed 's/$NAME/'$NAME'/' | sed 's/$REVERSE_PROXY_EMAIL/'$REVERSE_PROXY_EMAIL'/' | sed 's/$REVERSE_PROXY_HOST/'$REVERSE_PROXY_HOST'/' >> ./docker-compose-prod.yml
				    break;
				;;
				"traefik")				
					cp $BASEDIR/starter-files/services-files/stenciljs/base-traefik.yml ./docker-compose-prod.yml
	    			cat $BASEDIR/starter-files/services-files/stenciljs/prod/stenciljs-traefik.yml | sed 's/$NAME/'$NAME'/' | sed 's/$REVERSE_PROXY_HOST/'$REVERSE_PROXY_HOST'/' >> ./docker-compose-prod.yml
				    break;
				;;
			esac
			done

			cp $BASEDIR/starter-files/shell-files/initial-docker-ubuntu16.04.sh ./initial-docker-ubuntu16.04.sh

	    else
	    	echo ''$NAME' Directory Exists.'
		fi
		

	    break;
	;;
	"2")
	    echo "Coming Soon."
	    break;
	;;
esac
done