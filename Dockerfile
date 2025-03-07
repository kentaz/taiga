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
    nodejs \
    npm \
    git \
    supervisor \
    curl

# Clone Taiga repositories
WORKDIR /opt
RUN git clone https://github.com/taigaio/taiga-back.git && \
    git clone https://github.com/taigaio/taiga-front-dist.git

# Set up Python environment for backend
WORKDIR /opt/taiga-back
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install -r requirements.txt

# Set up Nginx configuration
COPY nginx.conf /etc/nginx/sites-available/taiga
RUN ln -s /etc/nginx/sites-available/taiga /etc/nginx/sites-enabled/taiga && \
    rm /etc/nginx/sites-enabled/default

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
