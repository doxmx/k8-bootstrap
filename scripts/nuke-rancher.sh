# This is used to nuke a rancher node
if [ -x "$(command -v docker)" ]; then {
  docker kill $(docker ps -aq)
  docker rm $(docker ps -aq)
  docker volume rm $(docker volume ls -q)
  docker rmi $(docker images -q)
}; fi

# Destroy the rancher artifacts
rm -rf /var/lib/rancher
rm -rf /var/etcd/backups/*
