# -*- mode: ruby -*-
# vi: set ft=ruby :

$hostname = "project.local"
$wp_image = "wordpress:5.7.0-php7.4-apache"
$wp_cli_image = "wordpress:cli-2.4.0-php7.4"
$mysql_image = "mysql:8.0.23"
$guest_to_host_ip = "192.168.50.4"

Vagrant.require_version '>= 2.2.15'

Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-20.04"

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false
  
    vb.name = $hostname

    # Customize the amount of memory on the VM:
    vb.memory = "1024"
    vb.cpus = 2
  end

  config.vm.hostname = $hostname

  config.vm.network "private_network", ip: $guest_to_host_ip

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.vm.provision "docker" do |d|
    d.pull_images "nginx"
    d.pull_images $wp_image
    d.pull_images $wp_cli_image
    d.pull_images $mysql_image
  end

  config.vm.provision "shell", inline: <<-'SCRIPT'
    if ! command -v docker-compose &> /dev/null
    then
      sudo curl -L -s "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
      sudo chmod +x /usr/local/bin/docker-compose && \
      sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi
  SCRIPT
  
  config.trigger.before :halt, :reload do |t|
    t.info = "Stopping docker-compose containers"
    t.run_remote = {inline: "docker-compose -f /vagrant/.wordpress/docker-compose.yml stop"}
  end

  config.trigger.after :up, :reload do |t|
    $script = <<-'SCRIPT'
      sed -i -r -e "s/^(\s*image:\s*)wordpress:?.*$/\1$1/" /vagrant/.wordpress/docker-compose.yml && \
      sed -i -r -e "s/^(\s*image:\s*)mysql:?.*$/\1$2/" /vagrant/.wordpress/docker-compose.yml
    SCRIPT
    t.info = "Setting container versions"
    t.run_remote = {inline: $script, args: [$wp_image, $mysql_image]}
  end
  
  config.trigger.after :up, :reload do |t|
    $script = <<-'SCRIPT'
      sed -i -r -e "s/^(\s*server_name\s*).*$/\1$1;/" /vagrant/.wordpress/nginx/default.conf && \
      sed -i -r -e "s/^(\s*return\s*301\s*).*$/\1https:\/\/$1\/\$request_uri;/" /vagrant/.wordpress/nginx/default.conf && \
      sed -i -r -e "s/^(\s*ssl_certificate\s*\/etc\/nginx\/auth\/).*$/\1$1.crt;/" /vagrant/.wordpress/nginx/default.conf && \
      sed -i -r -e "s/^(\s*ssl_certificate_key\s*\/etc\/nginx\/auth\/).*$/\1$1.key;/" /vagrant/.wordpress/nginx/default.conf
    SCRIPT
    t.info = "Setting nginx configuration"
    t.run_remote = {inline: $script, args: [$hostname]}
  end
  
  config.trigger.after :up, :reload do |t|
    $script = <<-'SCRIPT'
      if [ ! -f "/vagrant/.wordpress/certs/$1.crt" ]; then
        openssl req -x509 -newkey rsa:4096 -keyout /vagrant/.wordpress/certs/$1.key -out /vagrant/.wordpress/certs/$1.crt \
        -days 365 -subj "/CN=$1" -nodes &2> /dev/null
      fi
    SCRIPT
    t.info = "Creating TLS certificate"
    t.run_remote = {inline: $script, args: [$hostname]}
  end

  config.trigger.after :up, :reload do |t|
    t.info = "Starting docker-compose containers"
    t.run_remote = {inline: "docker-compose -f /vagrant/.wordpress/docker-compose.yml up -d"}
  end

  # config.trigger.after :up, :reload do |t|
  #   t.info = "Settings local hosts file"
  #   t.run = {inline: "sudo ./wp.sh set-hosts"}
  # end

  # config.trigger.before :destroy do |t|
  #   t.info = "Cleaning local hosts file"
  #   t.run = {inline: "sudo ./wp.sh reset-hosts"}
  # end

end
