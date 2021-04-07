# Vagrant+Docker powered base wordpress project

This workspace could be cloned to start working on a local wordpress project served as a docker-compose stack.

## Usage

The **Vagrantfile** creates an ubunt vm, sets up docker, a docker compose and the local hosts file.

In order to change the name to which the vm will be mapped and other environment parameters see the **Vagrantfile** heading variable declarations.

## Save and restore project status

Typing the following command the current status of the wordpress project will be save in a compressed format in the .wordpress/repo folder.

```
    #bash
    ./wp.sh save

    #powershell
    ./wp.ps1 save
```

Typing the following command the latest status saved in the .wordpress/repo folder will be restored, setting the vm hostname as siteurl option.

```
    #bash
    ./wp.sh load

    #powershell
    ./wp.ps1 load
```

Typing the following command the latest status saved in the .wordpress/repo folder will be restored, setting the **first parameter** as siteurl option.

```
    #bash
    ./wp.sh load https://mysite.com

    #powershell
    ./wp.ps1 load https://mysite.com
```

Typing the following command the status saved in the **second parameter** folder will be restored, setting the **first parameter** as siteurl option.

```
    #bash
    ./wp.sh load https://mysite.com /path/to/file

    #powershell
    ./wp.ps1 load https://mysite.com /path/to/file
```