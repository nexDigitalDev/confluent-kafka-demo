# MuleSoft kafka connector

This page explains how to configure the kafka connectors on MuleSoft Anypoint Studio. 

By following this tutorial, you will be able to consume Kafka messages from MuleSoft, transform those messages into Soap Request and read the soap response from the mock Soap Server. 

Soap responses and requests will be logged into **/your/preferred/path/logs** directory.

At the end of this guide, you will have a flow like :
![Mule Schema](img/schema.png)

## Pre-requisite
Before starting the guide, make sure that :
* You have done all the settings described in this [page](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/README.md).
* You have installed [MuleSoft Anypoint Studio](https://www.mulesoft.com/lp/dl/studio).
* You have installed [SOAP UI](https://www.soapui.org/).


## Configuring MuleSoft

### Kafka Connector

First, create a new mule project and open it.
In the **Mule Palette** side menu, click on **Search in Exchange...**
Seach for the **Kafka Connector** and add it to the project.

![Kafka Connector](img/connector.png)

Drag the **Message Consumer** in the flow. Your flow looks like as follow now :

![Flow 1](img/flow1.png)

Click on the **Message Consumer** in the flow, and in **General > Basic Settings** click on the **"+"** button to add a connector configuration for the Apache Kafka Consumer.

Select **Kafka Basic Consumer Connection** for Connection field and fill other fields as the following image shows :

![Connector configuration](img/config.png)

Pass the topic name **TRAFFIC_ENRICHED** in **General > General > Topic**.


### Transform Json String to Json Object
After that, add a **Transform Message** module in the flow. This first module will convert the Jsonfy String into Json Object.

Click on this module in the flow and modify the output as :

```java
%dw 2.0
output application/json
---
{
	traffic:read(payload,"application/json")
}
````