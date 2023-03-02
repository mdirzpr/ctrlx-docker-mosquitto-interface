#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

TARGET_ARCH=$1

echo --- clean up Docker
bash docker_clean.sh
echo TARGET_ARCH: ${TARGET_ARCH}
echo --- build mosquitto
bash build_mosquitto.sh ${TARGET_ARCH}
echo --- build datalayer interface
bash build_ctrlx_datalayer_mqtt_interface.sh ${TARGET_ARCH}
echo --- build datalayer interface ui
bash build_ctrlx_datalayer_mqtt_ui.sh ${TARGET_ARCH}
echo --- build snap
bash build_snap.sh ${TARGET_ARCH}