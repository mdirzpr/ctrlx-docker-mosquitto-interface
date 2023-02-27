#!/bin/bash
TARGET_ARCH=$1
echo TARGET_ARCH: ${TARGET_ARCH}
echo --- build mosquitto
bash build_mosquitto.sh ${TARGET_ARCH}
echo --- build datalayer interface
bash build_ctrlx_datalayer_mqtt_interface.sh ${TARGET_ARCH}
echo --- build snap
bash build_snap.sh ${TARGET_ARCH}