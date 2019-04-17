# MuleSoft Kafka connector

This page explains how to configure the kafka connectors on MuleSoft Anypoint Studio. 

By following this tutorial, you will be able to consume Kafka messages from MuleSoft, transform those messages into Soap Requests. Those Soap Requests will be sent to a Web Service. Soap Requests and their responses will be logged in files. 



At the end of this guide, you will have a flow like :
![Mule Schema](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/mule/img/schema.PNG?raw=true)

## Pre-requisite
Before starting the guide, make sure that :
* You have done all the settings described in this [page](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/README.md).
* You have installed [MuleSoft Anypoint Studio](https://www.mulesoft.com/lp/dl/studio).
* You have installed [SOAP UI](https://www.soapui.org/).


## Configure SOAP UI

This part is **optional** if you have already a running Soap Server. If you want to set up a mock web service with Soap UI, please do this section.

Open Soap UI and create a new SOAP Project using the wsdl file at **/your/preferred/path/confluent-kafka-demo/mule/airbus-hello.wsdl**.
> You can also use another wsdl file just make sure that further bellow your soap request matches to the format defined in this wsdl file.

Right-click on **Hello_Binding** and create a MockService with **path** configured to **/SayHello** on the port **9099**.

Click on the Mock Service that you created and run it. 

Let it run until the end of this tutorial.


## Configuring MuleSoft

The flow in MuleSoft is composed of :
- Kafka Consumer
- Dataweave to transfom kafka messages
- Web Service
- File Logging to save requests and responses

Before starting this section, open MuleSoft Anypoint and create a new mule project. Open the new created project.

### Kafka Connector

In the **Mule Palette** side menu, click on '**Search in Exchange...**'.
Seach for **Kafka Connector** and add it to the project.

![Kafka Connector](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/mule/img/connector.PNG?raw=true)

Once the kafka connector is added to the project, drag the **Message Consumer** from **Apache Kafka** in **MulePalette** side menu to the flow. Your flow looks like as follow now :

![Flow 1](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/mule/img/flow1.PNG?raw=true)

Click on this **Message Consumer** connector in the flow, and in **General > Basic Settings** click on the **"+"** button to add a connector configuration for the Apache Kafka Consumer.

Select **Kafka Basic Consumer Connection** for Connection field and fill other fields as the following image shows :
> If you want to connect to a secured Kafka Cluster, instead of using **Kafka Basic Consumer Connection** you can choose the adapted connexion mode.

![Connector configuration](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/mule/img/config.PNG?raw=true)


Pass the topic name **TRAFFIC_ENRICHED** in **General > General > Topic**.
> This tutorial is based on the **TRAFFIC_ENRICHED** topic created in the previous [tutorial](https://github.com/nexDigitalDev/confluent-kafka-demo). If you want to use another topic, please adapt the current tutorial to your use.

![Connector configuration](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/mule/img/config2.PNG?raw=true)


### Transform Json String to Json Object
After that, add a **Transform Message** module in the flow.

![Flow 2](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/mule/img/flow2.PNG?raw=true)

This module will convert the Json String into Json Object.

Click on this module in the flow and modify the **output** to match the code bellow :

```java
%dw 2.0
output application/json
---
{
	traffic:read(payload,"application/json")
}
````

### Transform Json Object to Soap-XML

Add a new **Transform Message** module in the flow.

![Flow 3](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/mule/img/flow3.PNG?raw=true)

This module transform the Json Object to the Soap-XML Format and modify the output as follow :

```java
%dw 2.0
output application/xml writeDeclaration=false
ns soapenv http://schemas.xmlsoap.org/soap/envelope/
ns hel http://www.examples.com/wsdl/HelloService.wsdl
---

{
	soapenv#Envelope: {
		soapenv#Body: {
				date: payload.traffic.DATE,
				vol: payload.traffic.VOL,
				depart: payload.traffic.DEPART,
				arrivee: payload.traffic.ARRIVEE,
				appareil: (payload.traffic.APPAREIL
default "") ++ payload.traffic.APPAREIL,
				distance: payload.traffic.DISTANCE,
				"type": payload.traffic.T_TYPE,
				aircraft: payload.traffic.AIRCRAFT,
				longueur: payload.traffic.LONGUEUR,
				autonomie: payload.traffic.AUTONOMIE,
				passagers: payload.traffic.PASSAGERS
		}
	}
	
}
```
> If you use another Soap Server, please adapt the above output format.

### Log Soap Request to File

After the previous **Transform Message** module, add a **Logger** module in the flow. There is typically nothing to configure with this log module.

Then, add a **File Write** module. Configure the **General > General > Path** to **/your/preferred/path/confluent-kafka-demo/logsrequestLog.txt** and set the **Write Mode** (set to **APPEND** if you want to keep every request).

Now your flow should look like :

![Flow 4](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/mule/img/flow4.PNG?raw=true)

### HTTP Request

Add the **HTTP Request** module to the flow.

![Flow 5](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/mule/img/flow5.PNG?raw=true)

Configure the **General > Request** as the following image shows :

![Soap Request](https://github.com/nexDigitalDev/confluent-kafka-demo/blob/master/mule/img/soap.PNG?raw=true)

>If you use another Soap server, please modify the URL.

### Log Soap Response to File

By the same way, add a **Logger** module and a **File Write** module in the flow to log the Soap Response.

Configure the **File Write** module to log the reponses into the **/your/preferred/path/confluent-kafka-demo/logs/responseLog.txt** file.

## Test your flow

Now, launch your application and test the configuration. Basically if you followed the previous tutorial, you have already produced data in the **TRAFFIC_ENRICHED** topic. You can verify that after lauching the MuleSoft App, your log files **/your/preferred/path/confluent-kafka-demo/logs/requestLog.txt** and **/your/preferred/path/confluent-kafka-demo/logs/responseLog.txt** have logged Soap requests and responses based on those messages you produced during the previous tutorial.


Keep your MuleSoft App running and in a terminal try to pass new streaming data :

```bash
$ cp /your/preferred/path/confluent-kafka-demo/data/Flight_Log_Paris_03mars5_2019.csv /your/preferred/path/confluent-kafka-demo/source/
```
> Don't forget to change the path !

You will observe that during the running of the Mule App, all new incoming data will be transformed into Soap requests and responses.

Now you can manipulate with Kafka and MuleSoft to test your configuration.