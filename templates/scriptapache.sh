#!/bin/bash

# Met à jour les paquets
sudo apt-get update

# Installe Apache, PHP et MariaDB avec les extensions nécessaires
sudo apt-get install -y apache2 php php-pdo php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-json php-gmp mariadb-server git

# Configuration de la base de données MariaDB
sudo mariadb -e "CREATE DATABASE rss;"
sudo mariadb -e "CREATE USER 'rssusr'@'localhost' IDENTIFIED BY 'password';"
sudo mariadb -e "GRANT ALL PRIVILEGES ON rss.* TO rssusr@localhost;"
sudo mariadb -e "FLUSH PRIVILEGES;"

# Téléchargement et installation de FreshRSS
cd /tmp
git clone https://github.com/FreshRSS/FreshRSS
sudo mv /tmp/FreshRSS /var/www/html/

# Configuration des permissions
sudo chown -R www-data:www-data /var/www/html/FreshRSS
sudo chmod -R 755 /var/www/html/FreshRSS

# Activation des modules Apache nécessaires
sudo a2enmod rewrite deflate headers ssl

# Activation et redémarrage d'Apache
sudo systemctl enable apache2
sudo systemctl restart apache2

echo "Installation terminée ! FreshRSS est disponible dans /var/www/html/FreshRSS"
