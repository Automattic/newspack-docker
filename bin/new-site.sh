#!/bin/bash

/var/scripts/uninstall.sh
/var/scripts/install.sh

wp plugin install woocommerce
wp plugin activate newspack-plugin woocommerce
wp newspack setup

/var/scripts/import-secrets.sh
