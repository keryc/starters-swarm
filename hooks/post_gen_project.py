import subprocess
import os
import shutil

PROJECT_DIRECTORY = os.path.realpath(os.path.curdir)

def remove_file(filepath):
    os.remove(os.path.join(PROJECT_DIRECTORY, filepath))

def remove_directory(filepath):
    shutil.rmtree(os.path.join(PROJECT_DIRECTORY, filepath))

cookiecutter_backend = '{{ cookiecutter.backend }}'
cookiecutter_frontend = '{{ cookiecutter.frontend }}'

if cookiecutter_frontend != 'ninguno':
	subprocess.call('chmod +x ./starter-scripts/frontend-starter.sh', shell=True)
	subprocess.call('sh ./starter-scripts/frontend-starter.sh', shell=True)

if cookiecutter_backend == 'django':
	subprocess.call('chmod +x ./starter-scripts/django-starter.sh', shell=True)
	subprocess.call('sh ./starter-scripts/django-starter.sh', shell=True)

if __name__ == '__main__':
	remove_file('Pipfile')
	remove_file('Pipfile.lock')
	remove_directory('starter-files')
	remove_directory('starter-scripts')
