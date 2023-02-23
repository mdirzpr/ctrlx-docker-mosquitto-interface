# ctrlx-docker-mosquitto-plc

Author: samuelgilk@boschrexroth-us.com

Description: Containerized MQTT broker for use with ctrlX CORE. Automates generation and update of MQTT topics from PLC variables.

Instructions:
  1. Run build_all.sh, passing target architecture as an argument (Ex. ./build_all.sh "arm64")
  2. Install built snap on ctrlX CORE or ctrlX CORE Virtual
  3. Make sure port forwarding is enabled on ctrlX CORE network adapter to access the broker externally
  
  
