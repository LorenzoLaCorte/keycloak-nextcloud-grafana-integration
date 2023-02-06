FROM nextcloud:23.0-apache
COPY set_config.sh /set_config.sh
RUN apt update && apt install -y sudo && apt install -y nano
RUN chmod +x /set_config.sh

# RUN chown root config/config.php
ENTRYPOINT ["/set_config.sh"]