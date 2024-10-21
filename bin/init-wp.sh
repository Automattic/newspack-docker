#!/bin/bash

# Download WordPress
[ -f /var/www/html/xmlrpc.php ] || wp --allow-root core download

# Configure WordPress
if [ ! -f /var/www/html/wp-config.php ]; then
	echo "Creating wp-config.php ..."
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
	wp --allow-root config set table_prefix ${TABLE_PREFIX}
	wp --allow-root config set WP_CACHE true --type=constant

	# Respecting Dockerfile-forwarded environment variables
	# Allow to be reverse-proxied from https
	wp --allow-root config set "_SERVER['HTTPS']" "isset( \$_SERVER['HTTP_X_FORWARDED_PROTO'] ) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https' ? 'on' : NULL" \
		--raw \
		--type=variable

	# Allow this installation to run on http or https.
	wp --allow-root config set DOCKER_REQUEST_URL \
		"( ! empty( \$_SERVER['HTTPS'] ) ? 'https://' : 'http://' ) . ( ! empty( \$_SERVER['HTTP_HOST'] ) ? \$_SERVER['HTTP_HOST'] : 'localhost' )" \
		--raw \
		--type=constant
	wp --allow-root config set WP_SITEURL "DOCKER_REQUEST_URL" --raw --type=constant
	wp --allow-root config set WP_HOME "DOCKER_REQUEST_URL" --raw --type=constant

	# Tell WP-CONFIG we're in a docker instance.
	wp --allow-root config set JETPACK_DOCKER_ENV true --raw --type=constant
fi

# Copy single site htaccess if none is present
if [ ! -f /var/www/html/.htaccess ]; then
	cp /var/lib/jetpack-config/htaccess /var/www/html/.htaccess
fi

# MU Plugin
mkdir -p /var/www/html/wp-content/mu-plugins
cp /var/scripts/newspack-docker-mu.php /var/www/html/wp-content/mu-plugins