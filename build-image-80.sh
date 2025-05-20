#!/bin/bash

source .env
if [[ ! -z "$USE_CUSTOM_APACHE_USER" ]]
then
    APACHE_USER="$USE_CUSTOM_APACHE_USER"
fi

docker build \
    -t newspack-dev-8 \
    --platform linux/arm64 \
    --build-arg PHP_VERSION=8.0 \
    --build-arg COMPOSER_VERSION=2.2.6 \
    --build-arg APACHE_RUN_USER="$APACHE_USER" \
    --build-arg PHPUNIT_VERSION=9.5.10 \
    .
