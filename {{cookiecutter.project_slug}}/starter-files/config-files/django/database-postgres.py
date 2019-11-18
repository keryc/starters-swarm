

#DATABASE
DATABASES = {
	'default': {
		'ENGINE': 'django.db.backends.postgresql_psycopg2',
		'NAME': os.environ.get('DB_NAME', ''),
		'USER': os.environ.get('DB_USER', ''),
		'PASSWORD': os.environ.get('DB_PASS', ''),
		'HOST': os.environ.get('DB_HOST', ''),
		'PORT': 5432,
	}
}