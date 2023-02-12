FROM quay.io/keycloak/keycloak:20.0.1
COPY entrypoint.sh /entrypoint.sh
# RUN apk update && apk upgrade && apk --no-cache add sudo
# RUN sudo chmod +x /entrypoint.sh

# RUN chown root config/config.php
ENTRYPOINT ["/entrypoint.sh"]
# "/opt/keycloak/bin/kc.sh start-dev --import-realm --log-level=info --log=console,file --log-file=/logs/keycloak.log --hostname=auth.localdomain --hostname-strict-https=false"  