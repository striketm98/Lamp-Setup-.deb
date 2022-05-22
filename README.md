# Lamp-Setup-Ubuntu-20-04-LTS



LAMP stack is the combination of the most frequently used software packages to build dynamic websites. LAMP is an abbreviation that uses the first letter of each of the packages included in it: Linux, Apache, MariaDB, and PHP.
******************************************LAMP(LINUX APACHE MYSQL PHP)*********************************************
Installation of Lamp stack in Ubuntu 20.0.4 LTS(Server_Based) 
*******************************************************************************************************************
Specification : RAM 1GB HDD 10 GB 
*******************************************************
Remote Host Using: Vs Code/Mobaxtreme
*******************************************************
Cloud service Used: AWS
********************************************************
Apache Installation:
*********************************************************
`sudo apt update`

`sudo apt-get install apache2 -y`

Php Installation with Packages:
*************************************************************
`sudo apt-get install -y php php-tcpdf php-cgi php-pear php-mbstring libapache2-mod-php php-common php-phpseclib php-mysql

`sudo apt install php php-{cli,fpm,json,common,mysql,zip,gd,intl,mbstring,curl,xml,pear,tidy,soap,bcmath,xmlrpc}`

Mysql Installation:
****************************************************************
`sudo apt install mariadb-server`

`sudo mysql_secure_installation`

`>>Enter current password for root (enter for none): Enter

>>Set a root password? [Y/n] y

>>Remove anonymous users? [Y/n] y

>>Disallow root login remotely? [Y/n] y

>>Remove test database and access to it? [Y/n] y

>>Reload privilege tables now? [Y/n] y

sudo mysql -u root -p123

>>CREATE DATABASE mydemo;

>>CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'password';

>>GRANT ALL PRIVILEGES ON mydemo.* TO 'newuser'@'localhost';

>>QUIT`

`mysql -u newuser -password`

>>###check_db######

phpmyadmin Installation:
******************************************************************
`DATA="$(wget https://www.phpmyadmin.net/home_page/version.txt -q -O-)"`

`URL="$(echo $DATA | cut -d ' ' -f 3)"`

`VERSION="$(echo $DATA | cut -d ' ' -f 1)"`

`wget https://files.phpmyadmin.net/phpMyAdmin/${VERSION}/phpMyAdmin-${VERSION}-all-languages.tar.gz`

`wget https://files.phpmyadmin.net/phpMyAdmin/${VERSION}/phpMyAdmin-${VERSION}-english.tar.gz`

`tar xvf phpMyAdmin-${VERSION}-all-languages.tar.gz`

`sudo mv phpMyAdmin-*/ /usr/share/phpmyadmin`

`sudo mkdir -p /var/lib/phpmyadmin/tmp;sudo chown -R www-data:www-data /var/lib/phpmyadmin;`

`sudo mkdir /etc/phpmyadmin/`

`sudo cp /usr/share/phpmyadmin/config.sample.inc.php  /usr/share/phpmyadmin/config.inc.php`

add two componet:
*******************************************************************
`sudo vim /usr/share/phpmyadmin/config.sample.inc.php`

  `$cfg['blowfish_secret'] = 'H2OxcGXxflSd8JwrwVlh6KW6s2rER63i';`

  `$cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';`


`sudo vim /etc/apache2/conf-enabled/phpmyadmin.conf`
**************************add it*************************************
Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options SymLinksIfOwnerMatch
    DirectoryIndex index.php

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

Restart apache2 server:
****************************************************************
```
sudo systemctl restart apache2

sudo systemctl restart mysql
```

Permission Change:
******************************************************************

`sudo chown -R www-data:www-data /var/www/html/;sudo chmod -R 755 /var/www/html/`

open-ssl Installation:
******************************************************************
```
sudo lsb_release -a

sudo a2enmod ssl

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/server.yourdomain.com.key -out /etc/ssl/certs/server.yourdomain.com.crt

>>Country Name (2 letter code) [AU]:

>>State or Province Name (full name) [Some-State]:

>>Locality Name (eg, city) []:

>>Organization Name (eg, company) [Internet Widgits Pty Ltd]:

>>Organizational Unit Name (eg, section) []:

>>Common Name (e.g. server FQDN or YOUR name) []: 13.126.208.136

Email Address []: 
```

`sudo vim /etc/apache2/sites-available/clubmaster.conf`  


***********************************************add it****************************************
```
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

```


***************Reload all services**************************************
```sudo a2dismod mpm_event

sudo a2enmod mpm_prefork

sudo sudo a2enmod php7.4

sudo a2enmod rewrite

sudo a2ensite clubmaster.conf

sudo systemctl reload apache2
```
