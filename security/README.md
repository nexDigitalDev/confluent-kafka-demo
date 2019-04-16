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

> hello
> demo
```
> Don't forget to modify the path !

Once you produced some message, use the console consumer to confirm that your messages was successfully created in Kafka :
```bash
$ kafka-console-consumer \
--consumer.config /your/preferred/path/confluent-kafka-demo/security/consumer_sasl.properties \
--from-beginning \
--topic sasl-topic \
--bootstrap-server localhost:9093

hello
demo
```
> Don't forget to modify the path !

Now you have the basics to play security on Confluent. You can jump directly to the [Authorization and ACLs](https://github.com/nexDigitalDev/confluent-kafka-demo/authorisation-and-acls) section to see how to set up autorisations with Kafka ACLs.

You can also secure Kafka Connect, KSQL, Control Center, Schema Registry and REST Proxy which are also Kafka Clients in the following parts. The basic is quite similar which consists in passing SSL certificates and SASL configurations in the properties files.

If you want to configure other clients, please refer to the [documentation](https://docs.confluent.io/current/security/index.html) of confluent.



## Configure KSQL and Stream Processing Clients
Navigate to **/etc/ksql/ksql-server.properties** and modify it to match the lines below.

```properties
bootstrap.servers=localhost:9093
listeners=http://localhost:8088

# Top level
security.protocol=SASL_SSL
ssl.truststore.location=/etc/kafka/secrets/kafka.client.truststore.jks
ssl.truststore.password=confluent
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="client" password="client-secret";

# Embedded producer for streams monitoring with Confluent Control Center
producer.interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor
producer.confluent.monitoring.interceptor.security.protocol=SASL_SSL
producer.confluent.monitoring.interceptor.ssl.truststore.location=/etc/kafka/secrets/kafka.client.truststore.jks
producer.confluent.monitoring.interceptor.ssl.truststore.password=confluent
producer.confluent.monitoring.interceptor.ssl.keystore.location=/etc/kafka/secrets/kafka.client.keystore.jks
producer.confluent.monitoring.interceptor.ssl.keystore.password=confluent
producer.confluent.monitoring.interceptor.ssl.key.password=confluent
producer.confluent.monitoring.interceptor.sasl.mechanism=PLAIN
producer.confluent.monitoring.interceptor.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="client" password="client-secret";

# Embedded consumer for streams monitoring with Confluent Control Center
consumer.interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor
consumer.confluent.monitoring.interceptor.security.protocol=SASL_SSL
consumer.confluent.monitoring.interceptor.ssl.truststore.location=/etc/kafka/secrets/kafka.client.truststore.jks
consumer.confluent.monitoring.interceptor.ssl.truststore.password=confluent
consumer.confluent.monitoring.interceptor.ssl.keystore.location=/etc/kafka/secrets/kafka.client.keystore.jks
consumer.confluent.monitoring.interceptor.ssl.keystore.password=confluent
consumer.confluent.monitoring.interceptor.ssl.key.password=confluent
consumer.confluent.monitoring.interceptor.sasl.mechanism=PLAIN
consumer.confluent.monitoring.interceptor.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="client" password="client-secret";
```
## Configure Kafka Connect

Navigate to the properties file **/etc/kafka/connect-distributed.properties** and modify it to match the lines below.

```properties
#Security Configuration

# Connect worker
security.protocol=SASL_SSL
ssl.truststore.location=/etc/kafka/secrets/kafka.client.truststore.jks
ssl.truststore.password=confluent
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
   username="client" \
   password="client-secret";

# Embedded producer for source connectors
producer.security.protocol=SASL_SSL
producer.ssl.truststore.location=/etc/kafka/secrets/kafka.client.truststore.jks
producer.ssl.truststore.password=confluent
producer.sasl.mechanism=PLAIN
producer.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
  username="client" \
  password="client-secret";

# Embedded consumer for sink connectors
consumer.security.protocol=SASL_SSL
consumer.ssl.truststore.location=/etc/kafka/secrets/kafka.client.truststore.jks
consumer.ssl.truststore.password=confluent
consumer.sasl.mechanism=PLAIN
consumer.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
  username="client" \
  password="client-secret";

# Embedded producer for source connectors for streams monitoring with Confluent Control Center
producer.interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor
producer.confluent.monitoring.interceptor.security.protocol=SASL_SSL
producer.confluent.monitoring.interceptor.ssl.truststore.location=/etc/kafka/secrets/kafka.client.truststore.jks
producer.confluent.monitoring.interceptor.ssl.truststore.password=confluent
producer.confluent.monitoring.interceptor.sasl.mechanism=PLAIN
producer.confluent.monitoring.interceptor.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
  username="client" \
  password="client-secret";

