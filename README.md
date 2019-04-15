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

## Kafka SpoolDir Connector

Before starting this part, make sure that you create a directory **kafka** in **/your/preferred/path/**. You will store your data files, connectors configuration files and other related files in this directory.

 

#### Installation

You can either download the connector with Confluent Hub using the following command :

```bash
$ confluent-hub install jcustenborder/kafka-connect-spooldir:1.0.37
```
Or download manually the connector in **/your/preferred/path/kafka/kafka-connect-spooldir** with git :
```bash
$ git clone https://github.com/jcustenborder/kafka-connect-spooldir.git
$ cd kafka-connect-spooldir
$ mvn clean package
```
Once you downloaded the connector manually or with Confluent Hub, create the following directories :
```bash
$ mkdir /your/preferred/path/kafka/source
$ mkdir /your/preferred/path/kafka/finished
$ mkdir /your/preferred/path/kafka/error
```

#### Schema Generation

This part is **optional** if you want to know how to generate Avro Schema which is used when adding the connectors in the next part. 

**It requires that you installed the spooldir connector with git**. However, if you installed the connector with Confluent Hub, you can either define the Avro schema manually or looking for online Json - Avro converter.

First, create the configuration file at **/your/preferred/path/kafka/spool_conf.tmp** which contains : 
```
input.path=/your/preferred/path/kafka/source
finished.path=/your/preferred/path/kafka/finished
error.path=/your/preferred/path/kafka/error
csv.first.row.as.header=true
```
> Don't forget to replace the paths to source, finished and error directories in the above file.


Navigate to the **/your/preferred/path/kafka/kafka-connect-spooldir** and execute the following commands :
```bash
$ export CLASSPATH="$(find target/kafka-connect-target/usr/share/kafka-connect/kafka-connect-spooldir/ -type f -name '*.jar' | tr '\n' ':')"

$ kafka-run-class com.github.jcustenborder.kafka.connect.spooldir.SchemaGenerator -t csv -f /your/preferred/path/kafka/source/yourFile.csv -c /your/preferred/path/kafka/spool_conf.tmp

```
> Do not forget to replace the path to your **spool_conf.tmp** and your CSV file in the above commands.

