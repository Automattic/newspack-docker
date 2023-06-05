#!/bin/bash

WP_PATH=${1:-"/var/www/html"}

/var/scripts/uninstall.sh $WP_PATH
/var/scripts/install.sh $WP_PATH

wp --allow-root --path="$WP_PATH" plugin install woocommerce
wp --allow-root --path="$WP_PATH" plugin activate newspack-plugin woocommerce
wp --allow-root --path="$WP_PATH" newspack setup

/var/scripts/import-secrets.sh $WP_PATH
