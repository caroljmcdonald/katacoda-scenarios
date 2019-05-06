#!/bin/bash
yum install tcpdump -y
#mapr-posix-client-* -y
#systemctl restart mapr-posix-client-container

# Download lab material
git clone https://github.com/mapr-demos/flightdelayhol
mv /root/flightdelayhol/data/* .
