FROM docker/compose:1.29.2

# Install additional tools
RUN apk add --no-cache bash git curl postgresql-client

# Clone the official Taiga docker repository
RUN git clone https://github.com/taigaio/taiga-docker.git /taiga

# Copy our configuration files
COPY config.env /taiga/.env
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /taiga

ENTRYPOINT ["/entrypoint.sh"]
