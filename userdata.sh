#!/bin/bash
# ========================================================
# Modern WordPress Setup Script for Amazon Linux 2
# Using RDS as database
# ========================================================

# -----------------------------
# Update system and install required packages
# -----------------------------
sudo yum update -y
sudo yum install -y httpd php php-cli php-fpm php-mysqlnd php-gd php-mbstring php-xml php-opcache php-intl php-soap php-json unzip wget curl mariadb

# -----------------------------
# Start Apache and enable on boot
# -----------------------------
sudo systemctl start httpd
sudo systemctl enable httpd

# -----------------------------
# Database configuration from Terraform
# -----------------------------
DBName="${db_name}"          # Terraform variable for DB name
DBUser="${db_user}"          # Terraform variable for DB user
DBPassword="${db_password}"  # Terraform variable for DB password
DBHost="${rds_endpoint}" #Terraform variable for RDS endpoint


# -----------------------------
# Download and install WordPress
# -----------------------------
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress/* .
sudo rm -rf wordpress latest.tar.gz

# -----------------------------
# Configure WordPress wp-config.php
# -----------------------------
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/$DBName/" wp-config.php
sudo sed -i "s/username_here/$DBUser/" wp-config.php
sudo sed -i "s/password_here/$DBPassword/" wp-config.php
sudo sed -i "s/localhost/$DBHost/" wp-config.php

# Generate WordPress security keys automatically
sudo curl -s https://api.wordpress.org/secret-key/1.1/salt/ | sudo tee -a wp-config.php > /dev/null

# -----------------------------
# Set permissions for WordPress
# -----------------------------
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www/html
sudo chmod 2775 /var/www/html
sudo find /var/www/html -type d -exec chmod 2775 {} \;
sudo find /var/www/html -type f -exec chmod 0664 {} \;

# -----------------------------
# Optional: Test RDS connection
# -----------------------------
# mysql -h "$DBHost" -u "$DBUser" -p"$DBPassword" "$DBName" -e "SHOW DATABASES;"

# -----------------------------
# Restart Apache
# -----------------------------
sudo systemctl restart httpd

echo "✅ WordPress setup complete (connected to RDS)"
