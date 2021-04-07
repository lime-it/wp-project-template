#!/usr/bin/bash

IMPORT_SITE_URL="$1"
IMPORT_SITE_URL=${IMPORT_SITE_URL:="https://"$(cat /vagrant/Vagrantfile | grep -e "\$hostname\s*=" | sed -r -e 's/^\s*\$hostname\s*=\s*"(.*)"$/\1/')}

source $(dirname "${BASH_SOURCE[0]}")/.env.sh

IMPORT_FILE_NAME="$2"
IMPORT_FILE_NAME=${IMPORT_FILE_NAME:="/vagrant/.wordpress/repo/"$(ls /vagrant/.wordpress/repo/ | sort -r | head -1)}

CLI_CMD=$(cat <<EOF | tr '\n' ' ' | sed -r -e 's/\s*\&\&\s*/ \&\& /g' | sed -r -e 's/^\s*//g' | sed -r -e 's/\s*$//g' | sed -r -e 's/"/\\"/g'
    export SITE_URL=$IMPORT_SITE_URL && 
    export SITE_URL_SL=\$(echo \$SITE_URL | sed -r -e 's/^https?:(.*)$/\1/g') && 
    export SITE_URL_D=\$(echo \$SITE_URL | sed -r -e 's/^https?:\/\/(.*)$/\1/g') && 
    rm -rf wp-content && 
    tar -xzf - &&  
    find ./ -type f -print0 | xargs -0 sed -i 's|$EXPORT_SITE_URL_D|'\$SITE_URL_D'|g' && 
    find ./ -type f -print0 | xargs -0 sed -i 's|$EXPORT_SITE_URL_SL|'\$SITE_URL_SL'|g' &&
    find ./ -type f -print0 | xargs -0 sed -i 's|$EXPORT_SITE_URL|'\$SITE_URL'|g' && 
    wp db import --dbuser=root --dbpass=$MYSQL_ROOT_PWD bkp.sql && 
    rm bkp.sql
EOF
)


echo "Loading db and copying wp-content folder from $IMPORT_FILE_NAME setting siteurl to $IMPORT_SITE_URL"

docker run -i --rm -u 33 \
    $DOCKER_ENV_VARS \
    --volumes-from "$WP_CONTAINER_ID" \
    --network container:"$WP_CONTAINER_ID" \
    --entrypoint bash "$WP_CLI_IMAGE" \
    -c "$CLI_CMD" < $IMPORT_FILE_NAME