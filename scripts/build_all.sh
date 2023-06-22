#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

TARGET_ARCH=$1

echo --- clean up Docker
bash docker_clean.sh
echo TARGET_ARCH: ${TARGET_ARCH}
echo --- build ctrlx-secomea image
bash build_image.sh ${TARGET_ARCH}
echo --- build snap
bash build_snap.sh ${TARGET_ARCH}