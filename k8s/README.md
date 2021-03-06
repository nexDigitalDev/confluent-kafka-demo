# Kubernetes Deployment

This page shows how to deploy this [demo](https://github.com/nexDigitalDev/confluent-kafka-demo) on Kubernetes.
The prerequisites are to have a kubernetes cluster with helm/tiller installed

The Kubernetes deployment is mainly based on confluent helm charts that are available at https://github.com/confluentinc/cp-helm-charts
By default these helm charts will deploy a kafka cluster with 3 kafka brokers, 3 zookeepers, 1 kafka connect, 1 ksql server and 1 schema registry

To be able to modify the helm charts, the first step is to download it
https://github.com/confluentinc/cp-helm-charts.git

The main file to configure the deployment is cp-helm-charts/values.yaml
In this file you can configure
- the number of instances for kafka-broker and for zookeepers
- the persitence characteritics for kafka-broker and for zookeepers.

You can also specify the images used for each component in the cp-helm-charts/{component}/values.yaml

## Kafka connect
In this demo, we will use the spooldir connector (https://www.confluent.io/connector/kafka-connect-spooldir/) to treat and stream data from incomming files.
We have to install and configure this connector on the kafka-connect component. We will do it by creating a ready to use image and then change cp-helm-charts/values.yaml to reference this new image.
The detail of this configuration is described [here](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/k8s/connect-spooldir/README.md)

## Deploy the cluster
After configuring the helm charts, you can then launch the installation.
`helm install ./cp-helm-charts --name confluent --namespace confluent`
This command will deploy the right pods and services with release name confluent (--name) on the k8s namespace confluent (--namespace)

## Kafka ksql
In order to communicate easily with ksql-server it is useful to create a pod with a ksql-client.
You can do it by using the ksql-client-pod.yaml

Then to execute ksql client, you have first to connect to the pod shell
`kubectl exec -it ksql-client -n confluent -- /bin/bash` (assuming that confluent is the k8s namespace that was used)
And then execute ksql with the right connection (by targeting the deployed services)
`ksql http://confluent-cp-ksql-server:8088`
