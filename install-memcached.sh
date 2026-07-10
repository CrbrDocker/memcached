#!/bin/bash
#
# install-memcached.sh
#
# Installs memcached on the crbr Debian base image. Copied into the image and
# run once at build time (see Dockerfile), then removed. All runtime tuning is
# done through the MEM / MAXCONN env vars in the Dockerfile CMD, so there is
# nothing to configure here beyond the package install.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

apt-get -y update
apt-get -y dist-upgrade
apt-get -y install --no-install-recommends memcached

# APT cache + lists cleanup (an `apt-get update` will be needed before any
# further install in a derived image).
apt-get clean
apt-get autoclean
rm -rf /var/lib/apt/lists/* 2>/dev/null || true
rm -rf /var/cache/apt/*pkgcache.bin 2>/dev/null || true

# Final cleanup before sealing the image.
rm -rf /tmp/* /var/tmp/* 2>/dev/null || true
find /var/log -type f -delete 2>/dev/null || true
