#!/usr/bin/bash

EXPORT_SITE_URL='https://lime-wp-export-domain'

EXPORT_SITE_URL_SL=$(echo "$EXPORT_SITE_URL" | sed -r -e 's/^https?:(.*)$/\1/g')
EXPORT_SITE_URL_D=$(echo "$EXPORT_SITE_URL" | sed -r -e 's/^https?:\/\/(.*)$/\1/g')

WP_CONTAINER_ID=$(docker ps | grep -e "wordpress_wordpress" | cut -d" " -f1 | sed 's/^\s*//g' | sed 's/\s*$//g')
WP_CLI_IMAGE=$(cat /vagrant/Vagrantfile | grep -e '$wp_cli_image\s*=' | sed -r -e 's/^[^=]*=\s*"(.*)"\s*$/\1/')
MYSQL_ROOT_PWD=$(cat /vagrant/.wordpress/docker-compose.yml | grep "MYSQL_ROOT_PASSWORD" | sed -r -e 's/^\s*(.*):\s*(.*)$/\2/')

DOCKER_ENV_VARS=$(cat /vagrant/.wordpress/docker-compose.yml | grep -e "WORDPRESS_DB_.*:\s*.*$" | sed -r -e 's/^\s*(.*):\s*(.*)$/--env \1=\2/' | tr '\n' ' ')