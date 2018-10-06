

#CELERY
INSTALLED_APPS.append('django_celery_results')
CELERY_BROKER_URL = os.environ.get('CELERY_BROKER_URL','')
CELERY_RESULT_BACKEND = 'django-db'