#!/bin/bash
set -e

WP_PATH=$1
echo "Linking contributed plugins to $WP_PATH"

# if WP_PATH is empty, use default
if [ -z "$WP_PATH" ]; then
	WP_PATH="/var/www/html/wp-content"
else
  WP_PATH="/var/www/additional-sites-html/$WP_PATH/wp-content"
fi

if [ ! -d "${WP_PATH}" ]; then
	echo "$WP_PATH directory does not exist"
	exit 1
fi

SOURCE_DIR="/contributed-plugins"
TARGET_DIR="$WP_PATH/plugins";

find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d '' dir; do
    # Extract the base directory name
    dirname=$(basename "$dir")

    symlink_path="$TARGET_DIR/$dirname"

    # Check if the symlink already exists and if not – create it
    if [ ! -e "$symlink_path" ]; then
        ln -s "$dir" "$symlink_path"
        echo "Symlinked: $symlink_path -> $dir"
    fi
done
