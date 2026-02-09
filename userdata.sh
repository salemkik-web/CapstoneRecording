#!/bin/bash
yum update -y
yum install -y httpd php php-mysqlnd wget unzip

systemctl start httpd
systemctl enable httpd

cd /var/www/html

# Download WordPress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
chown -R apache:apache wordpress

cd wordpress

# Create wp-config.php from sample
cp wp-config-sample.php wp-config.php

# Replace DB values using Terraform variables
sed -i "s/database_name_here/${db_name}/" wp-config.php
sed -i "s/username_here/${db_user}/" wp-config.php
sed -i "s/password_here/${db_password}/" wp-config.php
sed -i "s/localhost/${db_host}/" wp-config.php

# Permissions
chown -R apache:apache /var/www/html/wordpress

systemctl restart httpd
