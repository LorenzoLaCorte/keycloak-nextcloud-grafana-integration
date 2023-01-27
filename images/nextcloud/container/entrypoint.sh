#!/bin/sh

NEXTCLOUD_CONTAINER_NAME=VCC_stack_nextcloud

#
# Helper functions
#
# Nextcloud
runOCC() {
    docker exec -i -u www-data "$NEXTCLOUD_CONTAINER_NAME" php occ "$@"
}
setBoolean() { runOCC config:system:set --value="$2" --type=boolean -- "$1"; }
setInteger() { runOCC config:system:set --value="$2" --type=integer -- "$1"; }
setString() { runOCC config:system:set --value="$2" --type=string -- "$1"; }
# Keycloak
runKeycloak() {
    docker exec -i "$KEYCLOAK_CONTAINER_NAME" "$@"
}
keycloakAdminToken() {
    runKeycloak curl -X POST "http://localhost:8080/realms/master/protocol/openid-connect/token" \
        --data-urlencode "username=${KEYCLOAK_ADMIN_USER}" \
        --data-urlencode "password=${KEYCLOAK_ADMIN_PASSWORD}" \
        --data-urlencode 'grant_type=password' \
        --data-urlencode 'client_id=admin-cli'
}
keycloakCurl() {
    runKeycloak curl \
        --header "Authorization: Bearer $(keycloakAdminToken | jq -r '.access_token')" \
        "$@"
}

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

echo "Applying network settings..."
php /var/www/html/occ config:system:set trusted_domains 1 --value="192.168.50.10"