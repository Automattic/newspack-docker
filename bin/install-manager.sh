#!/bin/bash

mkdir -p /var/www/manager-html
cd /var/www/manager-html

if wp --allow-root core is-installed; then
	echo
	echo "Manager already installed"
	echo
	exit 1;
fi

# Install WP core
wp --allow-root core install \
	--url=manager.local \
	--title="${WP_TITLE}" \
	--admin_user=${WP_ADMIN_USER} \
	--admin_password=${WP_ADMIN_PASSWORD} \
	--admin_email=${WP_ADMIN_EMAIL} \
	--skip-email

echo
echo "Manager installed. Open manager.local"
echo
