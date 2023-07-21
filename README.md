# vsomeip_in_docker
This example is installing vsomeip in a Linux Docker container and implementing a simple HelloWorld service and client.

# How to Run
## Step 1. Source code clone
```
$ git clone https://github.com/daekp/vsomeip_in_docker.git
```
## Step 2. Network Configuration
### If you want communication two process in single containers
Skip this step.

### If you want communication between two containers
- vsomeip_server.json \
Enter the IP you want in the "unicast" key (The IP address of the container running the service application).
```
{ 
   "unicast" : "172.20.0.2",
    "logging" :
    {
        "level" : "debug",
        "console" : "true",
        "file" : { "enable" : "false" },
        "dlt" : "false"
    },
    "applications" :
    [
        {
           "name" : "service-sample",
            "id" : "0x1277"
        }
    ],
 
            "services" :
            [
                {
                   "service" : "0x1234",
                   "instance" : "0x5678",
                   "unreliable" : "30490"
                }
            ],
 
   "routing" : "service-sample",
   "service-discovery" :
    {
       "enable" : "true",
       "multicast" : "224.244.224.245",
       "port" : "30490",
       "protocol" : "udp"
    }
}
```
- vsomeip_client.json \
Enter the IP you want in the "unicast" key (The IP address of the container running the client application).
```
{ 
   "unicast" : "172.20.0.3",
    "logging" :
    {
        "level" : "debug",
        "console" : "true",
        "file" : { "enable" : "false" },
        "dlt" : "false"
    },
    "applications" :
    [
        {
            "name" : "client-sample",
            "id" : "0x1343"
        }
    ],
   "routing" : "client-sample",
    "service-discovery" :
    {
        "enable" : "true",
        "multicast" : "224.244.224.245",
        "port" : "30490",
        "protocol" : "udp"
    }
}
```
- Create docker network
```
sudo docker network create --gateway 172.20.0.1 --subnet 172.20.0.0/16 myBridge
```
## Step 3. Dockerfile Build
```
$ chmod +x docker_build.sh
$ sudo ./docker_build.sh
```
## Step 4. Dockerfile Run
- TERMINAL 1 (Server)
```
$ sudo docker run --network myBridge --ip 172.20.0.2 -p 30490 -it vsomip_server
```
- TERMINAL 2 (Client)
```
$ sudo docker run --network myBridge --ip 172.20.0.3 -p 30490 -it vsomip_client
```
# Reference
- Zeung-il Kim, "Genivi commonapi, some/ip", https://endland.medium.com/genivi-commonapi-some-ip-ab5cd0e36849 
- endland, "build-common-api-cpp-native", https://github.com/endland/build-common-api-cpp-native/tree/master
- COVESA, "vsomeip in 10 minutes", https://github.com/COVESA/vsomeip/wiki/vsomeip-in-10-minutes
- "Cpp Code Generation Failed", https://github.com/COVESA/capicxx-someip-tools/issues/33
- "Running Hello world or Custom Applications", https://github.com/COVESA/vsomeip/issues/431
- "commonapi some/ip 두개의 디바이스간 통신 구현", https://youonlyliveonce1.tistory.com/66