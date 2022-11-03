#!/bin/bash
source /var/scripts/repos.sh
source /var/scripts/jn-functions.sh

echo -n Password: 
read -s password
echo

echo "Uploading Newspack plugin"
process_newspack_plugin newspack-plugin $password

dest_folder="/srv/users/$USER/apps/$USER/public"
sshpass -p $password ssh -o StrictHostKeyChecking=no $USER@$DOMAIN "cd $dest_folder; wp plugin activate newspack-plugin; wp newspack setup"