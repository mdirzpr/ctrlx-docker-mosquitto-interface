# ctrlx-docker-mosquitto-interface

Author: samuel.gilk@boschrexroth-us.com

Description: Containerized MQTT broker for use with ctrlX CORE. Automates generation and update of MQTT topics from datalayer nodes.

Instructions:

1. Install docker and configure buildx
2. Run build_all.sh, passing target architecture as an argument (Ex. ./build_all.sh "arm64")
3. Install Container Engine app on ctrlX CORE or ctrlX CORE Virtual
4. Install built ctrlx-docker-mosquitto-interface snap on ctrlX CORE or ctrlX CORE Virtual
5. Make sure port forwarding is enabled on ctrlX CORE network adapter to access the broker externally
6. Write to ctrlx-datalayer-mqtt-interface/MQTT_Root the paths you'd like to publish to MQTT
