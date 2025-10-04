#!/bin/bash
# =========================================================
# Auto Installer WordPress + LAMP Stack (Optimized)
# with Apache + PHP-FPM + MariaDB Tuning
# by Abdur Rozak, SMKS YASMIDA Ambarawa
# GitHub: https://github.com/abdurrozakskom
# GitHub   : https://github.com/abdurrozakskom
# YouTube  : https://www.youtube.com/@AbdurRozakSKom
# Instagram: https://instagram.com/abdurrozak.skom
# Facebook : https://facebook.com/abdurrozak.skom
# TikTok   : https://tiktok.com/abdurrozak.skom
# Threads  : https://threads.com/@abdurrozak.skom
# Lynk.id  : https://lynk.id/abdurrozak.skom
# Donasi:
# • Saweria  : https://saweria.co/abdurrozakskom
# • Trakteer : https://trakteer.id/abdurrozakskom/gift
# • Paypal   : https://paypal.me/abdurrozakskom
# License: MIT
# =========================================================

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}=== Auto Installer LAMP + WordPress (Optimized) ===${NC}"

# --- Input Interaktif ---
read -p "Masukkan Nama Database (default: wordpress_db): " DB_NAME
DB_NAME=${DB_NAME:-wordpress_db}

read -p "Masukkan Username Database (default: wp_user): " DB_USER
DB_USER=${DB_USER:-wp_user}

read -sp "Masukkan Password Database (default: wp_password): " DB_PASS
DB_PASS=${DB_PASS:-wp_password}
echo ""

read -p "Masukkan Domain/ServerName (contoh: example.com, kosongkan untuk pakai IP server): " DOMAIN
DOMAIN=${DOMAIN:-_}

echo -e "${CYAN}Database: $DB_NAME | User: $DB_USER | Domain: $DOMAIN${NC}"

# --- Update & Install ---
echo -e "${GREEN}[1/7] Update system...${NC}"
sudo apt update && sudo apt upgrade -y

echo -e "${GREEN}[2/7] Install Apache...${NC}"
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2

echo -e "${GREEN}[3/7] Install MariaDB...${NC}"
sudo apt install mariadb-server mariadb-client -y
sudo systemctl enable mariadb
sudo systemctl start mariadb

# --- Setup Database ---
echo -e "${CYAN}Membuat Database WordPress...${NC}"
sudo mysql -e "CREATE DATABASE ${DB_NAME};"
sudo mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo -e "${GREEN}[4/7] Install PHP-FPM & Modules...${NC}"
sudo apt install php-fpm php-mysql php-xml php-gd php-curl php-mbstring php-xmlrpc unzip -y

# Enable PHP-FPM in Apache
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php*-fpm

# Restart service
sudo systemctl restart apache2
sudo systemctl restart php*-fpm

# --- Install WordPress ---
echo -e "${GREEN}[5/7] Install WordPress...${NC}"
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
sudo mv wordpress /var/www/html/
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# --- Apache VirtualHost ---
echo -e "${GREEN}[6/7] Konfigurasi Apache VirtualHost...${NC}"
VHOST="/etc/apache2/sites-available/wordpress.conf"

cat <<EOF | sudo tee $VHOST
<VirtualHost *:80>
    ServerAdmin admin@${DOMAIN}
    ServerName ${DOMAIN}
    DocumentRoot /var/www/html/wordpress

    <Directory /var/www/html/wordpress/>
        AllowOverride All
        Require all granted
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php/php-fpm.sock|fcgi://localhost/"
    </FilesMatch>

    ErrorLog \${APACHE_LOG_DIR}/wordpress_error.log
    CustomLog \${APACHE_LOG_DIR}/wordpress_access.log combined
</VirtualHost>
EOF

sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# =========================================================
# === TUNING BAGIAN SERVER ===
# =========================================================

echo -e "${GREEN}[7/7] Tuning Server...${NC}"

# --- Ambil jumlah CPU & RAM ---
CPU_CORES=$(nproc)
TOTAL_RAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_RAM_MB=$((TOTAL_RAM / 1024))

echo -e "${CYAN}CPU: ${CPU_CORES} cores | RAM: ${TOTAL_RAM_MB} MB${NC}"

# --- Tuning Apache MPM Event ---
APACHE_MPM_CONF="/etc/apache2/mods-available/mpm_event.conf"
sudo sed -i "s/StartServers.*/StartServers $CPU_CORES/" $APACHE_MPM_CONF
sudo sed -i "s/MinSpareThreads.*/MinSpareThreads 25/" $APACHE_MPM_CONF
sudo sed -i "s/MaxSpareThreads.*/MaxSpareThreads 75/" $APACHE_MPM_CONF
sudo sed -i "s/ThreadLimit.*/ThreadLimit 64/" $APACHE_MPM_CONF
sudo sed -i "s/ThreadsPerChild.*/ThreadsPerChild 25/" $APACHE_MPM_CONF
sudo sed -i "s/MaxRequestWorkers.*/MaxRequestWorkers $((CPU_CORES*50))/" $APACHE_MPM_CONF
sudo sed -i "s/MaxConnectionsPerChild.*/MaxConnectionsPerChild 1000/" $APACHE_MPM_CONF

