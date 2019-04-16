# confluent-kafka-demo



Demonstration of the Confluent/Kafka distribution with a file connector (Spooldir), KSQL, MuleSoft Kafka connector. You can activate the security or deploy it on a K8s cluster.

This demo contains several parts:

    - Confluent installation and configuration
    - Connectors installation and configuration
    - KSQL configuration
    - MuleSoft configuration
    - Security configuration.

The example this demo gives consists in activating 2 SpoolDir connectors which will transform a file located in a defined source directory into Kafka messages.

## Confluent Installation

#### 		Local Installation for Ubuntu and Debian systems

Get the Confluent public key and add it to APT Key management utility. This key is used to sign the packages in the APT repository.

```bash
$ wget -qO - https://packages.confluent.io/deb/5.1/archive.key | sudo apt-key add -
```

Add the repository to your **/etc/apt/sources.list** file by running this command:

```bash
$ add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/5.1 stable main"
```

Update apt-get and install the entire Confluent Platform.

```bash
$ apt-get update && sudo apt-get install confluent-platform-2.11
```

Please refer to this [page](https://docs.confluent.io/current/installation/installing_cp/index.html) for other installation methods.

#### 		Configuration

Navigate to the ZooKeeper properties file **/etc/kafka/zookeeper.properties** and modify it to match the lines below.

```
dataDir=/var/lib/zookeeper/
clientPort=2181
```

Navigate to the Kafka properties file **/etc/kafka/server.properties** and set the following lines:

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

## Clone this repository

Clone this repository to **/your/preferred/path** :
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

This part is **optional**  
Read it if you want to know how to generate Avro Schema which are used when adding the connectors in the next part. 

**This requires that you installed the spooldir connector with git**.  
However, if you installed the connector with Confluent Hub, you can either define the Avro schema manually or looking for online Json - Avro converter.

First, create the configuration file at **/your/preferred/path/confluent-kafka-demo/spool_conf.tmp** which should contain : 
```
input.path=/your/preferred/path/confluent-kafka-demo/source
finished.path=/your/preferred/path/confluent-kafka-demo/finished
error.path=/your/preferred/path/confluent-kafka-demo/error
csv.first.row.as.header=true
```
> Don't forget to replace the paths in each of the lines above by the one you set instead of `/your/preferred/path/`.


Navigate to the **/your/preferred/path/confluent-kafka-demo/kafka-connect-spooldir** and execute the following commands on the file **/your/preferred/path/confluent-kafka-demo/source/yourFile.csv** to generate the Avro Schema based on the data in this file:
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
After that, execute the script for installing the demo :
```bash
$ ./scripts/demo-install.sh
```
This script will add the connectors for referential and streaming data. The connectors will transform the CSV files into kafka messages and add them to **'aircraft'** and **'traffic'** topics. 

Intermediate KSQL streams and tables are also created in order to rekey messages by partioning. After that, a new stream **TRAFFIC_ENRICHED** and its corresponding topic are created based on the jointure of the **'AIRCRAFT_TABLE_KEY'** table and the **'TRAFFIC_KEY'** stream.

## KSQL

Open the KSQL by typing the following command in the terminal :

```bash
$ ksql
```

Select the stream **TRAFFIC_ENRICHED** created with the previous scrip **demo-install.sh**. 

```sql
$ SELECT * FROM TRAFFIC_ENRICHED;
```
> If you want to select all data from the beginning, before executing the above command, <br> run 
 **SET 'auto.offset.reset'='earliest';**  in the KSQL terminal.

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
Please refer to the this [page](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/mule/README.md) to configure the MuleSoft Consumer.


## Configuring Security

Please refer to this [page](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/security/README.md) to set up the security.