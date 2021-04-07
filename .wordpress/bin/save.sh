#!/usr/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/.env.sh

PATH_TO_EXPORT='wp-content'
EXPORT_PATH="./lime_wp_export"

EXPORT_FILE_NAME=$(date +%s%3N).tar.gz

CLI_CMD=$(cat <<EOF | tr '\n' ' ' | sed -r -e 's/\s*\&\&\s*/ \&\& /g' | sed -r -e 's/^\s*//g' | sed -r -e 's/\s*$//g' | sed -r -e 's/"/\\"/g'
    export SITE_URL=\$(wp option get siteurl) && 
    export SITE_URL_SL=\$(echo \$SITE_URL | sed -r -e 's/^https?:(.*)$/\1/g') && 
    export SITE_URL_D=\$(echo \$SITE_URL | sed -r -e 's/^https?:\/\/(.*)$/\1/g') && 
    rm -rf $EXPORT_PATH && 
    mkdir $EXPORT_PATH && 
    cp -r ./$PATH_TO_EXPORT $EXPORT_PATH/$PATH_TO_EXPORT &&
    cd $EXPORT_PATH && 
    wp db export --dbuser=root --dbpass=$MYSQL_ROOT_PWD bkp.sql > /dev/null && 
    find ./ -type f -print0 | xargs -0 sed -i 's|'\$SITE_URL'|$EXPORT_SITE_URL|g' && 
    find ./ -type f -print0 | xargs -0 sed -i 's|'\$SITE_URL_SL'|$EXPORT_SITE_URL_SL|g' && 
    find ./ -type f -print0 | xargs -0 sed -i 's|'\$SITE_URL_D'|$EXPORT_SITE_URL_D|g' && 
    tar -czf tmp wp-content bkp.sql > /dev/null && 
    cat tmp
EOF
)

mkdir -p /vagrant/.wordpress/repo

echo "Dumping db and copying www/$PATH_TO_EXPORT folder to .wordpress/repo/$EXPORT_FILE_NAME"

docker run -i --rm -u 33 \
    $DOCKER_ENV_VARS \
    --volumes-from "$WP_CONTAINER_ID" \
    --network container:"$WP_CONTAINER_ID" \
    --entrypoint bash "$WP_CLI_IMAGE" \
    -c "$CLI_CMD" > /vagrant/.wordpress/repo/$EXPORT_FILE_NAME