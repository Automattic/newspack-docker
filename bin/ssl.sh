#!/bin/bash

. /tmp/.env

if [[ ! $(command -v mkcert) ]]; then
  echo "Installing mkcert"
  apt-get update && apt install -y wget libnss3-tools

  LATEST_RELEASE_DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/FiloSottile/mkcert/releases" | jq -r 'first | .assets[] | select(.name | contains("linux-amd64")) | .browser_download_url')
  printf "$LATEST_RELEASE_DOWNLOAD_URL"

  wget "$LATEST_RELEASE_DOWNLOAD_URL"
  mv mkcert-v*-linux-amd64 mkcert
  chmod a+x mkcert
  mv mkcert /usr/local/bin/
fi

CERTS_DIR="/etc/ssl/certs"

if [ -f "$CERTS_DIR/${WP_DOMAIN}.pem" ]; then
  echo "Found SSL certificate in $CERTS_DIR for ${WP_DOMAIN}."
else
  echo "Creating SSL certificate in $CERTS_DIR for ${WP_DOMAIN}…"

  # Create certificate for the domain.
  mkcert -install
  mkcert ${WP_DOMAIN}

  mkdir -p $CERTS_DIR
  mv ${WP_DOMAIN}.pem "$CERTS_DIR/${WP_DOMAIN}.pem"
  mv ${WP_DOMAIN}-key.pem "$CERTS_DIR/${WP_DOMAIN}-key.pem"
fi

# Replace "localhost" with WP_DOMAIN in the apache config file:
sed -i "s/localhost/${WP_DOMAIN}/g" /etc/apache2/sites-available/000-default.conf
