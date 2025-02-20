FROM python:3.11-alpine as base

FROM base as builder

RUN apk update && apk --no-cache add python3-dev libpq-dev && mkdir /install
WORKDIR /install
COPY requirements.txt ./
RUN pip install --no-cache-dir --prefix=/install -r ./requirements.txt

FROM base

ARG USER=user
ARG USER_UID=1001
ARG PROJECT_NAME=project
ARG GUNICORN_PORT=8000
ARG GUNICORN_WORKERS=2
# the value is in seconds
ARG GUNICORN_TIMEOUT=60
ARG GUNICORN_LOG_LEVEL=error
ARG DJANGO_BASE_DIR=/usr/src/$PROJECT_NAME
ARG DJANGO_STATIC_ROOT=/var/www/static
ARG DJANGO_MEDIA_ROOT=/var/www/media
ARG DJANGO_SQLITE_DIR=/sqlite
# The superuser with the data below will be created only if there are no users in the database!
ARG DJANGO_SUPERUSER_USERNAME=admin
ARG DJANGO_SUPERUSER_PASSWORD=admin
ARG DJANGO_SUPERUSER_EMAIL=admin@example.com


ENV \
	USER=$USER \
	USER_UID=$USER_UID \
	PROJECT_NAME=$PROJECT_NAME \
	GUNICORN_PORT=$GUNICORN_PORT \
	GUNICORN_WORKERS=$GUNICORN_WORKERS \
	GUNICORN_TIMEOUT=$GUNICORN_TIMEOUT \
	GUNICORN_LOG_LEVEL=$GUNICORN_LOG_LEVEL \
	DJANGO_BASE_DIR=$DJANGO_BASE_DIR \
	DJANGO_STATIC_ROOT=$DJANGO_STATIC_ROOT \
	DJANGO_MEDIA_ROOT=$DJANGO_MEDIA_ROOT \
	DJANGO_SQLITE_DIR=$DJANGO_SQLITE_DIR \
	DJANGO_SUPERUSER_USERNAME=$DJANGO_SUPERUSER_USERNAME \
	DJANGO_SUPERUSER_PASSWORD=$DJANGO_SUPERUSER_PASSWORD \
	DJANGO_SUPERUSER_EMAIL=$DJANGO_SUPERUSER_EMAIL


COPY --from=builder /install /usr/local
COPY docker-entrypoint.sh /
COPY docker-cmd.sh /
COPY $PROJECT_NAME $DJANGO_BASE_DIR

# User
RUN chmod +x /docker-entrypoint.sh /docker-cmd.sh && \
	apk --no-cache add su-exec libpq-dev && \
	mkdir -p $DJANGO_STATIC_ROOT $DJANGO_MEDIA_ROOT $DJANGO_SQLITE_DIR && \
	adduser -s /bin/sh -D -u $USER_UID $USER && \
	chown -R $USER:$USER $DJANGO_BASE_DIR $DJANGO_STATIC_ROOT $DJANGO_MEDIA_ROOT $DJANGO_SQLITE_DIR

WORKDIR $DJANGO_BASE_DIR
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/docker-cmd.sh"]

EXPOSE $GUNICORN_PORT
