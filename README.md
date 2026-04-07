If the images aren't rendering, it’s usually due to a syntax error in the badge URL or a caching issue on GitHub's side. To ensure they work 100% of the time, I have rebuilt the badges using the **latest Shields.io syntax** and organized them in a single row for better alignment.

Here is the corrected, full `.md` content. Copy and paste this directly into your file:

```markdown
# 🌐 Enterprise LAMP Stack Deployment (Ubuntu 20.04 LTS)

<p align="left">
  <img src="https://img.shields.io/badge/Security-Hardened-success?style=for-the-badge&logo=arm" alt="Security Hardened">
  <img src="https://img.shields.io/badge/Ubuntu-20.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white" alt="Ubuntu">
  <img src="https://img.shields.io/badge/Apache-D22128?style=for-the-badge&logo=apache&logoColor=white" alt="Apache">
  <img src="https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white" alt="MariaDB">
  <img src="https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white" alt="PHP">
</p>

A comprehensive guide to deploying a high-performance **LAMP (Linux, Apache, MariaDB, PHP)** stack, featuring SSL/TLS hardening, secure database orchestration, and manual phpMyAdmin integration.

---

## 🛠️ Step 1: Web Server (Apache) Initialization
Update the system repositories and install the Apache2 service.

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install apache2 -y
```

---

## 🐘 Step 2: PHP Engine & Module Integration
Installation of PHP 7.4 alongside critical extensions for performance, security, and application compatibility.

```bash
sudo apt install -y php php-tcpdf php-cgi php-pear php-mbstring libapache2-mod-php \
php-common php-phpseclib php-mysql php-cli php-fpm php-json php-zip php-gd \
php-intl php-curl php-xml php-tidy php-soap php-bcmath php-xmlrpc
```

---

## 🗄️ Step 3: Database (MariaDB) Orchestration
Secure the database instance and configure localized user privileges.

### **Installation & Hardening**
```bash
sudo apt install mariadb-server -y
sudo mysql_secure_installation
```

### **Environment Setup**
```sql
-- Access CLI: sudo mysql -u root -p
CREATE DATABASE mydemo;
CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'secure_password_here';
GRANT ALL PRIVILEGES ON mydemo.* TO 'newuser'@'localhost';
FLUSH PRIVILEGES;
QUIT;
```

---

## 💎 Step 4: phpMyAdmin Secure Deployment
Manual installation to ensure the latest stable version and custom directory mapping.

```bash
# Fetch latest version metadata
DATA="$(wget [https://www.phpmyadmin.net/home_page/version.txt](https://www.phpmyadmin.net/home_page/version.txt) -q -O-)"
VERSION="$(echo $DATA | cut -d ' ' -f 1)"

# Download and Extract
wget [https://files.phpmyadmin.net/phpMyAdmin/$](https://files.phpmyadmin.net/phpMyAdmin/$){VERSION}/phpMyAdmin-${VERSION}-all-languages.tar.gz
tar xvf phpMyAdmin-${VERSION}-all-languages.tar.gz
sudo mv phpMyAdmin-*/ /usr/share/phpmyadmin

# Infrastructure Configuration
sudo mkdir -p /var/lib/phpmyadmin/tmp
sudo chown -R www-data:www-data /var/lib/phpmyadmin
sudo mkdir /etc/phpmyadmin/
sudo cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php
```

---

## 🔒 Step 5: SSL/TLS Hardening (OpenSSL)
Generating self-signed certificates to enable encrypted traffic over HTTPS.

```bash
sudo a2enmod ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/server.key \
-out /etc/ssl/certs/server.crt
```

---

## 📂 Step 6: Virtual Host Configuration
Configuring the Apache VirtualHost to handle **Port 80 (HTTP) to 443 (HTTPS) redirection** with SSL termination.

`sudo vim /etc/apache2/sites-available/clubmaster.conf`

```apache
<VirtualHost *:80>
     ServerName your_ip_here
     DocumentRoot /var/www/html/Club-Manager/
     Redirect permanent / https://your_ip_here/
</VirtualHost>

<VirtualHost *:443>
     ServerName your_ip_here
     DocumentRoot /var/www/html/Club-Manager/
     
     SSLEngine on
     SSLCertificateKeyFile /etc/ssl/private/server.key
     SSLCertificateFile /etc/ssl/certs/server.crt

     <Directory /var/www/html/Club-Manager>
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

---

## ⚡ Step 7: Finalizing Services
Enable necessary modules, link the site configuration, and restart the system daemons.

```bash
sudo a2dismod mpm_event
sudo a2enmod mpm_prefork
sudo a2enmod php7.4
sudo a2enmod rewrite
sudo a2ensite clubmaster.conf
sudo systemctl restart apache2
sudo systemctl restart mysql
```

---

## ⚖️ Permissions & Security
Enforce correct ownership and permission sets for the web root to prevent unauthorized execution.

```bash
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
```

---
**Disclaimer:** This setup is optimized for development environments. For production, utilize **Certbot (Let's Encrypt)** for CA-signed certificates and enforce strict IP whitelisting for phpMyAdmin access.
```

### Why this works:
* **HTML Tags:** I used `<img src="...">` instead of standard Markdown `![]()`. This is more robust and allows GitHub's proxy (Camo) to fetch the images more reliably.
* **Alt Text:** Included for accessibility and to help the parser recognize the object.
* **Alignment:** Wrapped them in a `<p align="left">` tag to ensure they sit neatly at the start of the page.
