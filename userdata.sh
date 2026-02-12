 #!/bin/bash

# Log all output for debugging
exec > /var/log/user-data.log 2>&1
set -e
echo "Starting userdata script..."

# Update OS
yum update -y

# Install MariaDB client (for RDS connectivity)
yum install -y mariadb

# Enable PHP 8 via Amazon Linux Extras (Amazon Linux 2 only)
amazon-linux-extras enable php8.0
yum clean metadata

# Install Apache, PHP, required PHP extensions, and tools
yum install -y httpd mod_ssl php php-cli php-mysqlnd php-gd php-curl php-mbstring php-xml php-json wget unzip curl

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
 ALB_DNS="${alb_dns}"

# Wait for RDS to be reachable
echo "Waiting for RDS at $DBHost..."
until mysql -h "$DBHost" -u "$DBUser" -p"$DBPassword" -e "CREATE DATABASE IF NOT EXISTS $DBName;" >/dev/null 2>&1; do
  echo "$(date) - RDS not ready yet, retrying in 15s..."
  sleep 15
done
echo "RDS is reachable and DB exists!"

# Navigate to web root
cd /var/www/html

# Download WordPress with retry logic
echo "Downloading WordPress..."
for i in {1..5}; do
  curl -fL https://wordpress.org/latest.tar.gz -o latest.tar.gz && break
  echo "Retry $i failed, waiting 10s..."
  sleep 10
  if [ $i -eq 5 ]; then
    echo "Failed to download WordPress. Exiting."
    exit 1
  fi
done

# Extract WordPress
for i in {1..3}; do
  tar -xzf latest.tar.gz && break
  echo "$(date) - Extraction failed, retrying in 5s..."
  sleep 5
  if [ $i -eq 3 ]; then
    echo "WordPress extraction failed. Exiting."
    exit 1
  fi
done


# Move WordPress files safely
if [ -d wordpress ]; then
  rm -rf /var/www/html/*
  rsync -av wordpress/ /var/www/html/
  rm -rf wordpress latest.tar.gz
else
  echo "WordPress directory not found. Exiting."
  exit 1
fi


# Configure WordPress
echo "Configuring wp-config.php..."
if [ ! -f wp-config.php ]; then
  cp wp-config-sample.php wp-config.php
  sed -i "s/database_name_here/$DBName/g" wp-config.php
  sed -i "s/username_here/$DBUser/g" wp-config.php
  sed -i "s/password_here/$DBPassword/g" wp-config.php
  sed -i "s/localhost/$DBHost/g" wp-config.php
fi

# Install WP-CLI
echo "Installing WP-CLI..."
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Wait until WordPress is ready
echo "Waiting for WordPress to be ready..."
until curl -s http://localhost/index.php >/dev/null 2>&1; do
  echo "$(date) - WordPress not ready yet, retrying in 10s..."
  sleep 10
done
echo "WordPress is ready!"

# Test DB connection
echo "Testing WordPress DB connection..."
until php -r "include 'wp-config.php'; \$link = @mysqli_connect('$DBHost', '$DBUser', '$DBPassword', '$DBName') or exit(1);" >/dev/null 2>&1; do
  echo "$(date) - WordPress DB connection not ready, retrying..."
  sleep 10
done
echo "WordPress DB connection successful!"

# Wait until WordPress DB is reachable
until wp db check --allow-root >/dev/null 2>&1; do
  echo "$(date) - WordPress DB not ready for WP-CLI, retrying..."
  sleep 10
done

# Then set siteurl and home
wp option update siteurl "http://$ALB_DNS" --allow-root
wp option update home "http://$ALB_DNS" --allow-root

# Set correct permissions
echo "Setting file permissions..."
chown -R apache:apache /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# Restart Apache
systemctl restart httpd

echo "Userdata script completed successfully!"
