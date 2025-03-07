from .common import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('POSTGRES_DB'),
        'USER': os.getenv('POSTGRES_USER'),
        'PASSWORD': os.getenv('POSTGRES_PASSWORD'),
        'HOST': os.getenv('POSTGRES_HOST'),
        'PORT': '5432',
    }
}

MEDIA_URL = "https://%s/media/" % os.getenv('TAIGA_SITES_DOMAIN')
STATIC_URL = "https://%s/static/" % os.getenv('TAIGA_SITES_DOMAIN')

SECRET_KEY = os.getenv('TAIGA_SECRET_KEY')
