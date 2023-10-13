# fswepp-docker


## Build container

```
sudo docker-compose build
```

## Daemonizing

1. Put service file in `/etc/systemd/services`
2. enable serivce  `sudo systemctl enable docker-compose-fswepp`

## Starting/Stoping service 


```
sudo systemctl start docker-compose-fswepp
sudo systemctl stop docker-compose-fswepp
sudo systemctl restart docker-compose-fswepp
```


## Docker Interactive Shell

```
sudo docker exec -it fswepp-docker-fswepp-1 /bin/bash
```
