 #!/bin/bash

# Log all output for debugging
exec > /var/log/user-data.log 2>&1
set -e
echo "Starting userdata script..."

# Update OS
yum update -y

# Enable PHP 8 via Amazon Linux Extras
amazon-linux-extras enable php8.0
yum clean metadata

# Install Apache, PHP, required PHP extensions, and tools
yum install -y httpd mod_ssl php php-cli php-mysqlnd php-gd php-curl php-mbstring php-xml php-json wget unzip

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Ensure Apache listens on all interfaces
sed -i 's/^Listen .*/Listen 0.0.0.0:80/' /etc/httpd/conf/httpd.conf
systemctl restart httpd

# Remove default Apache test page and welcome.conf
rm -f /var/www/html/index.html
rm -f /etc/httpd/conf.d/welcome.conf

# Terraform-provided DB variables
DBName="${db_name}"
DBUser="${db_user}"
DBPassword="${db_password}"
DBHost="${db_host}"

# Wait for RDS to be reachable
echo "Waiting for RDS at $DBHost..."
for i in {1..20}; do
  mysql -h "$DBHost" -u "$DBUser" -p"$DBPassword" -e "SHOW DATABASES;" && break
  sleep 15
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

# Set correct permissions
echo "Setting file permissions..."
chown -R apache:apache /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# Restart Apache to apply changes
systemctl restart httpd

echo "Userdata script completed successfully!"