# Embedded consumer for sink connectors for streams monitoring with Confluent Control Center
consumer.interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor
consumer.confluent.monitoring.interceptor.security.protocol=SASL_SSL
consumer.confluent.monitoring.interceptor.ssl.truststore.location=/etc/kafka/secrets/kafka.client.truststore.jks
consumer.confluent.monitoring.interceptor.ssl.truststore.password=confluent
consumer.confluent.monitoring.interceptor.sasl.mechanism=PLAIN
consumer.confluent.monitoring.interceptor.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
  username="client" \
  password="client-secret";
```

## Confluent Control Center
To secure the Control Center application, add the following configuration to **/etc/confluent-control-center/control-center.properties**:
```properties
##################################
##### Security Configuration #####
##################################

confluent.controlcenter.streams.security.protocol=SASL_SSL
confluent.controlcenter.streams.ssl.truststore.location=/etc/kafka/secrets/kafka.client.truststore.jks
confluent.controlcenter.streams.ssl.truststore.password=confluent
confluent.controlcenter.streams.sasl.mechanism=PLAIN
confluent.controlcenter.streams.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
  username="client" \
  password="client-secret";

ssl.client.auth=false

# Embedded producer for streams monitoring with Confluent Control Center
producer.interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor
producer.confluent.monitoring.interceptor.security.protocol=SASL_SSL
producer.confluent.monitoring.interceptor.ssl.truststore.location=/etc/kafka/secrets/kafka.client.truststore.jks
producer.confluent.monitoring.interceptor.ssl.truststore.password=confluent
producer.confluent.monitoring.interceptor.sasl.mechanism=PLAIN
producer.confluent.monitoring.interceptor.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="client" password="client-secret";

# Embedded consumer for streams monitoring with Confluent Control Center
consumer.interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor
consumer.confluent.monitoring.interceptor.security.protocol=SASL_SSL
consumer.confluent.monitoring.interceptor.ssl.truststore.location=/etc/kafka/secrets/kafka.client.truststore.jks
consumer.confluent.monitoring.interceptor.ssl.truststore.password=confluent
consumer.confluent.monitoring.interceptor.sasl.mechanism=PLAIN
consumer.confluent.monitoring.interceptor.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="client" password="client-secret";
```

## Authorization and ACLs

You may have noticed that the user **'client'** is defined as a Super User in [this section](https://github.com/nexDigitalDev/confluent-kafka-demo/tree/master/security#configure-kafka-brokers).
That implies this user has rights to access, read and write to any topics even though there is no explicit ACL declaration.

Try the following command to show all existing ACL definition :
```bash
$ kafka-acls --authorizer-properties zookeeper.connect=localhost:2181 --list --topic sasl-topic
```

Now try to produce and consume as user **client** with the following commands. You will see that the access to **sasl-topic** is not blocked for this user.

```bash
$ kafka-console-producer \
--broker-list localhost:9093 \
--topic sasl-topic \
--producer.config /your/preferred/path/confluent-kafka-demo/security/producer_sasl.properties

> try to enter
> some messages

$ kafka-console-consumer \
--consumer.config /your/preferred/path/confluent-kafka-demo/security/consumer_sasl.properties \
--from-beginning \
--topic sasl-topic \
--bootstrap-server localhost:9093

hello
demo
try to enter
some messages
```
> Don't forget to modify the path !

Now try to authenticate as a non-super user **test** with the following commands :

```bash
$ kafka-console-producer \
--broker-list localhost:9093\
--topic sasl-topic \
--producer.config /your/preferred/path/confluent-kafka-demo/security/test-client_sasl.properties
```
> Don't forget to modify the path !

The above command will be denied since the user **test** has any right on **sasl-topic** topic.

Execute the following command to grant him the write right :
```bash
$ kafka-acls --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal \
User:test --operation WRITE --topic sasl-topic
```

By the same way, if you want to give the read right to this user, execute the following command:

```bash
kafka-acls --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal \
User:test --operation READ --topic sasl-topic --group '*'
```

Now the user **test** is able to produce and consume on the topic **sasl-topic**.

```bash
$ kafka-console-producer \
--broker-list localhost:9093 \
--topic sasl-topic \
--producer.config /your/preferred/path/confluent-kafka-demo/security/test-client_sasl.properties
> now I have right
> to write this message

$ kafka-console-consumer \
--consumer.config /your/preferred/path/confluent-kafka-demo/security/test-client_sasl.properties \
--from-beginning \
--topic sasl-topic \
--bootstrap-server localhost:9093

hello
demo
try to enter
some messages
now I have right
to write this message
```
