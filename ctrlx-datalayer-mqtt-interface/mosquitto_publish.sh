#!/bin/bash
# Publish Data
server=$1
topic=$2
value=$3
echo "MQTT WRITE: ${server}, TOPIC: ${topic}, VALUE: ${value}"
mosquitto_pub -h $server -t $topic -m "$value"