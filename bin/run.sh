#!/bin/bash
set -e

# This file is run for the Docker image defined in Dockerfile.
# These commands will be run each time the container is run.
#
# If you modify anything here, remember to build the image again by running:
# jetpack docker build-image

user="${APACHE_RUN_USER:-www-data}"

chmod +x /var/scripts/init-wp.sh

if [ $user != 'www-data' ];
	then
	echo Switching to user $user
	su -c "/var/scripts/init-wp.sh" -m $user
else
	echo Running as default user $user
	/var/scripts/init-wp.sh
fi

# Clean up old method of including psysh (used from 2019 until 2021)
# if [[ -e /var/www/html/wp-cli.yml ]] && grep -q '^require: /usr/local/bin/psysh$' /var/www/html/wp-cli.yml; then
# 	TMP="$(grep -v '^require: /usr/local/bin/psysh$' /var/www/html/wp-cli.yml || true)"
# 	if [[ -z "$TMP" ]]; then
# 		rm /var/www/html/wp-cli.yml
# 	else
# 		echo "$TMP" > /var/www/html/wp-cli.yml
# 	fi
# fi

# if [ "$COMPOSE_PROJECT_NAME" == "jetpack_dev" ] ; then
# 	# If we don't have the wordpress test helpers, download them
# 	if [ ! -d /tmp/wordpress-develop/tests ]; then
# 		# Get latest WordPress unit-test helper files
# 		svn co \
# 			https://develop.svn.wordpress.org/trunk/tests/phpunit/data \
# 			/tmp/wordpress-develop/tests/phpunit/data \
# 			--trust-server-cert \
# 			--non-interactive
# 		svn co \
# 			https://develop.svn.wordpress.org/trunk/tests/phpunit/includes \
# 			/tmp/wordpress-develop/tests/phpunit/includes \
# 			--trust-server-cert \
# 			--non-interactive
# 	fi

# 	# Create a wp-tests-config.php if there's none currently
# 	if [ ! -f /tmp/wordpress-develop/wp-tests-config.php ]; then
# 		cp /var/lib/jetpack-config/wp-tests-config.php /tmp/wordpress-develop/wp-tests-config.php
# 	fi

# 	# Symlink jetpack into wordpress-develop for WP >= 5.6-beta1
# 	WP_TESTS_JP_DIR="/tmp/wordpress-develop/tests/phpunit/data/plugins/jetpack"
# 	if [ ! -L $WP_TESTS_JP_DIR ] || [ ! -e $WP_TESTS_JP_DIR ]; then
# 		ln -s /var/www/html/wp-content/plugins/jetpack $WP_TESTS_JP_DIR
# 	fi
# fi

# for DIR in /usr/local/src/jetpack-monorepo/projects/plugins/*; do
# 	[ -d "$DIR" ] || continue # We are only interested in directories, e.g. different plugins.
# 	PLUGIN="$(basename $DIR)"
# 	# Symlink plugins into the wp-content dir.
# 	if [ ! -e /var/www/html/wp-content/plugins/"$PLUGIN" ]; then
# 		echo "Linking the $PLUGIN plugin."
# 		ln -s "$DIR" /var/www/html/wp-content/plugins/"$PLUGIN"
# 	fi
# done

WP_HOST_PORT=":$HOST_PORT"

if [ 80 -eq "$HOST_PORT" ]; then
	WP_HOST_PORT=""
fi

chmod +x /var/scripts/*
/var/scripts/run-extras.sh
/var/scripts/link-repos.sh

# Memcached
cp /var/scripts/object-cache.php /var/www/html/wp-content/

# Clean up pre-existing Apache pid file
APACHE_PID_FILE="/run/apache2/apache2.pid"
if [ -e $APACHE_PID_FILE ]; then
	rm -f $APACHE_PID_FILE
fi

echo
echo "Open http://${WP_DOMAIN}${WP_HOST_PORT}/ to see your site!"
echo "Open http://localhost:8025 to see Mailhog inbox."
echo

# Start memcached
/etc/init.d/memcached start

# Run apache in the foreground so the container keeps running
echo "Running Apache in the foreground"
apachectl -D FOREGROUND
