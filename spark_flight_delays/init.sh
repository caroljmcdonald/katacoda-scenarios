#!/bin/bash

# Login
echo "mapr" | maprlogin password -user mapr

# Add a mapr license needed for snapshots
#wget -P /root https://raw.githubusercontent.com/mapr-demos/katacoda-scenarios/master/spark_with_zeppelin/assets/mapr_license.txt
#maprcli license add -license /root/mapr_license.txt -is_file true

# Download lab material
git clone https://github.com/mapr-demos/flightdelayhol
mv /root/flightdelayhol/target/*.jar .
mv /root/flightdelayhol/data/* .

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





