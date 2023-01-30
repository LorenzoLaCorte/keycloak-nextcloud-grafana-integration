#!/bin/bash

#
# Helper functions
#

KEYCLOAK_CONTAINER_NAME=VCC_stack_keycloak
KEYCLOAK_ADMIN_USER=admin
KEYCLOAK_ADMIN_PASSWORD=admin
SAMPLE_USER_PASSWORD=itsdifficult

# Keycloak
keycloakAdminToken() {
    curl -X POST "http://localhost:8080/realms/master/protocol/openid-connect/token" \
        --data-urlencode "username=${KEYCLOAK_ADMIN_USER}" \
        --data-urlencode "password=${KEYCLOAK_ADMIN_PASSWORD}" \
        --data-urlencode 'grant_type=password' \
        --data-urlencode 'client_id=admin-cli'
}
keycloakCurl() {
    curl \
        --header "Authorization: Bearer $(keycloakAdminToken | jq -r '.access_token')" \
        "$@"
}

# Wait until Keycloak is alive
until curl -sSf http://127.0.0.1:8080; do
    sleep 1
done
echo 'Keycloak alive'

# Create 'vcc' keycloak realm
if [ "$(keycloakCurl -o /dev/null -sw '%{http_code}' http://127.0.0.1:8080/admin/realms/vcc)" = "404" ]; then
    keycloakCurl \
        -X POST \
        -H 'Content-Type: application/json' \
        --data '{"displayName":"Virtualization and Cloud Computing","id":"vcc","realm":"vcc","enabled":true}' \
        http://127.0.0.1:8080/admin/realms
fi

# Create 'nextcloud' keycloak client
if [ "$(keycloakCurl -o /dev/null -sw '%{http_code}' http://127.0.0.1:8080/admin/realms/vcc/clients/nextcloud)" = "404" ]; then
    # !!! THIS REDIRECT URI IS INSECURE !!!
    keycloakCurl \
        -X POST \
        -H 'Content-Type: application/json; charset=UTF-8' \
        --data "{\"id\":\"nextcloud\",\"clientId\":\"nextcloud\",\"description\":\"Integration with Nextcloud\",\"publicClient\":false,\"redirectUris\":[\"*\"],\"enabled\":true}" \
        http://127.0.0.1:8080/admin/realms/vcc/clients
fi
OIDC_CLIENT_SECRET=$(keycloakCurl http://127.0.0.1:8080/admin/realms/vcc/clients/nextcloud | jq -r '.secret')

# Create a user inside of keycloak
findExaminer() {
    keycloakCurl 'http://127.0.0.1:8080/admin/realms/vcc/users?exact=true&lastName=Examiner'
}
findExaminerId() {
    findExaminer | jq -r '.[0].id'
}
if [ "$(findExaminer | jq -r '. | length')" = "0" ]; then
    keycloakCurl \
        -X POST \
        -H 'Content-Type: application/json; charset=UTF-8' \
        --data "{\"id\":\"examiner\",\"username\":\"vcc-examiner\",\"firstName\":\"VCC\",\"lastName\":\"Examiner\",\"email\":\"vcc.examiner@bots.dibris.unige.it\",\"emailVerified\":true,\"enabled\":true}" \
        'http://127.0.0.1:8080/admin/realms/vcc/users'
    user_id=$(findExaminerId)
    keycloakCurl \
        -X PUT \
        -H 'Content-Type: application/json; charset=UTF-8' \
        --data "{\"type\":\"rawPassword\",\"value\":\"${SAMPLE_USER_PASSWORD}\"}" \
        "http://127.0.0.1:8080/admin/realms/vcc/users/${user_id}/reset-password"
fi
