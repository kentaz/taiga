FROM ubuntu:20.04

# Avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    postgresql-client \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    libpq-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libxslt-dev \
    libssl-dev \
    libffi-dev \
    nodejs \
    npm \
    git \
    supervisor \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone specific Taiga versions that are compatible
WORKDIR /opt
RUN git clone -b 6.0.0 https://github.com/taigaio/taiga-back.git && \
    git clone -b 6.0.0 https://github.com/taigaio/taiga-front-dist.git

# Set up Python environment for backend with improved error handling
WORKDIR /opt/taiga-back
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install psycopg2-binary && \
    pip install -r requirements.txt || (echo "Full pip install failed, trying with --no-deps" && \
    pip install --no-deps -r requirements.txt && \
    pip install django-filter djangorestframework django-cors-headers)

# Set up Nginx configuration
COPY nginx.conf /etc/nginx/sites-available/taiga
RUN ln -s /etc/nginx/sites-available/taiga /etc/nginx/sites-enabled/taiga && \
    rm -f /etc/nginx/sites-enabled/default

# Create supervisord configuration
COPY supervisord.conf /etc/supervisor/conf.d/taiga.conf

# Copy config files
COPY local.py /opt/taiga-back/settings/local.py
COPY conf.json /opt/taiga-front-dist/dist/conf.json

# Entry script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