# --- Tuning PHP-FPM ---
PHP_FPM_POOL="/etc/php/*/fpm/pool.d/www.conf"
sudo sed -i "s/^pm = .*/pm = dynamic/" $PHP_FPM_POOL
sudo sed -i "s/^pm.max_children.*/pm.max_children = $((TOTAL_RAM_MB / 32))/" $PHP_FPM_POOL
sudo sed -i "s/^pm.start_servers.*/pm.start_servers = $((CPU_CORES*2))/" $PHP_FPM_POOL
sudo sed -i "s/^pm.min_spare_servers.*/pm.min_spare_servers = $CPU_CORES/" $PHP_FPM_POOL
sudo sed -i "s/^pm.max_spare_servers.*/pm.max_spare_servers = $((CPU_CORES*4))/" $PHP_FPM_POOL

# --- Tuning MariaDB ---
MY_CNF="/etc/mysql/mariadb.conf.d/99-tuning.cnf"
cat <<EOF | sudo tee $MY_CNF
[mysqld]
innodb_buffer_pool_size = $((TOTAL_RAM_MB * 60 / 100))M
innodb_log_file_size = 256M
innodb_flush_method = O_DIRECT
max_connections = $((CPU_CORES*100))
query_cache_size = 0
query_cache_type = 0
tmp_table_size = 64M
max_heap_table_size = 64M
EOF

# Restart services
sudo systemctl restart apache2
sudo systemctl restart php*-fpm
sudo systemctl restart mariadb

echo -e "${CYAN}==============================================${NC}"
echo -e "${GREEN}WordPress berhasil diinstall & server sudah di-tuning!${NC}"
echo -e "URL   : http://${DOMAIN}/"
echo -e "DB    : ${DB_NAME}"
echo -e "USER  : ${DB_USER}"
echo -e "PASS  : ${DB_PASS}"
echo -e "${CYAN}==============================================${NC}"
# ---- Credit Author ----
echo -e "${CYAN}📌 Credit Author:${RESET}"
echo -e "${YELLOW}Abdur Rozak, SMKS YASMIDA Ambarawa${RESET}"
echo -e "${YELLOW}GitHub : \e]8;;https://github.com/abdurrozakskom\ahttps://github.com/abdurrozakskom\e]8;;\a${RESET}"
echo -e "${YELLOW}YouTube: \e]8;;https://www.youtube.com/@AbdurRozakSKom\ahttps://www.youtube.com/@AbdurRozakSKom\e]8;;\a${RESET}"
echo ""
# ---- Donasi ----
echo -e "${CYAN}💖 Jika script ini bermanfaat, silakan donasi untuk mendukung pengembangan:${RESET}"
echo -e "${YELLOW}• Saweria  : \e]8;;https://saweria.co/abdurrozakskom\ahttps://saweria.co/abdurrozakskom\e]8;;\a${RESET}"
echo -e "${YELLOW}• Trakteer : \e]8;;https://trakteer.id/abdurrozakskom/gift\ahttps://trakteer.id/abdurrozakskom/gift\e]8;;\a${RESET}"
echo -e "${YELLOW}• Paypal   : \e]8;;https://paypal.me/abdurrozakskom\ahttps://paypal.me/abdurrozakskom\e]8;;\a${RESET}"
echo ""
# ---- Sosial Media ----
echo -e "${CYAN}🌐 Ikuti sosial media resmi untuk update & info:${RESET}"
echo -e "${YELLOW}• GitHub    : \e]8;;https://github.com/abdurrozakskom\ahttps://github.com/abdurrozakskom\e]8;;\a${RESET}"
echo -e "${YELLOW}• Lynk.id   : \e]8;;https://lynk.id/abdurrozak.skom\ahttps://lynk.id/abdurrozak.skom\e]8;;\a${RESET}"
echo -e "${YELLOW}• Instagram : \e]8;;https://instagram.com/abdurrozak.skom\ahttps://instagram.com/abdurrozak.skom\e]8;;\a${RESET}"
echo -e "${YELLOW}• Facebook  : \e]8;;https://facebook.com/abdurrozak.skom\ahttps://facebook.com/abdurrozak.skom\e]8;;\a${RESET}"
echo -e "${YELLOW}• TikTok    : \e]8;;https://tiktok.com/abdurrozak.skom\ahttps://tiktok.com/abdurrozak.skom\e]8;;\a${RESET}"
echo -e "${YELLOW}• Threads   : \e]8;;https://threads.com/@abdurrozak.skom\ahttps://threads.com/@abdurrozak.skom\e]8;;\a${RESET}"
echo -e "${YELLOW}• YouTube   : \e]8;;https://www.youtube.com/@AbdurRozakSKom\ahttps://www.youtube.com/@AbdurRozakSKom\e]8;;\a${RESET}"