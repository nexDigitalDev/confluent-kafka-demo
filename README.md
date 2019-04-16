# confluent-kafka-demo



Demonstration of the confluent kafka distribution with file connector (spooldir), ksql, muleSoft kafka connector. Possibility to activate the security or to deploy on a k8s cluster.

This demo will contain several parts: Confluent Installation and Configuration, Connectors Installation and Configuration, KSQL, MuleSoft Configuration and Security Configuration.

The use case of this demo is quite simple. It consists in activating 2 SpoolDir cnnectors which will transform the file in the defined source directory into Kafka messages.

## Requirement

- For system requirements, please refer to this [page](https://docs.confluent.io/current/installation/system-requirements.html).
- Java 1.8 is required


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
Or download manually the connector in **/your/preferred/path/confluent-kafka-demo/plugins/kafka-connect-spooldir** with git (**Maven** is required in this case):
```bash
$ mkdir plugins && cd plugins
$ git clone https://github.com/jcustenborder/kafka-connect-spooldir.git
$ cd kafka-connect-spooldir
$ mvn clean package
```
If you installed the connector with Git, modify the **plugin.path** configuration in those four files : 
<br>- **/etc/kafka/connect-distributed.properties** <br>- **/etc/kafka/connect-standalone.properties** <br>- **/etc/schema-registry/connect-avro-distributed.properties**
<br>- **/etc/schema-registry/connect-avro-standalone.properties**
```properties
plugin.path=/usr/share/java, /your/preferred/path/confluent-kafka-demo/plugins/kafka-connect-spooldir/target/kafka-connect-target/usr/share/kafka-connect/
```
> Don't forget to change **/your/preferred/path** to the path where you cloned this git repository !

After modifying configuration files, restart confluent :
```bash
$ confluent stop
$ confluent start
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


Navigate to the **/your/preferred/path/confluent-kafka-demo/kafka-connect-spooldir** and execute the following commands on the file **/your/preferred/path/confluent-kafka-demo/data/aircraft_airbus_airfrance_0.csv** to generate the Avro Schema of the data in this file:
```bash
$ export CLASSPATH="$(find target/kafka-connect-target/usr/share/kafka-connect/kafka-connect-spooldir/ -type f -name '*.jar' | tr '\n' ':')"

$ kafka-run-class com.github.jcustenborder.kafka.connect.spooldir.SchemaGenerator -t csv -f /your/preferred/path/confluent-kafka-demo/data/aircraft_airbus_airfrance_0.csv -c /your/preferred/path/confluent-kafka-demo/spool_conf.tmp

```
> Don't forget to replace the path to your **spool_conf.tmp** and **aircraft_airbus_airfrance_0.csv** files in the above commands.

## Set up the Demo

Navigate to **/your/preferred/path/confluent-kafka-demo/scripts**.
```bash
$ cd /your/preferred/path/confluent-kafka-demo/scripts
```

Modify the script **demo-install.sh** by modifying the "**KAFKA_DIR**" variable :

```bash
# Modify the access path to the confluent-kafka-demo directory
KAFKA_DIR=/your/preferred/path/confluent-kafka-demo 
```

Modify the paths variables ("**input.path**", "**finished.path**" and "**error.path**") in the two connector configuration files **csv-source-traffic.config** and **csv-source-aircraft.config** :
```bash
{
    ...
    "config":{
        ...
        "input.path": "/your/preferred/path/confluent-kafka-demo/source",
        "finished.path": "/your/preferred/path/confluent-kafka-demo/finished",
        "error.path": "/your/preferred/path/confluent-kafka-demo/error",
        ...
        }
    ...
}
```

After that, launch the script for installing the demo as root :
```bash
$ sudo ./scripts/demo-install.sh
```
This script will add the connectors for referential and streaming data. The connectors will transform the CSV files into kafka messages and add them to **'aircraft'** and **'traffic'** topics. 

Intermediate KSQL streams and tables are also created in order to rekey messages by partioning. After that, a new stream **TRAFFIC_ENRICHED** and its corresponding topic are created based on the jointure of the **AIRCRAFT_TABLE_KEY** table and the **TRAFFIC_KEY** stream.

## KSQL

Open the KSQL by typing the following command in the terminal :

```bash
$ ksql
```

In the installation script  **demo-install.sh**, some data were send trough the connectors. To visualise those Kafka messages with KSQL you can select the **TRAFFIC_ENRICHED** stream using the following commands : 

```sql
$ SET 'auto.offset.reset'='earliest';
$ SELECT * FROM TRAFFIC_ENRICHED;
```
> The first command is aimed to select messages from the beginning.

Now, let's see what happens if you add new input data to this stream. Keep this KSQL terminal running and in another terminal execute the following command :

```bash
$ cp /your/preferred/path/confluent-kafka-demo/data/Flight_Log_Paris_demoUpdateBEFORE02fev_2019.csv /your/preferred/path/confluent-kafka-demo/source/
```
> Don't forget to replace the path in the above command !

You will see in the terminal running KSQL that there is a new input data.

<br>

Now let's update a referential data and see if the new input stream will be updated.

```bash
$ cp /your/preferred/path/confluent-kafka-demo/data/aircraft_airbus_airfrance_demoUpdate.csv /your/preferred/path/confluent-kafka-demo/source/

$ cp /your/preferred/path/confluent-kafka-demo/data/Flight_Log_Paris_demoUpdateAFTER02fev_2019.csv /your/preferred/path/confluent-kafka-demo/source/
```

Normally, in the KSQL Terminal, you will see that the same stream traffic has now different referential data.

## Console Producer and Consumer 

Instead of using KSQL, you can either use the console producer or consumer to consume or produce messages. If you use console producer, be aware that your input data has the same data structure as defined in the connector configuration file. 

For example, you can use the console consumer to observe the messages of **TRAFFIC_ENRICHED** : 

```bash
$ kafka-console-consumer --bootstrap-server localhost:9092 --topic TRAFFIC_ENRICHED --from-beginning --formatter kafka.tools.DefaultMessageFormatter --property print.key=true --property print.value=true  --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer --property value.deserializer=org.apache.kafka.common.serialization.StringDeserializer
```

## MuleSoft Consumer
Please refer to the this [page](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/mule/README.md) to configure the MuleSoft Consumer.


## Configuring Security

Please refer to this [page](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/security/README.md) to set up the security.