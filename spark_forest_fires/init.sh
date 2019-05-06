#!/bin/bash

# Login
echo "mapr" | maprlogin password -user mapr

# Start Zeppelin
/opt/zeppelin/bin/zeppelin-daemon.sh start
# Wait for Zeppelin start to complete
until $(curl --output /dev/null --silent --head --fail http://localhost:7000/api); do
    sleep 1
done

####################################################
# Install stuff needed for the Forest Fire notebook
####################################################
sudo yum install python-pip -y
sudo pip install dbfpy requests pandas bs4 websocket-client
wget https://github.com/joewalnes/websocketd/releases/download/v0.3.0/websocketd.0.3.0.i386.rpm
sudo rpm -ivh websocketd.0.3.0.i386.rpm
git clone https://github.com/mapr-demos/mapr-sparkml-streaming-wildfires
cp mapr-sparkml-streaming-wildfires/ml_input_stream.sh mapr-sparkml-streaming-wildfires/ml_output_stream.sh /root
websocketd --port=3433 --dir=/root --devconsole &
disown

# Import notebook into Zeppelin
wget -P /root https://raw.githubusercontent.com/mapr-demos/katacoda-scenarios/master/spark_forest_fires/assets/Forest%20Fire%20Prediction.json
curl -X POST http://localhost:7000/api/notebook/import -d @"/root/Forest Fire Prediction.json"

# create streams
#maprcli stream create -path /user/mapr/ml_input -produceperm p -consumeperm p -topicperm p -ttl 604800
#maprcli stream topic create -path /user/mapr/ml_input -topic requester001
# ttl 604800 is 1 week
#maprcli stream create -path /user/mapr/ml_output -produceperm p -consumeperm p -topicperm p -ttl 604800
#maprcli stream topic create -path /user/mapr/ml_output -topic kmeans001

# Copy the pre-built kmeans model:
mkdir /mapr/demo.mapr.com/user/mapr/data
tar -C /mapr/demo.mapr.com/user/mapr/data -xvf mapr-sparkml-streaming-wildfires/saved_model.tgz
mv /mapr/demo.mapr.com/user/mapr/data/save_fire_model/ /mapr/demo.mapr.com/user/mapr/data/save_fire_model-cascadia

# Copy the fat jar for applying the kmeans model on streaming lat/long coordinates. The fat jar has been split to fit within github's 100MB file size limit. Join the pieces with cat:
cat mapr-sparkml-streaming-wildfires/target/mapr-sparkml-streaming-fires-1.0-jar-with-dependencies.jar-* > mapr-sparkml-streaming-fires-1.0-jar-with-dependencies.jar


