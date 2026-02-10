#!/bin/bash

# Update OS and install Apache + PHP + required tools
sudo yum update -y
sudo yum install -y httpd php php-mysqlnd wget unzip

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Database variables passed from Terraform
DBName="${db_name}"
DBUser="${db_user}"
DBPassword="${db_password}"
DBHost="${db_host}"

# Wait a few seconds for RDS to be ready
sleep 10

# Download and extract WordPress
sudo wget http://wordpress.org/latest.tar.gz -P /var/www/html
cd /var/www/html
sudo tar -zxvf latest.tar.gz
sudo cp -rvf wordpress/* .
sudo rm -rf wordpress latest.tar.gz

# Configure WordPress to use RDS
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/$DBName/g" wp-config.php
sudo sed -i "s/username_here/$DBUser/g" wp-config.php
sudo sed -i "s/password_here/$DBPassword/g" wp-config.php
sudo sed -i "s/localhost/$DBHost/g" wp-config.php

# Set correct permissions for Apache
sudo chown -R apache:apache /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

# Restart Apache to apply changes
sudo systemctl restart httpd
