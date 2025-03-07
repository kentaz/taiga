FROM docker:20.10

# Install docker-compose and other tools
RUN apk add --no-cache py-pip bash git curl
RUN pip install docker-compose

# Clone the official Taiga docker repository
RUN git clone https://github.com/taigaio/taiga-docker.git /taiga

# Copy our configuration files
COPY config.env /taiga/.env
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /taiga

ENTRYPOINT ["/entrypoint.sh"]
