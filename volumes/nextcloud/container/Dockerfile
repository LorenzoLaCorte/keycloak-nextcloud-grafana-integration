FROM nextcloud:23.0-apache
COPY set_config.sh /set_config.sh
COPY test.sh /test.sh
RUN apt update && apt install -y sudo && apt install -y nano && apt install -y procmail
RUN chmod +x /set_config.sh
RUN chmod +x /test.sh

# RUN chown root config/config.php
ENTRYPOINT ["/set_config.sh"]