if [ $# -eq 0 ]; then
	echo "No arguments provided"
    echo "Inform the Jurassic Ninja site user and domain"
    echo "Example: jn-cp user123 red-rat.jurassic.ninja"
	exit 1
fi

USER="$1"
DOMAIN="$2"

process_plugin() {
    
    local plugin=$1
    # Let's check if is one of our plugins, if it is, let's use the release script
    for i in "${newspack_plugins[@]}"
    do
        if [[ $i == $plugin ]]
        then
            process_newspack_plugin $plugin $2
            return
        fi
    done

    process_custom_plugin $plugin $2
}

process_newspack_plugin() {
    local plugin=$1
    local password=$2
    local dest_folder="/srv/users/$USER/apps/$USER/public"
    
    cd /newspack-repos/$1
    echo "Creating package for $plugin"
    npm run --silent release:archive > /dev/null
    echo Uploading...
    sshpass -p $password scp -o StrictHostKeyChecking=no "release/$plugin.zip" $USER@$DOMAIN:$dest_folder/
    sshpass -p $password ssh -o StrictHostKeyChecking=no $USER@$DOMAIN "cd $dest_folder; wp plugin install $plugin.zip --force"
}

process_custom_plugin() {
    local plugin=$1
    local password=$2
    local dest_folder="/srv/users/$USER/apps/$USER/public"

    cd /var/www/html/wp-content/plugins/
    echo "Creating package for $plugin"
    zip -r $plugin.zip $plugin/ > /dev/null
    echo Uploading...
    sshpass -p $password scp -o StrictHostKeyChecking=no "$plugin.zip" $USER@$DOMAIN:$dest_folder/
    sshpass -p $password ssh -o StrictHostKeyChecking=no $USER@$DOMAIN "cd $dest_folder; wp plugin install $plugin.zip --force"
    rm $plugin.zip
}