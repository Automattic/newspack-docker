#!/bin/bash

if [[ -n "$APACHE_RUN_USER" ]]; 
    then 
    echo Creating user $APACHE_RUN_USER
    useradd "${APACHE_RUN_USER}" -ms /bin/bash
    echo Setting $APACHE_RUN_USER as the apache user
    sed -i "s|www-data|${APACHE_RUN_USER}|g" /etc/apache2/envvars
else
    echo Using default apache user
fi
