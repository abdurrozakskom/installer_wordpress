#!/bin/bash
# =========================================================
# Auto Installer WordPress on LAMP Stack
# by Abdur Rozak, SMKS YASMIDA Ambarawa
# GitHub: https://github.com/abdurrozakskom
# License: MIT
# =========================================================

# Warna
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}=== Auto Installer LAMP + WordPress ===${NC}"

# 1. Update & Upgrade
echo -e "${GREEN}[1/6] Update & Upgrade...${NC}"
sudo apt update && sudo apt upgrade -y

# 2. Install Apache
echo -e "${GREEN}[2/6] Install Apache2...${NC}"
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2

# 3. Install MariaDB
echo -e "${GREEN}[3/6] Install MariaDB...${NC}"
sudo apt install mariadb-server mariadb-client -y
sudo systemctl enable mariadb
sudo systemctl start mariadb

# 3a. Setup Database
DB_NAME="wordpress_db"
DB_USER="wp_user"
DB_PASS="wp_password"

echo -e "${CYAN}Membuat Database WordPress...${NC}"
sudo mysql -e "CREATE DATABASE ${DB_NAME};"
sudo mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# 4. Install PHP
echo -e "${GREEN}[4/6] Install PHP & Modules...${NC}"
sudo apt install php php-mysql php-xml php-gd php-curl php-mbstring php-xmlrpc libapache2-mod-php -y
sudo systemctl restart apache2

# 5. Install WordPress
echo -e "${GREEN}[5/6] Download & Install WordPress...${NC}"
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
sudo mv wordpress /var/www/html/

# 6. Konfigurasi Permission
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# 7. Konfigurasi Apache VirtualHost
echo -e "${GREEN}[6/6] Konfigurasi Apache untuk WordPress...${NC}"
VHOST="/etc/apache2/sites-available/wordpress.conf"

cat <<EOF | sudo tee $VHOST
<VirtualHost *:80>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/html/wordpress
    ServerName example.com
    ServerAlias www.example.com

    <Directory /var/www/html/wordpress/>
        AllowOverride All
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/wordpress_error.log
    CustomLog \${APACHE_LOG_DIR}/wordpress_access.log combined
</VirtualHost>
EOF

# Enable site & rewrite
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

echo -e "${CYAN}==============================================${NC}"
echo -e "${GREEN}WordPress berhasil diinstall!${NC}"
echo -e "URL   : http://server-ip/"
echo -e "DB    : ${DB_NAME}"
echo -e "USER  : ${DB_USER}"
echo -e "PASS  : ${DB_PASS}"
echo -e "${CYAN}==============================================${NC}"
