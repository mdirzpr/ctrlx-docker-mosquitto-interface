# ctrlx-docker-mosquitto-plc

Author: samuel.gilk@boschrexroth-us.com

Description: Containerized MQTT broker for use with ctrlX CORE. Automates generation and update of MQTT topics from PLC variables.

Instructions:
  1. Run build_all.sh, passing target architecture as an argument (Ex. ./build_all.sh "arm64")
  2. Install Container Engine app on ctrlX CORE or ctrlX CORE Virtual
  3. Install built ctrlx-docker-mosquitto-plc snap on ctrlX CORE or ctrlX CORE Virtual
  4. Make sure port forwarding is enabled on ctrlX CORE network adapter to access the broker externally
  
  
