#!/bin/bash

# Log all output for debugging
exec > /var/log/user-data.log 2>&1
set -e

echo "Starting user-data script"

# Update OS
yum update -y

# Enable LAMP + PHP8.0 with MariaDB client
amazon-linux-extras enable lamp-mariadb10.2-php8.0
yum clean metadata

# Install Apache + SSL + PHP + extensions + wget/unzip
yum install -y httpd mod_ssl php php-mysqlnd php-cli php-gd php-curl php-mbstring php-xml php-json wget unzip
yum clean all

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Remove default Apache test page
rm -f /var/www/html/index.html

# Terraform variables
DBName="${db_name}"
DBUser="${db_user}"
DBPassword="${db_password}"
DBHost="${db_host}"

# Wait for RDS to be ready
echo "Waiting for RDS to be ready at $DBHost..."
until mysql -h "$DBHost" -u "$DBUser" -p"$DBPassword" -e "SHOW DATABASES;" ; do
    echo "RDS not ready yet, retrying in 30 seconds..."
    sleep 30
done
echo "RDS is reachable!"

# Navigate to web root
cd /var/www/html

# Download and extract WordPress
echo "Downloading WordPress..."
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* .
rm -rf wordpress latest.tar.gz

# Configure WordPress
echo "Configuring wp-config.php..."
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/$DBName/g" wp-config.php
sed -i "s/username_here/$DBUser/g" wp-config.php
sed -i "s/password_here/$DBPassword/g" wp-config.php
sed -i "s/localhost/$DBHost/g" wp-config.php

# Set permissions
echo "Setting file permissions..."
chown -R apache:apache /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# Restart Apache to apply everything
systemctl restart httpd

echo "User-data script completed successfully!"
