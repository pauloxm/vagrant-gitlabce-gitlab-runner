#!/bin/bash

# Installing using conveninence script
echo "[TASK 1] Install docker (Easy Mode)"

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh

# Installing docker-compose
echo "[TASK 2] Install docker-compose (Easy Mode)"

mkdir -p /usr/local/lib/docker/cli-plugins/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose

echo "[TASK 3] Configure docker-compose"

sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
sudo ln -s /usr/local/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose

# Configuring requisites
echo "[TASK 4] Enable docker command to vagrant user"

sudo usermod -aG docker vagrant

echo "[TASK 5] run gitlab container"

export GITLAB_HOME=/srv/gitlab
export GITLAB_HOME=/vagrant/gitlab


docker run -d --name gitlab --hostname gitlab.example.com \
  --publish 443:443 --publish 80:80 --publish 2200:22 \
  -e GITLAB_ROOT_EMAIL="root@local" -e GITLAB_ROOT_PASSWORD="senhasegura" \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab/gitlab-ce:latest

echo "[TASK 6] run gitlab-runner container"

docker run -d --name gitlab-runner --hostname gitlab-runner \
           --publish 2201:22 \
           --restart always \
           -v /srv/gitlab-runner/config:/etc/gitlab-runner \
           -v /var/run/docker.sock:/var/run/docker.sock \
           gitlab/gitlab-runner:latest
