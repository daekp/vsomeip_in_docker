#!/bin/sh

docker build --no-cache -t vsomip_server .
# docker build -t vsomip_client 

docker run -it vsomip_server
# sudo docker run -d vsomip_client
