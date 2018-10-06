FROM python:3-onbuild

ENV APP_NAME "server"
ENV APP_USER "app"
ENV HOME /home/$APP_USER
ENV APP_DIR $HOME/$APP_NAME

WORKDIR $APP_DIR
COPY requirements.txt $APP_DIR/requirements.txt

COPY . $APP_DIR

WORKDIR $APP_DIR

RUN chmod +x /home/app/server/entrypoint.sh
EXPOSE 8000