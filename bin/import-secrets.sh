#!/bin/bash

WP_PATH=${1:-"/var/www/html"}

if [ -f /var/scripts/secrets.json ]; then
    cp /var/scripts/secrets.json /tmp/
    wp eval-file /var/scripts/copy-secrets.php --allow-root --path=$WP_PATH
    rm /tmp/secrets.json
else
    echo "No secrets.json file found."
fi