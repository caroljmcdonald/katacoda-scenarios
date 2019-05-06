#!/bin/bash

export MAPR_ANSIBLE_INVENTORY="host_templates/hosts_katacoda"
export MAPR_ANSIBLE_EXTRA_VARS="disks=/dev/vdb disk_storage_pool_size=1 virtual_machine=True mfs_heapsize_maxpercent=20 drillbit_service_env='DRILLBIT_MAX_PROC_MEM=3072m,DRILL_HEAP=1024m,DRILL_MAX_DIRECT_MEMORY=1024m,DRILLBIT_CODE_CACHE_SIZE=512m' drill_heap_size_in_mb=3072"

#cd /opt/
#git clone https://github.com/mapr-emea/mapr-vagrant-packer.git
#cd mapr-vagrant-packer
#git checkout 9ec74c52e56a0dbbee325cabb34b5cf94e48e8bc

yum install unzip -y


cd /opt/
git clone https://github.com/mapr-emea/mapr-ansible.git
cd mapr-ansible
git checkout katacoda
ansible-playbook -i $MAPR_ANSIBLE_INVENTORY --extra-vars "$MAPR_ANSIBLE_EXTRA_VARS" site-cluster.yml
cd /
rm -Rf /opt/mapr-ansible

cd /opt/
git clone https://github.com/mapr-demos/katacoda-scenarios
cd katacoda-scenarios
export GIT_REV="$(git rev-parse HEAD)"
cd /
rm -Rf /opt/katacoda-scenarios


source /etc/profile
#sleep 1m

#systemctl restart mapr-warden
# trigger build2

sleep 5m

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk/
export MAPR_TICKETFILE_LOCATION=/opt/mapr/conf/mapruserticket

maprcli volume list -json | jq '.data[].volumename' | xargs -L 1 maprcli volume modify -replication 1 -minreplication 1 -name
maprcli volume list -json | jq '.data[].volumename' | xargs -L 1 maprcli volume modify -nsreplication 1 -nsminreplication 1 -name

maprcli alarm clearall

# Add a mapr license needed for snapshots, does not work
#wget -P /tmp https://raw.githubusercontent.com/mapr-demos/katacoda-scenarios/master/envfiles/mapr_license.txt
#maprcli license add -license /tmp/mapr_license.txt -is_file true

# Drill AntLR version conflict, remove antlr lib from mapr dbshell
cp /opt/mapr/bin/mapr-config.sh /opt/mapr/bin/mapr-config.sh.bak
sed -e '126d' /opt/mapr/bin/mapr-config.sh.bak > /opt/mapr/bin/mapr-config.sh

echo "Git rev $GIT_REV" > /tmp/maprimage

# Zeppelin setup
# setup Zeppelin zeppelin-0.8.1-bin-all.tgz
wget -P /opt http://us.mirrors.quenda.co/apache/zeppelin/zeppelin-0.8.1/zeppelin-0.8.1-bin-all.tgz
tar -C /opt/ -xzf /opt/zeppelin-0.8.1-bin-all.tgz
mv /opt/zeppelin-0.8.1-bin-all /opt/zeppelin
chown -R mapr:mapr /opt/zeppelin
# Configure Zeppelin for YARN, Spark, and webui port 7000
echo "export ZEPPELIN_PORT=7000" >> /opt/zeppelin/conf/zeppelin-env.sh
echo "export MAPR_TICKETFILE_LOCATION=/opt/mapr/conf/mapruserticket" >> /opt/zeppelin/conf/zeppelin-env.sh
echo "export SPARK_HOME=/opt/mapr/spark/spark-2.3.2" >> /opt/zeppelin/conf/zeppelin-env.sh
echo "export HADOOP_HOME=/opt/mapr/hadoop/hadoop-2.7.0" >> /opt/zeppelin/conf/zeppelin-env.sh
echo "export SPARK_SUBMIT_OPTIONS=\"--packages graphframes:graphframes:0.7.0-spark2.3-s_2.11\"" >> /opt/zeppelin/conf/zeppelin-env.sh

#wget -P /etc/systemd/system/ https://raw.githubusercontent.com/mapr-demos/katacoda-scenarios/master/envfiles/zeppelin.service
#sudo systemctl disable zeppelin

# Disable annoying console email notifications
rm -f /var/spool/mail/root

systemctl stop mapr-posix-client-basic | true
systemctl stop mapr-warden
systemctl stop mapr-zookeeper
systemctl disable postfix
systemctl stop postfix