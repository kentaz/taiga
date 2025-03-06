FROM taigaio/taiga:6.0.0

COPY docker-compose.yml /taiga/docker-compose.yml

# Entry point script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
