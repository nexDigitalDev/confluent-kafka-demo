Create an image with this [Dockerfile](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/k8s/connect-spooldir/Dockerfile) which
- install the kafka-connect-spooldir (https://www.confluent.io/connector/kafka-connect-spooldir/) on the confluentinc/cp-kafka-connect image
- create directories (source, finished and error) used in the context of the demo

Make sur that the image is available on the k8s cluster nodes

Modify the cp-helm-charts/charts/cp-kafka-connect/values.yaml
- image reference: change the name of the image by putting the image name and version that you used when creating the new image from the Dockerfile
```-image: confluentinc/cp-kafka-connect
-imageTag: 5.1.2

+image: nexdigital/spooldir
+imageTag: latest
```
- connector location : configure the plugin.path parameter
```-  "plugin.path": "/usr/share/java"
+  "plugin.path": "/usr/share/java,/usr/share/confluent-hub-components"
````
