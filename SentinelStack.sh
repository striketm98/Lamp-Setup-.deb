#!/bin/bash

# --- Configuration Variables ---
DB_ROOT_PASS="MyNewPass"
DB_USER="newuser"
DB_PASS="password123"
DB_NAME="mydemo"
SERVER_IP="13.126.208.136"
APP_DIR="/var/www/html/Club-Manager"

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "🛡️ Starting Security-Hardened LAMP Deployment..."

# 1. Update & Base Packages
apt update && apt upgrade -y
apt install -y apache2 mariadb-server openssl wget curl

# 2. PHP Stack Installation
echo "🐘 Installing PHP modules..."
apt install -y php php-{tcpdf,cgi,pear,mbstring,common,phpseclib,mysql,cli,fpm,json,zip,gd,intl,curl,xml,tidy,soap,bcmath,xmlrpc} libapache2-mod-php

# 3. Database Automation
echo "🗄️ Configuring MariaDB..."
# Secure installation automation
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASS';"
mysql -u root -p"$DB_ROOT_PASS" -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -p"$DB_ROOT_PASS" -e "DROP DATABASE IF EXISTS test;"
mysql -u root -p"$DB_ROOT_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -u root -p"$DB_ROOT_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -u root -p"$DB_ROOT_PASS" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mysql -u root -p"$DB_ROOT_PASS" -e "FLUSH PRIVILEGES;"

# 4. phpMyAdmin Automated Install
echo "💎 Deploying phpMyAdmin..."
DATA="$(wget https://www.phpmyadmin.net/home_page/version.txt -q -O-)"
VERSION="$(echo $DATA | cut -d ' ' -f 1)"
wget -q https://files.phpmyadmin.net/phpMyAdmin/${VERSION}/phpMyAdmin-${VERSION}-all-languages.tar.gz
tar -xzf phpMyAdmin-${VERSION}-all-languages.tar.gz
mv phpMyAdmin-${VERSION}-all-languages /usr/share/phpmyadmin
rm phpMyAdmin-${VERSION}-all-languages.tar.gz

mkdir -p /var/lib/phpmyadmin/tmp
chown -R www-data:www-data /var/lib/phpmyadmin
cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php

# Automatic Config Editing (No VIM needed)
sed -i "s/\$cfg\['blowfish_secret'\] = '';/\$cfg\['blowfish_secret'\] = 'H2OxcGXxflSd8JwrwVlh6KW6s2rER63i';/" /usr/share/phpmyadmin/config.inc.php
echo "\$cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';" >> /usr/share/phpmyadmin/config.inc.php

# 5. Apache Configurations (phpMyAdmin & VirtualHost)
echo "🌐 Configuring Apache..."
cat <<EOF > /etc/apache2/conf-enabled/phpmyadmin.conf
Alias /phpmyadmin /usr/share/phpmyadmin
<Directory /usr/share/phpmyadmin>
    Options SymLinksIfOwnerMatch
    DirectoryIndex index.php
    Require all granted
</Directory>
EOF

# SSL Generation (Non-interactive)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/server.key \
-out /etc/ssl/certs/server.crt \
-subj "/C=AU/ST=Some-State/L=City/O=Internet/OU=Section/CN=$SERVER_IP"

# VirtualHost Configuration
cat <<EOF > /etc/apache2/sites-available/clubmaster.conf
<VirtualHost *:80>
    ServerName $SERVER_IP
    Redirect permanent / https://$SERVER_IP/
</VirtualHost>

<VirtualHost *:443>
    ServerName $SERVER_IP
    DocumentRoot $APP_DIR
    SSLEngine on
    SSLCertificateKeyFile /etc/ssl/private/server.key
    SSLCertificateFile /etc/ssl/certs/server.crt
    <Directory $APP_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# 6. Final Permissions & Service Restart
echo "⚙️ Finalizing environment..."
mkdir -p $APP_DIR
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

a2enmod ssl rewrite mpm_prefork
# Ensure the correct PHP version is enabled (adjusting for common 20.04 defaults)
a2enmod php$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
a2ensite clubmaster.conf
a2dissite 000-default.conf

systemctl restart apache2
systemctl restart mysql

echo "✅ Deployment Complete! Access your app at https://$SERVER_IP"
