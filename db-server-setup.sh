#!/bin/bash

# This script should be executed by non-root user with root privileges
# on server with any kind of Red Hat OS (CentOS or similar)

sudo dnf update

# mysql configuration
sudo dnf install mysql-server
clear
sudo systemctl start mysqld.service
sudo systemctl enable mysqld
sudo mysql_secure_installation
clear

# Firewalld configuration
sudo dnf install firewalld
sudo systemctl enable firewalld
sudo systemctl start firewalld
# sudo firewall-cmd --state

# Force "public" as default zone. Probably it's already default but anyway.
sudo firewall-cmd --set-default-zone=public

# Force default network interface "eth0" as public. It allow only ssh access by default
sudo firewall-cmd --zone=public --change-interface=eth0

# Create new zone for private network
sudo firewall-cmd --permanent --new-zone=privateZone

# We should have private network for db server and app server. Move interface of this network to privateZone
sudo firewall-cmd --zone=privateZone --change-interface=private_network0 --permanent

# Move mysql service no privateZone(where is our private network)
sudo firewall-cmd --zone=privateZone --add-service=mysql --permanent
# Alternatively, you may want to use specific mysql port.
# sudo firewall-cmd --zone=privateZone --add-port=5757/tcp

sudo firewall-cmd --reload

clear

firewall-cmd --get-services
# As result of this we should have next result
# privateZone
#   interfaces: private_network0
# public
#   interfaces: eth0

echo "MySQL server installed."
echo "Firewalld enabled."
echo "All outgoing connections restricted"
echo "All public incoming connections drop except 22 port"
echo "Allowed incoming connection from private network to MySQL port (3306 or custom)"