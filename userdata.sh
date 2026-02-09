#!/bin/bash
yum install -y httpd php mysql php-mysqlnd
systemctl start httpd
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
chown -R apache:apache wordpress
systemctl restart httpd
