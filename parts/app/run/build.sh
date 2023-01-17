#!/bin/bash
set -e
# Environment
## Part Environment
export SNAPCRAFT_ARCH_TRIPLET="aarch64-linux-gnu"
export SNAPCRAFT_EXTENSIONS_DIR="/snap/snapcraft/8619/share/snapcraft/extensions"
export SNAPCRAFT_PARALLEL_BUILD_COUNT="4"
export SNAPCRAFT_PRIME="/home/boschrexroth/etherCAT-interface/prime"
export SNAPCRAFT_PROJECT_NAME="ctrlx-dotnet-ethercat-interface"
export SNAPCRAFT_PROJECT_VERSION="1.0.0"
export SNAPCRAFT_PROJECT_DIR="/home/boschrexroth/etherCAT-interface"
export SNAPCRAFT_PROJECT_GRADE="stable"
export SNAPCRAFT_STAGE="/home/boschrexroth/etherCAT-interface/stage"
export SNAPCRAFT_TARGET_ARCH="arm64"
export SNAPCRAFT_CONTENT_DIRS=""
export SNAPCRAFT_PART_SRC="/home/boschrexroth/etherCAT-interface/parts/app/src"
export SNAPCRAFT_PART_SRC_WORK="/home/boschrexroth/etherCAT-interface/parts/app/src/"
export SNAPCRAFT_PART_BUILD="/home/boschrexroth/etherCAT-interface/parts/app/build"
export SNAPCRAFT_PART_BUILD_WORK="/home/boschrexroth/etherCAT-interface/parts/app/build/"
export SNAPCRAFT_PART_INSTALL="/home/boschrexroth/etherCAT-interface/parts/app/install"
## Plugin Environment
## User Environment

set -xeuo pipefail
cp --archive --link --no-dereference . "${SNAPCRAFT_PART_INSTALL}"
