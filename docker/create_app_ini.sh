#!/bin/sh

set_default() {
    eval local varname=\$$1
    if [ -z "$varname" ]; then
        eval export "$1=\"$2\""
    fi
}

set_default "BRAND_NAME" "gogs"
set_default "USER" "git"
set_default "MODE" "prod"
set_default "DB_TYPE" "postgres"
set_default "DB_SCHEMA" "public"
set_default "SSL_MODE" "disable"
set_default "DEFAULT_BRANCH" "master"
set_default "DISABLE_SSH" "false"
set_default "START_SSH_SERVER" "true"
set_default "OFFLINE_MODE" "false"
set_default "EMAIL_ENABLED" "false"
set_default "REQUIRE_EMAIL_CONFIRMATION" "false"
set_default "DISABLE_REGISTRATION" "false"
set_default "ENABLE_REGISTRATION_CAPTCHA" "true"
set_default "REQUIRE_SIGNIN_VIEW" "false"
set_default "ENABLE_EMAIL_NOTIFICATION" "false"
set_default "DISABLE_GRAVATAR" "false"
set_default "ENABLE_FEDERATED_AVATAR" "false"
set_default "SESSION_PROVIDER" "file"
set_default "LOG_MODE" "file"
set_default "LOG_LEVEL" "Info"
set_default "INSTALL_LOCK" "true"

envsubst < /usr/local/bin/gogs/custom/conf/app.ini.template > /usr/local/bin/gogs/custom/conf/app.ini

exec "$@"