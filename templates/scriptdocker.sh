#!/bin/bash

sudo apt update
sudo apt install -y docker docker-compose
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.21.5
docker-compose -f /docker/reversproxy/docker-compose.yml up -d
docker-compose -f /docker/wordpress/docker-compose.yml up -d
