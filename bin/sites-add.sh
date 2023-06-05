#!/bin/bash

names=(
    "site1"
    "site2"
    "site3"
    "site4"
    "site5"
    "site6"
)

user="${APACHE_RUN_USER:-www-data}"


for name in "${names[@]}"; do
    if [ ! -d "/var/www/additional-sites-html/$name" ]; then
        mkdir -p "/var/www/additional-sites-html/$name"
        chown $user:$user "/var/www/additional-sites-html/$name"

        mysqladmin create $name -u root -p$MYSQL_ROOT_PASSWORD -h db
        mysql -u root -p$MYSQL_ROOT_PASSWORD -h db -e "GRANT ALL PRIVILEGES ON $name.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"

        su -c "/var/scripts/init-additional-site.sh $name" -m $user
        su -c "/var/scripts/reset-site.sh /var/www/additional-sites-html/$name" -m $user
        
        echo
        echo "Site $name created!. Open additional-sites.local/${name}"
        echo

        break
    fi
done



# /var/scripts/uninstall.sh
# /var/scripts/install.sh

# wp plugin install woocommerce
# wp plugin activate newspack-plugin woocommerce
# wp newspack setup

# /var/scripts/import-secrets.sh
