Create an image with this Dockerfile which
- install the kafka-connect-spooldir (https://www.confluent.io/connector/kafka-connect-spooldir/) on the confluentinc/cp-kafka-connect image
- create directories (source, finished and error) used in the context of the demo

Make sur that the image is available on the k8s cluster nodes

Modify the cp-helm-charts/charts/cp-kafka-connect/values.yaml
