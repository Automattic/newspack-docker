#!/bin/bash

FILE="/var/scripts/manager.${1}.key"
CONSTANT="NEWSPACK_MANAGER_API_${1^^}_KEY"

wp --allow-root config set $CONSTANT "$(cat $FILE)"
