FROM ubuntu:22.04

VOLUME ["/var/www/html"]

ARG PHP_VERSION
ARG COMPOSER_VERSION
ARG NODE_VERSION
ARG APACHE_RUN_USER
ARG PHPUNIT_VERSION
# ARG NPM_VERSION

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

WORKDIR /tmp

# Install basic packages, including Apache.
RUN \
	export DEBIAN_FRONTEND=noninteractive \
	&& apt-get update \
	&& apt-get install -y language-pack-en-base software-properties-common \
	&& retry_ppa() { \
		local attempt=0 delay=5 max_retries=5; \
		until add-apt-repository ppa:ondrej/php; do \
			attempt=$((attempt + 1)); \
			if [ $attempt -ge $max_retries ]; then \
				echo "Failed to add PPA after $max_retries attempts" >&2; \
				return 1; \
			fi; \
			echo "Attempt $attempt failed. Retrying in $delay seconds..." >&2; \
			sleep $delay; \
			delay=$((delay * 2)); \
		done; \
	} \
	&& retry_ppa \
	&& apt-get update \
	&& apt-get install -y \
		apache2 \
		curl \
		git \
		jq \
		less \
		libsodium23 \
		mysql-client \
		nano \
		ssmtp \
		subversion \
		sudo \
		unzip \
		vim \
		zip \
		wget \
		memcached \
		rsync \
		sshpass \
	&& apt-get remove --purge --auto-remove -y software-properties-common \
	&& rm -rf /var/lib/apt/lists/* ~/.launchpadlib

# Enable mod_rewrite in Apache.
RUN a2enmod rewrite

# Load the environment variables from the .env file
COPY .env /tmp/.env

# Install requested version of PHP.
RUN \
	: "${PHP_VERSION:?Build argument PHP_VERSION needs to be set and non-empty.}" \
	&& export DEBIAN_FRONTEND=noninteractive \
	&& apt-get update \
	&& apt-get install -y \
		libapache2-mod-php${PHP_VERSION} \
		php${PHP_VERSION} \
		php${PHP_VERSION}-bcmath \
		php${PHP_VERSION}-cli \
		php${PHP_VERSION}-curl \
		php${PHP_VERSION}-intl \
		php${PHP_VERSION}-ldap \
		php${PHP_VERSION}-mbstring \
		php${PHP_VERSION}-mysql \
		php${PHP_VERSION}-opcache \
		php${PHP_VERSION}-pgsql \
		php${PHP_VERSION}-soap \
		php${PHP_VERSION}-sqlite3 \
		php${PHP_VERSION}-xdebug \
		php${PHP_VERSION}-xml \
		php${PHP_VERSION}-xsl \
		php${PHP_VERSION}-zip \
		php${PHP_VERSION}-memcache \
		phpunit \
	php-pear \
	php${PHP_VERSION}-dev \
	&& apt-get install -y --no-install-recommends \
		php${PHP_VERSION}-apcu \
		php${PHP_VERSION}-gd \
		php${PHP_VERSION}-imagick \
	&& rm -rf /var/lib/apt/lists/*

# Install requested version of Composer.
RUN \
	: "${COMPOSER_VERSION:?Build argument COMPOSER_VERSION needs to be set and non-empty.}" \
	&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer --version=$COMPOSER_VERSION \
	&& php -r "unlink('composer-setup.php');"

# Install requested version of Node.
# We add the PPA for ease of updating, while we download the specific node version manually if possible for installation.
RUN \
	: "${NODE_VERSION:?Build argument NODE_VERSION needs to be set and non-empty.}" \
	&& N=${NODE_VERSION%%.*} \
	&& curl -fSL https://deb.nodesource.com/setup_${N}.x | bash - \
	&& DEB="$(curl -fSL https://deb.nodesource.com/node_${N}.x/pool/main/n/nodejs/ | perl -nwe 'BEGIN { $v = shift; $arch = shift; $re = qr/nodejs_\Q$v\E-.*_\Q$arch.deb\E/; $out=""; } $out=$1 if /href="($re)"/; END { print "$out"; }' "${NODE_VERSION}" "$(dpkg --print-architecture)")" \
	&& if [ -n "$DEB" ]; then curl -fSL "https://deb.nodesource.com/node_${N}.x/pool/main/n/nodejs/$DEB" --output /tmp/nodejs.deb && dpkg -i /tmp/nodejs.deb; else DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs; fi \
	&& rm -rf /var/lib/apt/lists/* /tmp/nodejs.deb

# Install requested version of PHPUNIT
RUN \
	: "${PHPUNIT_VERSION:?Build argument PHPUNIT_VERSION needs to be set and non-empty.}" \
	&& wget https://phar.phpunit.de/phpunit-${PHPUNIT_VERSION}.phar \
	&& chmod +x phpunit-${PHPUNIT_VERSION}.phar \
	&& mv phpunit-${PHPUNIT_VERSION}.phar /usr/local/bin/phpunit

# Install wp-cli.
RUN curl -o /usr/local/bin/wp -fSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli-nightly.phar \
	&& chmod +x /usr/local/bin/wp

# Install PsySH to use in wp-cli shell.
RUN mkdir /usr/local/src/psysh \
	&& cd /usr/local/src/psysh \
	&& composer require psy/psysh:@stable \
	&& mkdir ~/.wp-cli \
	&& echo "require: /usr/local/src/psysh/vendor/autoload.php" > ~/.wp-cli/config.yml \
	&& rm -rf ~/.cache ~/.composer ~/.config ~/.local ~/.subversion

# Copy a default config file for an apache host.
COPY ./config/apache_default /etc/apache2/sites-available/000-default.conf
COPY ./config/apache_manager /etc/apache2/sites-available/001-manager.conf
RUN a2ensite 001-manager.conf


# Copy a default set of settings for PHP (php.ini).
COPY ./config/php.ini /etc/php/${PHP_VERSION}/apache2/conf.d/20-jetpack-wordpress.ini
COPY ./config/php.ini /etc/php/${PHP_VERSION}/cli/conf.d/20-jetpack-wordpress.ini

# Copy single site htaccess to /var/lib/jetpack-config. run.sh will move it to the site's base dir if there's none present.
COPY ./config/htaccess /var/lib/jetpack-config/htaccess
COPY ./config/htaccess-multi /var/lib/jetpack-config/htaccess-multi

# Copy wp-tests-config to /var/lib/jetpack-config. run.sh will move it to the WordPress source code base dir if there's none present.
COPY ./config/wp-tests-config.php /var/lib/jetpack-config/wp-tests-config.php

# Copy a default set of settings for SMTP.
COPY ./config/ssmtp.conf /etc/ssmtp/ssmtp.conf

# Make apache run with the desired user
COPY ./bin/init_apache_user.sh /usr/local/bin/init_apache_user
RUN chmod +x /usr/local/bin/init_apache_user && /usr/local/bin/init_apache_user

# Copy and make cmd script executable.
COPY ./bin/run.sh /usr/local/bin/run
RUN chmod +x /usr/local/bin/run

# Set up SSL
RUN a2enmod ssl
# https://stackoverflow.com/a/73303983/3772847
RUN echo "Mutex posixsem" >> /etc/apache2/apache2.conf
COPY ./bin/ssl.sh /usr/local/bin/ssl
RUN chmod +x /usr/local/bin/ssl
RUN /usr/local/bin/ssl 'localhost'
RUN /usr/local/bin/ssl 'manager.com'

# Set up additional sites support
RUN a2enmod vhost_alias
COPY ./config/apache_additional_sites /etc/apache2/sites-available/002-additional.conf
RUN a2ensite 002-additional.conf

# Set the working directory for the next commands.
WORKDIR /var/www/html

# Make WP CLI always run as with allow-root.
RUN echo alias wp=\"wp --allow-root\" >> ~/.bashrc

# Allow us to login and run commands as the default apache user. Not recommended for production environments!
RUN chsh -s /bin/bash www-data

CMD ["/usr/local/bin/run"]
