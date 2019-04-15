# confluent-kafka-demo



Demonstration of the confluent kafka distribution with file connector (spooldir), ksql, muleSoft kafka connector. Possibility to activate the security or to deploy on a k8s cluster.

This demo will contain several parts: Confluent Installation and Configuration, Connectors Installation and Configuration, KSQL, MuleSoft Configuration and Security Configuration.

The use case of this demo is quite simple. It consists in activating 2 SpoolDir cnnectors which will transform the file in the defined source directory into Kafka messages.

## Confluent Installation

#### 	Local Installation For Ubuntu and Debian System

Install the Confluent public key. This key is used to sign the packages in the APT
repository.

> ```bash
> $ wget -qO - https://packages.confluent.io/deb/5.1/archive.key | sudo apt-key add -
> ```
>
> Add the repository to your **/etc/apt/sources.list** file by running this command:
>
> ```bash
> $ add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/5.1 stable main"
> ```

Update apt-get and install the entire Confluent Platform platform.

```bash
$ apt-get update && sudo apt-get install confluent-platform-2.11
```

Please refer to this [page](https://docs.confluent.io/current/installation/installing_cp/index.html) for other installation methods.

#### 	Configuration

Navigate to the ZooKeeper properties file **/etc/kafka/zookeeper.properties** and modify as shown.

> ```
> dataDir=/var/lib/zookeeper/
> clientPort=2181
> ```
>
> Navigate to the Kafka properties file **/etc/kafka/server.properties** and customize the following:

```bash
zookeeper.connect=localhost:2181
############################# Server Basics #############################
# The ID of the broker. This must be set to a unique integer for each broker.
#broker.id=0
broker.id.generation.enable=true
```

#### 	Start Confluent Platform

```bash
$ confluent start
```



## Kafka SpoolDir Connector

Before starting this part, make sure that you create a directory **kafka** in **/your/preferred/path/**. You will store your data files, connectors configuration files and 

 

#### 	Installation

##### 			Using Confluent Hub