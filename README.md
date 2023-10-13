# fswepp-docker

Dockerized fswepp website


## Building container

```
sudo docker-compose build
```

## Daemonizing

1. Put service file in `/etc/systemd/services`
2. enable serivce  `sudo systemctl enable docker-compose-fswepp`


## Service Management

### Starting Service
```
sudo systemctl start docker-compose-fswepp
```

### Stopping Service
```
sudo systemctl stop docker-compose-fswepp
```

### Restarting Service
```
sudo systemctl restart docker-compose-fswepp
```

## Docker Interactive Shell

```
sudo docker exec -it fswepp-docker-fswepp-1 /bin/bash
```

## Configuration

1. Check reverse proxy configuraiton in caddyfile
2. make `caddy_data` directory
3. change host name in `var/www/fswepp/wepphost`
