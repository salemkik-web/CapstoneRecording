 #!/bin/bash

# Log everything for debugging
exec > /var/log/user-data.log 2>&1

# Update OS
yum update -y

# Install Apache + PHP + MySQL extension
amazon-linux-extras enable php8.0
yum clean metadata
yum install -y httpd php php-mysqlnd wget unzip

# Start Apache
systemctl start httpd
systemctl enable httpd

# Variables from Terraform
DBName="${db_name}"
DBUser="${db_user}"
DBPassword="${db_password}"
DBHost="${db_host}"

# Wait for RDS to be reachable
until mysql -h "$DBHost" -u "$DBUser" -p"$DBPassword" -e "SHOW DATABASES;" ; do
  echo "Waiting for RDS..."
  sleep 15
done

# Go to web root
cd /var/www/html

# Download WordPress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* .
rm -rf wordpress latest.tar.gz

# Configure WordPress
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/$DBName/g" wp-config.php
sed -i "s/username_here/$DBUser/g" wp-config.php
sed -i "s/password_here/$DBPassword/g" wp-config.php
sed -i "s/localhost/$DBHost/g" wp-config.php

# Permissions
chown -R apache:apache /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# Restart Apache
systemctl restart httpd
