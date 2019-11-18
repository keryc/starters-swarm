from .base import * 

DEBUG = False if os.environ.get('DEBUG', 'true') == 'false' else True

ALLOWED_HOSTS = os.environ.get('ALLOWED_HOST').split(',')

MEDIA_ROOT = 'media/'
MEDIA_URL = '/media/'