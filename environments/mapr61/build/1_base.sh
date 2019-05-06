#!/bin/bash

yum install -y deltarpm epel-release

yum -y update
yum -y install gcc make gcc-c++ kernel-devel kernel-headers perl wget bzip2 tree git jq pv ansible
yum clean all

sed -i 's/.*UseDNS.*/UseDNS no/' /etc/ssh/sshd_config

timedatectl set-timezone UTC
timedatectl set-local-rtc 0
