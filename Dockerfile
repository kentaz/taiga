FROM python:3.7-slim

# Avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    postgresql-client \
    build-essential \
    libpq-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libxslt-dev \
    libssl-dev \
    libffi-dev \
    git \
    supervisor \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone specific Taiga versions that are compatible
WORKDIR /opt
RUN git clone -b stable https://github.com/taigaio/taiga-back.git && \
    git clone -b stable https://github.com/taigaio/taiga-front-dist.git

# Set up Python environment with specific pip version
WORKDIR /opt/taiga-back
RUN pip install pip==20.3.4 && \
    pip install wheel setuptools && \
    pip install psycopg2-binary gunicorn && \
    pip install -r requirements.txt

# Set up Nginx configuration
COPY nginx.conf /etc/nginx/sites-available/taiga
RUN mkdir -p /etc/nginx/sites-enabled && \
    ln -s /etc/nginx/sites-available/taiga /etc/nginx/sites-enabled/taiga && \
    rm -f /etc/nginx/sites-enabled/default

# Create supervisord configuration
COPY supervisord.conf /etc/supervisor/conf.d/taiga.conf

# Copy config files
COPY local.py /opt/taiga-back/settings/local.py
COPY conf.json /opt/taiga-front-dist/dist/conf.json

# Create required directories
RUN mkdir -p /opt/taiga-back/media /opt/taiga-back/static

# Entry script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
