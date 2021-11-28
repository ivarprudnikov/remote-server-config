#!/usr/bin/env bash
set -eu

# Create a working directory
mkdir -p /var/configwatcher
# Copy a config watcher script
cp -f config-watcher-daemon.py /usr/sbin/
# Install a system service which will start the watcher
cp -f ConfigWatcher.service /etc/systemd/system/
chmod 664 /etc/systemd/system/ConfigWatcher.service
systemctl daemon-reload
systemctl enable ConfigWatcher
service ConfigWatcher start
