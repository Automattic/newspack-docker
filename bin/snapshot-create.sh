#!/bin/bash

FOLDER="/snapshots/$1"
mkdir -p $FOLDER

echo Creating snapshot $1
echo "dumping database..."
wp db export $FOLDER/db.sql --allow-root
echo "Copying uploads..."
mkdir -p $FOLDER/uploads
cp -r /var/www/html/wp-content/uploads/* $FOLDER/uploads
echo "DONE!"
