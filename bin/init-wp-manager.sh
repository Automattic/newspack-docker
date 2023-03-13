#!/bin/bash

mkdir -p /var/www/manager-html
cd /var/www/manager-html

# Download WordPress
[ -f /var/www/manager-html/xmlrpc.php ] || wp --allow-root core download

# Configure WordPress
if [ ! -f /var/www/manager-html/wp-config.php ]; then
	echo "Creating Manager wp-config.php ..."
	# Loop until wp cli exits with 0
	# because if running the containers for the first time,
	# the mysql container will reject connections until it has set the database data
	# See "No connections until MySQL init completes" in https://hub.docker.com/_/mysql/
	times=15
	i=1
	while [ "$i" -le "$times" ]; do
		sleep 3
		wp --allow-root config create \
			--dbhost=${MYSQL_HOST} \
			--dbname=${MYSQL_DATABASE} \
			--dbuser=${MYSQL_USER} \
			--dbpass=${MYSQL_PASSWORD} \
			&& break
		[ ! $? -eq 0 ] || break;
		echo "Waiting for creating wp-config.php until mysql is ready to receive connections"
		(( i++ ))
	done

	echo "Setting other wp-config.php constants..."
	wp --allow-root config set WP_DEBUG true --raw --type=constant
	wp --allow-root config set WP_DEBUG_LOG true --raw --type=constant
	wp --allow-root config set WP_DEBUG_DISPLAY false --raw --type=constant
	wp --allow-root config set SCRIPT_DEBUG true --raw --type=constant
	wp --allow-root config set WP_AUTO_UPDATE_CORE true --raw --type=constant
	wp --allow-root config set AUTOMATIC_UPDATER_DISABLED true --raw --type=constant
	wp --allow-root config set table_prefix mngr_

fi

# Copy single site htaccess if none is present
if [ ! -f /var/www/manager-html/.htaccess ]; then
	cp /var/lib/jetpack-config/htaccess /var/www/manager-html/.htaccess
fi

# MU Plugin
mkdir -p /var/www/manager-html/wp-content/mu-plugins
cp /var/scripts/newspack-docker-mu.php /var/www/manager-html/wp-content/mu-plugins