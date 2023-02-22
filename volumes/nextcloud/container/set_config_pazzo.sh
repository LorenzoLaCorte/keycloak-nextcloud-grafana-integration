#!/bin/sh

# Wait until Keycloak is alive
until curl -sSf http://keycloak:8080; do
    sleep 1
done
echo 'Keycloak alive'

# -- Ensure that 2 replicas will not install nextcloud at the same time -- #

# let's do it with a lock
LOCK=/var/www/html/check_install.lock

# initialize a flag that will be set to 1 if another instance is installing
another_instance=0
# 3600-second timeout to the lock, so the script is executed if there is a stale lock
lockfile -r 0 -l 3600 "$LOCK" || another_instance=1

# ensure that whenever the script exits, remove_lock will be called
trap remove_lock EXIT

# check if I'm the first replica and so I need to install nextcloud
if [ $another_instance -eq 0 ]; do
    /entrypoint.sh apache2-foreground &
done

res=1
until [ $res -eq 0 ]; do
    sleep 1
    echo "Waiting nextcloud to be setup"
    sudo -u www-data ls /var/www/html/config/config.php
    res=$?
done
echo "Nextcloud setup done"

#
# Helper functions

# Nextcloud
runOCC() {
    sudo -E -u www-data php occ "$@"
}
setBoolean() { runOCC config:system:set --value="$2" --type=boolean -- "$1"; }
setInteger() { runOCC config:system:set --value="$2" --type=integer -- "$1"; }
setString() { runOCC config:system:set --value="$2" --type=string -- "$1"; }


# Wait until Nextcloud install is complete
until runOCC status --output json_pretty | grep 'installed' | grep -q 'true'; do
    sleep 1
    echo "Trying to verify if Nextcloud is ready..."
done
echo 'Nextcloud ready'

echo "Applying network settings..."

# Trusted domains
runOCC config:system:set trusted_domains 1 --value="cloud.localdomain"

# Enable logging
setString log_type file
setString logfile nextcloud.log
setString loglevel 1
setString logdateformat "F d, Y H:i:s"

# Install OpenID Connect login app on Nextcloud
runOCC app:install oidc_login

# Setup OpenID Connect login settings on Nextcloud
setBoolean allow_user_to_change_display_name false
setString lost_password_link disabled
setBoolean oidc_login_disable_registration false
setBoolean oidc_login_tls_verify false
setBoolean oidc_login_end_session_redirect true
setBoolean oidc_login_auto_redirect true
setBoolean oidc_login_redir_fallback true

setString oidc_login_provider_url "${OIDC_PROVIDER_URL}"
setString oidc_login_client_id "${OIDC_CLIENT_ID}"
setString oidc_login_client_secret "${OIDC_CLIENT_SECRET}"
setString oidc_login_logout_url "${OIDC_LOGOUT_URL}"

runOCC config:system:set --value=preferred_username --type=string -- oidc_login_attributes id
runOCC config:system:set --value=email --type=string -- oidc_login_attributes mail

tail -f /var/www/html/nextcloud.log