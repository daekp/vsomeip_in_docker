#!/bin/sh

docker build --no-cache -t vsomip_server .
docker build --no-cache -t vsomip_client .

# docker run -it vsomip_server
# docker run -it vsomip_client

# sudo docker network create --gateway 172.20.0.1 --subnet 172.20.0.0/16 myBridge
# sudo docker run --network myBridge --ip 172.20.0.2 -p 30490:30490 -it vsomip_server
# sudo docker run --network myBridge --ip 172.20.0.3 -p 30490:30490 -it vsomip_client
