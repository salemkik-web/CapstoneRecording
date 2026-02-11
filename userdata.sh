 #!/bin/bash

# Log all output for debugging
exec > /var/log/user-data.log 2>&1
set -e
echo "Starting userdata script..."

# Update OS
sudo yum update -y

sudo yum install -y mariadb

# Enable PHP 8 via Amazon Linux Extras (Amazon Linux 2 only)
sudo amazon-linux-extras enable php8.0
sudo yum clean metadata

# Install Apache, PHP, required PHP extensions, and tools
sudo yum install -y httpd mod_ssl php php-cli php-mysqlnd php-gd php-curl php-mbstring php-xml php-json wget unzip curl

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Ensure Apache listens on all interfaces
sudo sed -i 's/^Listen .*/Listen 0.0.0.0:80/' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd

# Remove default Apache test page and welcome.conf
sudo rm -f /var/www/html/index.html
sudo rm -f /etc/httpd/conf.d/welcome.conf

# Terraform-provided DB variables
DBName="${db_name}"
DBUser="${db_user}"
DBPassword="${db_password}"
DBHost="${db_host}"

# Wait for RDS to be reachable
echo "Waiting for RDS at $DBHost..."
until mysql -h "$DBHost" -u "$DBUser" -p"$DBPassword" -e "CREATE DATABASE IF NOT EXISTS $DBName;" >/dev/null 2>&1; do
  echo "$(date) - RDS not ready yet, retrying in 15s..."
  sleep 15
done
echo "RDS is reachable and DB exists!"

# Navigate to web root
cd /var/www/html

echo "Downloading WordPress..."
for i in {1..5}; do
  curl -fL https://wordpress.org/latest.tar.gz -o latest.tar.gz && break
  echo "Retry $i failed... waiting 10s"
  sleep 10
done

for i in {1..3}; do
  sudo tar -xzf latest.tar.gz && break
  echo "$(date) - Extraction failed, retrying in 5s..."
  sleep 5
done

# CLEAN + MOVE WORDPRESS (FIXED LOGIC)
if [ -d wordpress ]; then
  sudo rm -rf /var/www/html/*
  sudo mv wordpress/* /var/www/html/
  sudo rm -rf wordpress latest.tar.gz
else
  echo "WordPress directory not found. Download or extract failed."
  exit 1
fi
# Configure WordPress
echo "Configuring wp-config.php..."
if [ ! -f wp-config.php ]; then
  sudo cp wp-config-sample.php wp-config.php
  sudo sed -i "s/database_name_here/$DBName/g" wp-config.php
  sudo sed -i "s/username_here/$DBUser/g" wp-config.php
  sudo sed -i "s/password_here/$DBPassword/g" wp-config.php
  sudo sed -i "s/localhost/$DBHost/g" wp-config.php
fi

# Wait until WordPress is ready
echo "Waiting for WordPress to be ready..."
until curl -s http://localhost/index.php >/dev/null 2>&1; do
  echo "$(date) - WordPress not ready yet, retrying in 10s..."
  sleep 10
done
echo "WordPress is ready!"

sleep 10

# Test DB connection
echo "Testing WordPress DB connection..."
until php -r "include 'wp-config.php'; \$link = @mysqli_connect('$DBHost', '$DBUser', '$DBPassword', '$DBName') or exit(1);" >/dev/null 2>&1; do
  echo "$(date) - WordPress DB connection not ready, retrying..."
  sleep 10
done
echo "WordPress DB connection successful!"

# Set correct permissions
echo "Setting file permissions..."
sudo chown -R apache:apache /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

# Restart Apache
sudo systemctl restart httpd

echo "Userdata script completed successfully!"
