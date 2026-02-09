#!/bin/bash
sudo yum update -y
sudo yum install -y httpd php php-cli php-mysqlnd php-gd php-mbstring php-xml unzip wget curl mariadb

sudo systemctl start httpd
sudo systemctl enable httpd

DBName="${db_name}"
DBUser="${db_user}"
DBPassword="${db_password}"
DBHost="${db_host}"

cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress/* .
sudo rm -rf wordpress latest.tar.gz

sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/$DBName/" wp-config.php
sudo sed -i "s/username_here/$DBUser/" wp-config.php
sudo sed -i "s/password_here/$DBPassword/" wp-config.php
sudo sed -i "s/localhost/$DBHost/" wp-config.php

sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www/html
sudo chmod -R 775 /var/www/html

sudo systemctl restart httpd
echo "✅ WordPress setup complete (connected to RDS)"
