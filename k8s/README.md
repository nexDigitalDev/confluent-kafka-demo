# Kubernetes Deployment

This page shows how to deploy this [demo](https://github.com/nexDigitalDev/confluent-kafka-demo) on Kubernetes.

The Kubernetes deployment is mainly based on confluent helm charts that are available at https://github.com/confluentinc/cp-helm-charts
By default these helm charts will deploy a kafka cluster with 3 kafka brokers, 3 zookeepers, 1 kafka connect, 1 ksql server and 1 schema registry

To be able to modify the helm charts, the first step is to download it
https://github.com/confluentinc/cp-helm-charts.git

