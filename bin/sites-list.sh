#!/bin/bash

parent_folder="/var/www/additional-sites-html"

for folder in "$parent_folder"/*; do
    if [ -d "$folder" ]; then
        folder_name=$(basename "$folder")
        echo "$folder_name: http://additional-sites.local/$folder_name"
    fi
done