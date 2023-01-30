#!/bin/sh
#
# Helper functions
#
# Nextcloud
runOCC() {
    NEXTCLOUD_ID=$(docker ps | grep "$NEXTCLOUD_CONTAINER_NAME" | awk '{print $1}')
    docker exec -i -u www-data "$NEXTCLOUD_ID" php occ "$@"
}
setBoolean() { runOCC config:system:set --value="$2" --type=boolean -- "$1"; }
setInteger() { runOCC config:system:set --value="$2" --type=integer -- "$1"; }
setString() { runOCC config:system:set --value="$2" --type=string -- "$1"; }

# Wait until Nextcloud container appears
until docker inspect "$NEXTCLOUD_CONTAINER_NAME"; do
    sleep 1
done
echo 'Nextcloud container found'

# Wait until Nextcloud install is complete
until runOCC status --output json_pretty | grep 'installed' | grep -q 'true'; do
    sleep 1
done
echo 'Nextcloud ready'

# trusted domains
echo "Applying network settings..."
runOCC config:system:set trusted_domains 1 --value="192.168.50.10"
runOCC config:system:set trusted_domains 2 --value="cloud.localdomain"
# runOCC config:system:set trusted_domains 3 --value="10.255.255.10"


# setString 192.168.50.10 trusted_domains[1]
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

runOCC config:system:set --value=preferred_username --type=string -- oidc_login_attributes id
runOCC config:system:set --value=email --type=string -- oidc_login_attributes mail