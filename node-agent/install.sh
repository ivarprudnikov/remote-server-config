#!/usr/bin/env bash
set -eu

# install php server and overwrite the default index.html
apt update
DEBIAN_FRONTEND=noninteractive apt -y install apache2 php7.2 libapache2-mod-php7.2
mv /var/www/html/index.html /var/www/html/index.php
echo '<?php header("Content-Type: text/plain"); echo "Hello, world!\n"; ?>' > /var/www/html/index.php
chmod 0644 /var/www/html/index.php
chown nobody:nogroup /var/www/html/index.php
service apache2 start

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
