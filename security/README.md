# Security Configuration

In this guide, you will enbale the security on Zookeeper, Kafka and all Kafka Clients.

The security is devided into three parts :
- Secure Zookeeper and Kafka communication
- Secure Kafka brokers and Kafka clients communication
- ACL Autorisations

In production, the most common way to set up security is to add a new port. In this guide, you will be able to add a new port with SASL Authentication and SSL Encryption (**SASL_SSL**).

For more authentication methods, please refer to this [page](https://docs.confluent.io/current/security/index.html).


Before starting this guide, please check that your confluent is **down**. If not, run the following command to stop confluent :

```bash
$ confluent stop
```

## Generate certificate

Navigate to **/etc/kafka** and create a directory named **secrets**

```bash
$ cd /etc/kafka/ && sudo mkdir secrets && cd secrets
```
Execute the **certs-create.sh** script which creates certificates as root:
```bash
$ sudo /your/preferred/path/confluent-kafka-demo/security/certs-create.sh
```
> Don't forget to modify the path !



## Configure Zookeeper

First, you need to set up zookeeper by adding the following configuration to **/etc/kafka/zookeeper.properties**
```bash
## SECURITY Configuration

authProvider.1=org.apache.zookeeper.server.auth.SASLAuthenticationProvider
quorum.auth.enableSasl=true
quorum.auth.learnerRequireSasl=true
quorum.auth.serverRequireSasl=true
quorum.auth.learner.loginContext=QuorumLearner
quorum.auth.server.loginContext=QuorumServer
quorum.cnxn.threads.size=20
```

Before starting ZooKeeper, copy the ZooKeeper JAAS file to **/etc/kafka/** and pass its name as a JVM parameter :

```bash
$ cp /your/preferred/path/confluent-kafka-demo/security/zookeeper_jaas.conf /etc/kafka/

$ export KAFKA_OPTS="-Djava.security.auth.login.config=etc/kafka/zookeeper_jaas.conf"

$ confluent start zookeeper
```
> Don't forget to replace the path before copying !

## Configure Kafka Brokers

Modify the broker configuration file **/etc/kafka/server.properties** by adding the following :

```properties
######################## SECURITY  CONFIGURATION #################

listeners=SASL_SSL://localhost:9093,PLAINTEXT://localhost:9092
advertised.listeners=SASL_SSL://localhost:9093,PLAINTEXT://localhost:9092
authorizer.class.name=kafka.security.auth.SimpleAclAuthorizer
super.users=User:client;User:schemaregistry;User:restproxy;User:broker;User:connect;User:ANONYMOUS
metric.reporters=io.confluent.metrics.reporter.ConfluentMetricsReporter
broker.rack=r1

security.inter.broker.protocol=SASL_SSL
sasl.mechanism.inter.broker.protocol=PLAIN

confluent.metrics.reporter.bootstrap.servers=localhost:9093
confluent.metrics.reporter.security.protocol= SASL_SSL
confluent.metrics.reporter.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
	username=\"client\" \
	password=\"client-secret\";
confluent.metrics.reporter.sasl.mechanism=PLAIN
confluent.metrics.reporter.ssl.truststore.location=/etc/kafka/secrets/kafka.client.truststore.jks
confluent.metrics.reporter.ssl.truststore.password=confluent
confluent.metrics.reporter.ssl.keystore.location=/etc/kafka/secrets/kafka.client.keystore.jks
confluent.metrics.reporter.ssl.keystore.password=confluent
confluent.metrics.reporter.ssl.key.password=confluent
confluent.metrics.reporter.topic.replicas=1
confluent.metrics.reporter.max.request.size=10485760

# To avoid race condition with control-center
confluent.metrics.reporter.topic.create=false
auto.create.topics.enable=true
sasl.enabled.mechanisms=PLAIN
ssl.truststore.location=/etc/kafka/secrets/kafka.localhost.truststore.jks
ssl.truststore.password=confluent
ssl.keystore.location=/etc/kafka/secrets/kafka.localhost.keystore.jks
ssl.keystore.password=confluent
ssl.key.password=confluent

# enables 2-way authentication
ssl.client.auth=required
ssl.endpoint.identification.algorithm=
log4j.logger.kafka.authorizer.logger="DEBUG, authorizerAppender"
```

Copy the Broker JAAS File to **/etc/kafka** then pass its name as a JVM parameter before starting Kafka Brokers:

```bash
$ cp /your/preferred/path/confluent-kafka-demo/security/broker_jaas.conf /etc/kafka/

$ export KAFKA_OPTS="-Djava.security.auth.login.config=/etc/kafka/broker_jaas.conf"

$ confluent start kafka
```

# Test with Console Clients

Now let's test the above configuration with console producer and console consumer.

Try to enter some message with console producer by passing its SASL_SSL configuration file **/your/preferred/path/confluent-kafka-demo/security/producer_sasl.properties** :

```bash
$ kafka-console-producer \
--broker-list localhost:9093 \
--topic sasl-topic \
--producer.config /your/preferred/path/confluent-kafka-demo/security/producer_sasl.properties
```
> Don't forget to modify the path !

Once you produced some message, use the console consumer to confirm that your messages was successfully created in Kafka :
```bash
$ kafka-console-consumer \
--consumer.config /your/preferred/path/confluent-kafka-demo/security/consumer_sasl.properties \
--from-beginning \
--topic sasl-topic \
--bootstrap-server localhost:9093
```
> Don't forget to modify the path !

The basic Kafka Broker - Client communication is secured now. This is the common configuration for Kafka clients, based on that you can configure clients like Kafka Connect, KSQL, Control Center, Schema Registry, REST Proxy, etc.