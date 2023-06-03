# Set the project name here
PROJECT_NAME = django-docker-base-template
# Set the backup folder here
BACKUP_FOLDER = backups

.PHONY: clone build run test shell up down backup

# Builds the Docker container image with Django
build:
	docker build -t $(PROJECT_NAME):master .

# Runs the Django development server inside the Django container
run:
	docker run -it --rm -p 8000:8000 -v sqlite:/sqlite -v ./project:/usr/src/project $(PROJECT_NAME):master python manage.py runserver 0.0.0.0:8000

# Runs tests for the Django project
test:
	docker run -it --rm $(PROJECT_NAME):master python manage.py test 

# Starts an interactive shell with the Django project environment
shell:
	docker run -it --rm -v sqlite:/sqlite $(PROJECT_NAME):master python manage.py shell

# Starts all services locally (Postgres, Gunicorn, Traefik) using docker-compose
up:
	docker compose -f docker-compose.debug.yml up

# Stops all containers, removes them and their images. To delete the Postgre database as well, add the `-v` flag to the command
down:
	docker compose down --remove-orphans --rmi local

# Backs up the Postgres database to a folder
# You will need to replace [backup_folder] with the path to the folder where you want to store the backup.
# For example, if you want to store the backup in a folder named backups, you can use the following command:
# backup:
# 	docker exec $(PROJECT_NAME)_postgres_1 pg_dumpall -c -U postgres > backups/dump_`date +%d-%m-%Y"_"%H_%M_%S`.sql
# To run this command, you can use make backup. This will create a backup of the Postgres database and save it to the specified folder with a timestamped filename.
backup:
	docker exec $(PROJECT_NAME)_postgres_1 pg_dumpall -c -U postgres > $(BACKUP_FOLDER)/dump_`date +%d-%m-%Y"_"%H_%M_%S`.sql
