

#DJANGO REST FRAMEWORK
CORS_ORIGIN_WHITELIST = tuple(os.environ.get('ALLOWED_HOST_REST').split(','))
INSTALLED_APPS.append('corsheaders')
INSTALLED_APPS.append('rest_framework')
MIDDLEWARE.append('corsheaders.middleware.CorsMiddleware')