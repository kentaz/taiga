FROM docker:20.10

# Install dependencies with correct package names
RUN apk add --no-cache \
    bash \
    git \
    curl \
    python3 \
    py3-pip \
    libffi-dev \
    openssl-dev \
    gcc \
    libc-dev \
    make

# Install docker-compose using Python 3
RUN pip3 install --upgrade pip && \
    pip3 install docker-compose

# Clone the official Taiga docker repository
RUN git clone https://github.com/taigaio/taiga-docker.git /taiga

# Copy our configuration files
COPY config.env /taiga/.env
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /taiga

ENTRYPOINT ["/entrypoint.sh"]
