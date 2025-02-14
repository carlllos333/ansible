pipeline {
    agent any
    
    parameters {
        string(name: 'ID', defaultValue: 'root', description: '')
        string(name: 'IPADDR1', defaultValue: '192.168.240.136', description: 'docker')
        string(name: 'IPADDR2', defaultValue: '192.168.240.134', description: 'apache')
    }

    stages {
        stage('installaiton mise a jour sur le serveur docker') {
            steps {
                sh '''
                ssh $ID@$IPADDR1 "sudo apt-get update"
                '''
            }
        }
        stage('installaiton docker') {
            steps {
                sh '''
                ssh $ID@$IPADDR1 "sudo apt-get install -y docker docker-compose"
                '''
            }
        }
        stage('installaiton portainer') {
            steps {
                sh '''
                   ssh $ID@$IPADDR1 "docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.21.5"
                '''
            }
        }

        stage('création conteneurs docker') {
            steps {
                sh '''
                    mkdir -p docker 
                    mkdir -p docker/reversproxy
                    mkdir -p docker/wordpress
cat << 'EOF' > docker/reversproxy/docker-compose.yml
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF

cat << 'EOF' > docker/wordpress/docker-compose.yml
services:

  wordpress:
    image: wordpress
    restart: always
    ports:
      - 8080:80
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: exampleuser
      WORDPRESS_DB_PASSWORD: examplepass
      WORDPRESS_DB_NAME: exampledb
    volumes:
      - wordpress:/var/www/html

  db:
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_DATABASE: exampledb
      MYSQL_USER: exampleuser
      MYSQL_PASSWORD: examplepass
      MYSQL_RANDOM_ROOT_PASSWORD: '1'
    volumes:
      - db:/var/lib/mysql

volumes:
  wordpress:
  db:
EOF

                scp -r docker $ID@$IPADDR1:/
                ssh $ID@$IPADDR1 "docker-compose -f /docker/reversproxy/docker-compose.yml up -d"
                ssh $ID@$IPADDR1 "docker-compose -f /docker/wordpress/docker-compose.yml up -d"
                '''
            }
        }
        stage('Création du script pour installer FreshRSS sur le serveur apache') {
            steps {
                sh '''
cat << 'EOF' > script.sh
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
EOF
                '''
            }
        }
        stage('Envoie du script sur le serveur apache et gestion des permissions') {
            steps {
                sh '''
                scp script.sh $ID@$IPADDR2:/tmp/script.sh
                ssh $ID@$IPADDR2 "chmod +x /tmp/script.sh"
                '''
            }
        }
        stage('Execution du script') {
            steps {
                sh '''
                ssh $ID@$IPADDR2 "bash /tmp/script.sh"
                '''
            }
        }
    }
}