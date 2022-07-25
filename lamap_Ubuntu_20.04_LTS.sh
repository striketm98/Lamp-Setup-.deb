#! /bin/bash
sudo apt update
sudo apt-get install apache2 -y
sudo mv -f Club-Master /var/www/html
sudo apt-get install -y php php-tcpdf php-cgi php-pear php-mbstring libapache2-mod-php php-common php-phpseclib php-mysql
sudo apt install php php-{cli,fpm,json,common,mysql,zip,gd,intl,mbstring,curl,xml,pear,tidy,soap,bcmath,xmlrpc}
sudo apt install mariadb-server
sudo mysql_secure_installation
ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass';
sudo mysql -u root -p123
DATA="$(wget https://www.phpmyadmin.net/home_page/version.txt -q -O-)"
URL="$(echo $DATA | cut -d ' ' -f 3)"
VERSION="$(echo $DATA | cut -d ' ' -f 1)"
wget https://files.phpmyadmin.net/phpMyAdmin/${VERSION}/phpMyAdmin-${VERSION}-all-languages.tar.gz
wget https://files.phpmyadmin.net/phpMyAdmin/${VERSION}/phpMyAdmin-${VERSION}-english.tar.gz
tar xvf phpMyAdmin-${VERSION}-all-languages.tar.gz
sudo mv phpMyAdmin-*/ /usr/share/phpmyadmin
sudo mkdir -p /var/lib/phpmyadmin/tmp;sudo chown -R www-data:www-data /var/lib/phpmyadmin;
sudo mkdir /etc/phpmyadmin/
sudo cp /usr/share/phpmyadmin/config.sample.inc.php  /usr/share/phpmyadmin/config.inc.php
sudo vim /usr/share/phpmyadmin/config.inc.php 
	$cfg['blowfish_secret'] = 'H2OxcGXxflSd8JwrwVlh6KW6s2rER63i';
	$cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';

sudo tee /etc/apache2/conf-enabled/phpmyadmin.conf <<EOF

Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options SymLinksIfOwnerMatch
    DirectoryIndex index.php
    Order Allow,Deny
    Allow from 127.0.0.1
    Allow form 192.168.29.178

    <IfModule mod_php5.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/php/php-php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/:/usr/share/doc/phpmyadmin/:/usr/share/php/phpseclib/
        php_admin_value mbstring.func_overload 0
    </IfModule>
    <IfModule mod_php.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/php/php-php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/:/usr/share/doc/phpmyadmin/:/usr/share/php/phpseclib/
        php_admin_value mbstring.func_overload 0
    </IfModule>

</Directory>

# Authorize for setup
<Directory /usr/share/phpmyadmin/setup>
    <IfModule mod_authz_core.c>
        <IfModule mod_authn_file.c>
            AuthType Basic
            AuthName "phpMyAdmin Setup"
            AuthUserFile /etc/phpmyadmin/htpasswd.setup
        </IfModule>
        Require valid-user
    </IfModule>
</Directory>

# Disallow web access to directories that don't need it
<Directory /usr/share/phpmyadmin/templates>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>
EOF
sudo systemctl restart apache2

sudo systemctl restart mysql
sudo chown -R www-data:www-data /var/www/html/;sudo chmod -R 755 /var/www/html/
sudo lsb_release -a
sudo a2enmod ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/server.yourdomain.com.key -out /etc/ssl/certs/server.yourdomain.com.crt
sudo tee /etc/apache2/sites-available/clubmaster.conf <<EOF

<VirtualHost *:80>
     ServerName 13.126.208.136
     ServerAlias 13.126.208.136
     ServerAdmin admin@13.126.208.136
     DocumentRoot /var/www/html/Club-Manager/
     Redirect / https://13.126.208.136
     CustomLog ${APACHE_LOG_DIR}/access.log combined
     ErrorLog ${APACHE_LOG_DIR}/error.log

      <Directory /var/www/html/clubmanager>
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
            RewriteEngine on
            RewriteBase /
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteRule ^(.*)$ index.php?q=$1 [L,QSA]
   </Directory>
</VirtualHost>
<VirtualHost *:443>
     ServerName 13.126.208.136
     ServerAlias 13.126.208.136
     ServerAdmin admin@13.126.208.136
     DocumentRoot /var/www/html/Club-Manager/
     SSLEngine on
     SSLCertificateKeyFile /etc/ssl/private/server.yourdomain.com.key
     SSLCertificateFile /etc/ssl/certs/server.yourdomain.com.crt
     CustomLog ${APACHE_LOG_DIR}/access.log combined
     ErrorLog ${APACHE_LOG_DIR}/error.log
      <Directory /var/www/html/clubmanager>
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
            RewriteEngine on
            RewriteBase /
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteRule ^(.*)$ index.php?q=$1 [L,QSA]
   </Directory>
</VirtualHost>
EOF
sudo apache2ctl -t 
sudo a2dismod mpm_event
sudo a2enmod mpm_prefork
sudo sudo a2enmod php7.4
sudo a2enmod rewrite
sudo a2ensite clubmaster.conf
sudo systemctl reload apache2
