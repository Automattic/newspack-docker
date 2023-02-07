#!/bin/bash

FOLDER="/snapshots/$1"

echo Loading snapshot $1

# Flush cache to make sure memcached does not hold anything
wp --allow-root cache flush

echo "Cleaning database..."
wp --allow-root db reset --yes

echo "Importing database..."
wp --allow-root db import $FOLDER/db.sql

echo "Copying uploads..."
mkdir -p /var/www/html/wp-content/uploads
cp -r $FOLDER/uploads/* /var/www/html/wp-content/uploads/

echo "DONE!"