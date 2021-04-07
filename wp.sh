#!/usr/bin/bash

COMMAND="$1"

shift 1

case $COMMAND in
    save)
        vagrant ssh -c "/vagrant/.wordpress/bin/save.sh $@";;
    load)
        vagrant ssh -c "/vagrant/.wordpress/bin/load.sh $@";;
    *)
        cat <<'EOF'
Usage: ./wp.sh [command] [args]

Commands:

    save    Saves the current status of the wordpress instance (db and wp-content)
            args:
                none
    load    Loads a saved status tarball on the wordpress instance
            args:
                1. (OPTIONAL) Import file url, used to set the siteurl option. Takes the value of $hostname variable from Vagrantfile if omitted.
                2. (OPTIONAL) Import file path. Takes the latest tarball in ./wordpress/repo folder
EOF
;;
esac
