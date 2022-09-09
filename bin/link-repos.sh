#!/bin/bash

source /var/scripts/repos.sh

set -e

CODE_PATH="/newspack-repos"
WP_PATH="/var/www/html/wp-content"

if [ ! -d "${WP_PATH}" ]; then
	echo "$WP_PATH directory does not exist"
	exit 1
fi


for dir in "${newspack_plugins[@]}"
do :
	link="$WP_PATH/plugins/$dir"
	if [ -L "${link}" ]; then
		echo "$dir already symlinked"
	else
		echo "Symlinking $dir"
		ln -s "$CODE_PATH/$dir" "$link"
	fi
done

for dir in "${newspack_themes[@]}"
do :
	link="$WP_PATH/themes/$dir"
	if [ -L "${link}" ]; then
		echo "$dir already symlinked"
	else
		echo "Symlinking $dir"
		ln -s "$CODE_PATH/newspack-theme/$dir" "$link"
	fi
done