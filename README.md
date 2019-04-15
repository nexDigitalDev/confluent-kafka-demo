# confluent-kafka-demo



Demonstration of the confluent kafka distribution with file connector (spooldir), ksql, muleSoft kafka connector. Possibility to activate the security or to deploy on a k8s cluster.

This demo will contain several parts: Confluent Installation and Configuration, Connectors Installation and Configuration, KSQL, MuleSoft Configuration and Security Configuration.

The use case of this demo is quite simple. It consists in activating 2 SpoolDir cnnectors which will transform the file in the defined source directory into Kafka messages.

## Confluent Installation

#### 		Local Installation For Ubuntu and Debian System

Install the Confluent public key. This key is used to sign the packages in the APT
repository.

```bash
$ wget -qO - https://packages.confluent.io/deb/5.1/archive.key | sudo apt-key add -
```

Add the repository to your **/etc/apt/sources.list** file by running this command:

```bash
$ add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/5.1 stable main"
```

Update apt-get and install the entire Confluent Platform platform.

```bash
$ apt-get update && sudo apt-get install confluent-platform-2.11
```

Please refer to this [page](https://docs.confluent.io/current/installation/installing_cp/index.html) for other installation methods.

#### 		Configuration

Navigate to the ZooKeeper properties file **/etc/kafka/zookeeper.properties** and modify as shown.

```
dataDir=/var/lib/zookeeper/
clientPort=2181
```

Navigate to the Kafka properties file **/etc/kafka/server.properties** and customize the following:

```bash
zookeeper.connect=localhost:2181
############################# Server Basics #############################
# The ID of the broker. This must be set to a unique integer for each broker.
#broker.id=0
broker.id.generation.enable=true
```

#### 		Start Confluent Platform

```bash
$ confluent start
```

## Clone the current Repository

Clone the current repository to **/your/preferred/path** :
```bash
$ git clone https://github.com/nexDigitalDev/confluent-kafka-demo
$ cd confluent-kafka-demo
```

## Kafka SpoolDir Connector

Before starting this part, make sure that you are in the directory **/your/preferred/path/confluent-kafka-demo**. You will have your data files, connectors configuration files and other related files in this directory.

 

#### Installation

You can either download the connector with Confluent Hub using the following command :

```bash
$ confluent-hub install jcustenborder/kafka-connect-spooldir:1.0.37
```
Or download manually the connector in **/your/preferred/path/confluent-kafka-demo/kafka-connect-spooldir** with git :
```bash
$ git clone https://github.com/jcustenborder/kafka-connect-spooldir.git
$ cd kafka-connect-spooldir
$ mvn clean package
```
Once you downloaded the connector manually or with Confluent Hub, create the following directories :
```bash
$ mkdir /your/preferred/path/confluent-kafka-demo/source
$ mkdir /your/preferred/path/confluent-kafka-demo/finished
$ mkdir /your/preferred/path/confluent-kafka-demo/error
$ mkdir /your/preferred/path/confluent-kafka-demo/logs
```

#### Schema Generation

This part is **optional** if you want to know how to generate Avro Schema which is used when adding the connectors in the next part. 

**It requires that you installed the spooldir connector with git**. However, if you installed the connector with Confluent Hub, you can either define the Avro schema manually or looking for online Json - Avro converter.

First, create the configuration file at **/your/preferred/path/confluent-kafka-demo/spool_conf.tmp** which contains : 
```
input.path=/your/preferred/path/confluent-kafka-demo/source
finished.path=/your/preferred/path/confluent-kafka-demo/finished
error.path=/your/preferred/path/confluent-kafka-demo/error
csv.first.row.as.header=true
```
> Don't forget to replace the paths to source, finished and error directories in the above file.


Navigate to the **/your/preferred/path/confluent-kafka-demo/kafka-connect-spooldir** and execute the following commands on the file **/your/preferred/path/confluent-kafka-demo/source/yourFile.csv** to generate the Avro Schema of the data in this file:
```bash
$ export CLASSPATH="$(find target/kafka-connect-target/usr/share/kafka-connect/kafka-connect-spooldir/ -type f -name '*.jar' | tr '\n' ':')"

$ kafka-run-class com.github.jcustenborder.kafka.connect.spooldir.SchemaGenerator -t csv -f /your/preferred/path/confluent-kafka-demo/source/yourFile.csv -c /your/preferred/path/confluent-kafka-demo/spool_conf.tmp

```
> Don't forget to replace the path to your **spool_conf.tmp** and **your CSV file** in the above commands.

## Set up the Demo

Navigate to the **/your/preferred/path/confluent-kafka-demo**.
```bash
$ cd /your/preferred/path/confluent-kafka-demo
```

Modify the script **/your/preferred/path/confluent-kafka-demo/scripts/demo-install.sh** by modifying the **KAFKA_DIR** variable :

```bash
# Modify the access path to the confluent-kafka-demo directory
KAFKA_DIR=/your/preferred/path/confluent-kafka-demo 
```
After that, launch the script for running the demo :
```bash
$ ./scripts/demo-install.sh
```
This script will add the connectors for referential data and streaming data. The connectors will transform the CSV files into kafka messages and add them to **aircraft** and **traffic** topics. Intermediate KSQL streams and tables are also created to 

## KSQL

Open the KSQL by typing the following command in the terminal :

```bash
$ ksql
```

Select the stream **TRAFFIC_ENRICHED** created with the previous scrip **demo-install.sh**. 

```bash
SELECT * FROM TRAFFIC_ENRICHED;
```
> If you want to select all data from the beginning, before executing the above command, run \n
**SET 'auto.offset.reset'='earliest';** in the KSQL command lines.

Open another terminal, and place a new streaming traffic data with the following command. You will see in the terminal running KSQL that there is a new input data.

```bash
$ cp /your/preferred/path/confluent-kafka-demo/data/Flight_Log_Paris_demoUpdateBEFORE02fev_2019.csv /your/preferred/path/confluent-kafka-demo/source/
```
> Don't forget to replace the path in the above command !

Now let's update a referential data and see if the new input stream will be updated.

```bash
$ cp /your/preferred/path/confluent-kafka-demo/data/aircraft_airbus_airfrance_demoUpdate.csv /your/preferred/path/confluent-kafka-demo/source/

$ cp /your/preferred/path/confluent-kafka-demo/data/Flight_Log_Paris_demoUpdateAFTER02fev_2019.csv /your/preferred/path/confluent-kafka-demo/source/
```

Normally, in the KSQL Terminal, you will see that the same stream traffic has now different referential data.

## Console Producer and Consumer 

Instead of using KSQL, you can either use the console producer or consumer to consume or produce messages. For example, you can use the console consumer to observe the messages of **TRAFFIC_ENRICHED** : 

```bash
$ kafka-console-consumer --bootstrap-server localhost:9092 --topic TRAFFIC_ENRICHED --from-beginning --formatter kafka.tools.DefaultMessageFormatter --property print.key=true --property print.value=true  --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer --property value.deserializer=org.apache.kafka.common.serialization.StringDeserializer
```

## MuleSoft Consumer
Please refer to the this page to configure the MuleSoft Consumer.

```bash
```


```bash
```