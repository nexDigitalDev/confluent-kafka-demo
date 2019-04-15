# confluent-kafka-demo



Demonstration of the confluent kafka distribution with file connector (spooldir), ksql, muleSoft kafka connector. Possibility to activate the secutiry or to deploy on a k8s cluster



## Confluent Installation (Ubuntu Environment)

Step 1 : Install the Confluent public key. This key is used to sign the packages in the APT
repository.

> ```bash
> > $ wget -qO - https://packages.confluent.io/deb/5.1/archive.key | sudo apt-key add -
> ```
>
> Step 2 : Add the repository to your /etc/apt/sources.list by running this command: