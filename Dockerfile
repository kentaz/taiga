# Update to a newer Python version
FROM python:3.9-slim

# Keep your existing setup
ENV DEBIAN_FRONTEND=noninteractive

# Keep your existing apt packages
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

# Update this section - don't pin pip to an old version
WORKDIR /opt/taiga-back
RUN pip install --upgrade pip && \
    pip install wheel setuptools && \
    pip install psycopg2-binary gunicorn && \
    pip install -r requirements.txt

# Rest of your Dockerfile remains the same
...
