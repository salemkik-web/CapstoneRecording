#!/bin/bash
# Modern WordPress Setup Script for Amazon Linux 2 with RDS

# Update system
sudo yum update -y
sudo yum install -y httpd php php-cli php-fpm php-mysqlnd php-gd php-mbstring php-xml php-opcache php-intl php-soap php-json unzip wget curl mariadb

# Start Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# RDS variables from Terraform
DBName="${db_name}"
DBUser="${db_user}"
DBPassword="${db_password}"
DBHost="${db_host}"

# Install WordPress
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress/* .
sudo rm -rf wordpress latest.tar.gz

# Configure wp-config.php
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/$DBName/" wp-config.php
sudo sed -i "s/username_here/$DBUser/" wp-config.php
sudo sed -i "s/password_here/$DBPassword/" wp-config.php
sudo sed -i "s/localhost/$DBHost/" wp-config.php
sudo curl -s https://api.wordpress.org/secret-key/1.1/salt/ | sudo tee -a wp-config.php > /dev/null

# Permissions
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www/html
sudo chmod 2775 /var/www/html
sudo find /var/www/html -type d -exec chmod 2775 {} \;
sudo find /var/www/html -type f -exec chmod 0664 {} \;

# Restart Apache
sudo systemctl restart httpd
echo "✅ WordPress setup complete (connected to RDS)"
