#!/bin/bash

if [ -f /var/scripts/secrets.json ]; then
    cp /var/scripts/secrets.json /tmp/
    wp eval-file /var/scripts/copy-secrets.php --allow-root
    rm /tmp/secrets.json
else
    echo "No secrets.json file found."
fi