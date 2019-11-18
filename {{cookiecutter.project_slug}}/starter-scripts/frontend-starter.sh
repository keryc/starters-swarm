#!/bin/bash

SERVICES_FILES='./starter-files/services-files/frontend'

FRONTEND='./frontend'

{% if cookiecutter.frontend == 'stenciljs' %}
	npm init stencil ionic-pwa -y --name frontend; mkdir $FRONTEND/nginx
{% elif cookiecutter.frontend == 'angular' %}
	sudo npm install -g @angular/cli;
	ng new frontend; mkdir $FRONTEND/nginx
	curl https://www.gitignore.io/api/angular > $FRONTEND/.gitignore
{% elif cookiecutter.frontend == 'react' %}
	npx create-react-app frontend; mkdir $FRONTEND/nginx
	curl https://www.gitignore.io/api/react > $FRONTEND/.gitignore
{% endif %}

cp ./starter-files/nginx-files/frontend/default.conf $FRONTEND/nginx/default.conf
cp ./starter-files/docker-files/{{ cookiecutter.frontend }}/Dockerfile $FRONTEND/Dockerfile

cat $SERVICES_FILES/dev/frontend.yml >> $FRONTEND/docker-compose.yml
cat $SERVICES_FILES/prod/frontend.yml >> $FRONTEND/docker-compose-prod.yml

cp ./starter-files/shell-files/initial-docker-ubuntu16.04.sh ./initial-docker-ubuntu16.04.sh
