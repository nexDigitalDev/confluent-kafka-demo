#!/bin/bash

#clean Directories and log files


KAFKA_DIR=/your/preferred/path/kafka

FINISHED=$KAFKA_DIR/finished
SOURCE=$KAFKA_DIR/source
DATA=$KAFKA_DIR/data
SCRIPTS=$KAFKA_DIR/scripts

if [ "$(ls -A $FINISHED)" ]; then
    rm $FINISHED/*
fi

if [ "$(ls -A $SOURCE)" ]; then
    rm $SOURCE/*
fi

echo '' >  $KAFKA_DIR/logs/requestLog.txt
echo '' >  $KAFKA_DIR/logs/responseLog.txt


#Add connectors

curl -X POST -v -H "Content-Type: application/json" --data @$SCRIPTS/csv-source-aircraft.config http://localhost:8083/connectors

printf "\n\n"
sleep 1s

curl -X POST -v -H "Content-Type: application/json" --data @$SCRIPTS/csv-source-traffic.config http://localhost:8083/connectors
printf "\n\n"
sleep 1



#PUT FILES

cp $DATA/aircraft_airbus_airfrance_0.csv $SOURCE

cp $DATA/Flight_Log_Paris_01janv_2019.csv $SOURCE

cp $DATA/aircraft_airbus_airfrance_1.csv $SOURCE


sleep 1

#Create tables and streams

ksql http://localhost:8088 <<< "
RUN SCRIPT '$SCRIPTS/ksql-demo-P1.sql';
exit"

sleep 1

ksql http://localhost:8088 <<< "
RUN SCRIPT '$SCRIPTS/ksql-demo-P2.sql';
exit "
