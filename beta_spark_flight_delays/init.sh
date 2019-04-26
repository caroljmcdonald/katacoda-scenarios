#!/bin/bash

# Login
echo "mapr" | maprlogin password -user mapr

# Add a mapr license needed for snapshots
wget -P /root https://raw.githubusercontent.com/mapr-demos/katacoda-scenarios/master/spark_with_zeppelin/assets/mapr_license.txt
maprcli license add -license /root/mapr_license.txt -is_file true

# Remove Hive metastore in order to avoid some wierd errors
#/opt/mapr/hive/hive-2.3/bin/hive --service metastore --stop
#rm -rf /opt/mapr/hive/hive-2.3/bin/metastore_db/
#/opt/mapr/hive/hive-2.3/bin/hive --service metastore --start

# Install MapR POSIX client in order to use MapR via NFS
yum install unzip mapr-posix-client-* -y
systemctl restart mapr-posix-client-container

# Disable annoying console email notifications
postfix stop
rm -f /var/spool/mail/root

# Temporary Download Zeppelin for beta test
wget -P /opt http://us.mirrors.quenda.co/apache/zeppelin/zeppelin-0.8.1/zeppelin-0.8.1-bin-all.tgz 
tar -C /opt/ -xzf /opt/zeppelin-0.8.1-bin-all.tgz
mv /opt/zeppelin-0.8.1-bin-all /opt/zeppelin

# Download lab material
git clone https://github.com/mapr-demos/flightdelayhol
mv /root/flightdelayhol/target/*.jar .
mv /root/flightdelayhol/data/* .

# setup Zeppelin zeppelin-0.8.1-bin-all.tgz
#wget -P /opt http://us.mirrors.quenda.co/apache/zeppelin/zeppelin-0.8.1/zeppelin-0.8.1-bin-all.tgz 
tar -C /opt/ -xzf /opt/zeppelin-0.8.1-bin-all.tgz
mv /opt/zeppelin-0.8.1-bin-all /opt/zeppelin
# Configure Zeppelin for YARN, Spark, and webui port 7000
echo "export ZEPPELIN_PORT=7000" >> /opt/zeppelin/conf/zeppelin-env.sh
echo "export SPARK_HOME=/opt/mapr/spark/spark-2.3.2" >> /opt/zeppelin/conf/zeppelin-env.sh
echo "export HADOOP_HOME=/opt/mapr/hadoop/hadoop-2.7.0" >> /opt/zeppelin/conf/zeppelin-env.sh
echo "export SPARK_SUBMIT_OPTIONS=\"--packages graphframes:graphframes:0.7.0-spark2.3-s_2.11\"" >> /opt/zeppelin/conf/zeppelin-env.sh

# Start Zeppelin
/opt/zeppelin/bin/zeppelin-daemon.sh start
# Wait for Zeppelin start to complete
until $(curl --output /dev/null --silent --head --fail http://localhost:7000/api); do
    sleep 1
done

# Import notebooks into Zeppelin

curl -X POST http://localhost:7000/api/notebook/import -d @"/root/flightdelayhol/notebooks/FlightDelay1SparkDatasets.json"
curl -X POST http://localhost:7000/api/notebook/import -d @"/root/flightdelayhol/notebooks/FlightDelay2SparkMachineLearning.json"
curl -X POST http://localhost:7000/api/notebook/import -d @"/root/flightdelayhol/notebooks/FlightDelay3StructuredStreaming.json"
curl -X POST http://localhost:7000/api/notebook/import -d @"/root/flightdelayhol/notebooks/FlightDelay4SQLMapRDatabase.json"
curl -X POST http://localhost:7000/api/notebook/import -d @"/root/flightdelayhol/notebooks/FlightDelay5GraphFrames.json"





