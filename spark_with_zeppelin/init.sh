#!/bin/bash

# Login
echo "mapr" | maprlogin password -user mapr

# Start Zeppelin
/opt/zeppelin/bin/zeppelin-daemon.sh start
# Wait for Zeppelin start to complete
until $(curl --output /dev/null --silent --head --fail http://localhost:7000/api); do
    sleep 1
done

# Import notebook into Zeppelin
#wget -P /root https://raw.githubusercontent.com/mapr-demos/katacoda-scenarios/master/spark_with_zeppelin/assets/Forest%20Fire%20Prediction.json
#cp assets/Forest*.json /root
#curl -X POST http://localhost:7000/api/notebook/import -d @"/root/Forest Fire Prediction.json"

