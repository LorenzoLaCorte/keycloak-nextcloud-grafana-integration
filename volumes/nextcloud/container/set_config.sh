#!/bin/sh

/entrypoint.sh apache2-foreground &
until [ ! -f "/var/www/html/config" ]; do
    sleep 1
    echo "Waiting nextcloud to be setup"
done
echo "Nextcloud setup done"

chown root config/config.php

NEXTCLOUD_CONTAINER_NAME=VCC_stack_nextcloud
KEYCLOAK_CONTAINER_NAME=VCC_stack_keycloak
KEYCLOAK_ADMIN_USER=admin
KEYCLOAK_ADMIN_PASSWORD=admin
SAMPLE_USER_PASSWORD=itsdifficult
OIDC_CLIENT_ID=nextcloud 
OIDC_PROVIDER_URL=https://auth.localdomain/realms/vcc/
OIDC_LOGOUT_URL=https://auth.localdomain/apps/oidc_login/oidc
OIDC_CLIENT_SECRET=pippo

#
# Helper functions

# Nextcloud
runOCC() {
    php /var/www/html/occ "$@"
}
setBoolean() { runOCC config:system:set --value="$2" --type=boolean -- "$1"; }
setInteger() { runOCC config:system:set --value="$2" --type=integer -- "$1"; }
setString() { runOCC config:system:set --value="$2" --type=string -- "$1"; }

# Wait until Keycloak is alive
until curl -sSf http://keycloak:8080; do
    sleep 1
done
echo 'Keycloak alive'

# Wait until Nextcloud install is complete
until runOCC status --output json_pretty | grep 'installed' | grep -q 'true'; do
# until [ ! -f "/var/www/html/config" ]; do
    sleep 1
done
echo 'Nextcloud ready'

# trusted domains
echo "Applying network settings..."
setBoolean config_is_read_only false

runOCC config:system:set trusted_domains 1 --value="192.168.50.10"
runOCC config:system:set trusted_domains 2 --value="cloud.localdomain"

setString log_type file
setString logfile nextcloud.log
setString loglevel 0 
setString logdateformat "F d, Y H:i:s"

# Install OpenID Connect login app on Nextcloud
runOCC app:install oidc_login

# Setup OpenID Connect login settings on Nextcloud
setBoolean allow_user_to_change_display_name false
setString lost_password_link disabled
setBoolean oidc_login_disable_registration false

setString oidc_login_provider_url "${OIDC_PROVIDER_URL}"
setString oidc_login_client_id "${OIDC_CLIENT_ID}"
setString oidc_login_client_secret "${OIDC_CLIENT_SECRET}"
setBoolean oidc_login_end_session_redirect true
setString oidc_login_logout_url "${OIDC_LOGOUT_URL}"
setBoolean oidc_login_auto_redirect true
setBoolean oidc_login_redir_fallback true

setString overwriteprotocol "https"
setString overwritehost "cloud.localdomain"
setString overwrite.cli.url "https://cloud.localdomain"

runOCC config:system:set --value=preferred_username --type=string -- oidc_login_attributes id
runOCC config:system:set --value=email --type=string -- oidc_login_attributes mail
setBoolean config_is_read_only true

chown www-data config/config.php
until [ -f "/var/www/html/config" ]; do
    sleep 1
done