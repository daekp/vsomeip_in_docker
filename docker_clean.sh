#!/bin/bash


sudo docker rm -f $(sudo docker ps -aq)
sudo docker rmi $(sudo docker images -q)
