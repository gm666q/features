#!/bin/bash

export SDK_VARIANT="${VARIANT:-"hardfp"}"

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release
# Get an adjusted ID independent of distro variants
MAJOR_VERSION_ID=$(echo ${VERSION_ID} | cut -d . -f 1)
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    ADJUSTED_ID="debian"
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
echo "Running apt-get update..."
apt update -y
apt -y install --no-install-recommends cmake git-core make python3

if [ "${SDK_VARIANT}" = "softfp" ]; then
    git clone https://github.com/vitasdk-softfp/vdpm
else
    git clone https://github.com/vitasdk/vdpm
fi

cd vdpm
./bootstrap-vitasdk.sh
./install-all.sh

cd ..
rm -rf vdpm

echo "Done!"
