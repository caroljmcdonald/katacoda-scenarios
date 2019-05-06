This is tutorial demonstrates how to use Spark in Apache Zeppelin for a machine learning exercise. To run this exercise, follow the Zeppelin notebook described below.

***Wait about 5 minutes for Zeppelin to download and install.***

1. Open Zeppelin in the toolbar tab
2. Wait up to 5 minutes for Zeppelin to start. The tab will automatically refresh.
3. Refresh the Zeppelin notebooks. 
4. Open and run the Forest Fire Prediction notebook. 🔥

The Zeppelin notebook trains a kmeans model for fire prediction. 

A pre-built kmeans model has been included so you don't have to run the entire Zeppelin notebook. If you want to use the pre-built model to demonstrate kmeans on streaming data, do this:

1. Run the Spark ML job which applies kmeans on a stream of lat,long coordinates. This represents a service that listens for fires (the lat/long) and assigns a cluster id (i.e. "fire station") to respond to that fire:
`/opt/mapr/spark/spark-*/bin/spark-submit --class com.sparkkafka.fire.SparkKafkaConsumerProducer --master local[2] /root/mapr-sparkml-streaming-fires-1.0-jar-with-dependencies.jar /mapr/demo.mapr.com/user/mapr/data/save_fire_model-cascadia  /user/mapr/ml_input:requester001 /user/mapr/ml_output:kmeans001`{{execute}}
2. Open the KMeans Input window and enter a lat,long value (e.g: 42.988,-121.272). This represents the location for a new fire. 
3. Open the KMeans Output window to see the cluster id (i.e. “fire station”) which the model has assigned to respond to that fire.

Instead of using the KMeans input/output window, you can also monitor the streams manually, like this:

4. Input lat/long coordinates to an event stream: `/opt/mapr/kafka/kafka-1.1.1/bin/kafka-console-producer.sh --topic /user/mapr/ml_input:requester001 --broker-list this.will.be.ignored:9092`{{execute}}
5. Watch the Spark ML kmeans output on this stream: `/opt/mapr/kafka/kafka-1.1.1/bin/kafka-console-consumer.sh --topic /user/mapr/ml_output:kmeans001 --bootstrap-server not.applicable:0000 --from-beginning`{{execute}}

