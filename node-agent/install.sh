#!/usr/bin/env bash
set -eu

GITHUB_URL=https://raw.githubusercontent.com
REPO=ivarprudnikov/remote-server-config
TAG=v1.0
INSTALL_FILE=node-agent/install.sh
DAEMON_WORKDIR=/var/configwatcher
DAEMON_TMP=/var/configwatcher/tmp
LOCAL_DAEMON_FILE=/usr/sbin/config-watcher-daemon.py
LOCAL_CONFIGWATCHER_SERVICE=/etc/systemd/system/ConfigWatcher.service

echo "Checking if running as root..."
if [ "$EUID" -ne 0 ]
  then echo "Please run as root as scripts installs a daemon service that needs privileged access"
  exit 1
fi

echo "Looking for curl..."
if ! command -v curl > /dev/null; then
	echo "Not found."
	echo ""
	echo "======================================================================================================"
	echo " Please install curl on your system using your favourite package manager."
	echo ""
	echo " Rerun this script installing curl."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

echo "Looking for python3..."
if ! command -v python3 > /dev/null; then
	echo "Not found."
	echo ""
	echo "======================================================================================================"
	echo " Please install python3 on your system using your favourite package manager."
	echo ""
	echo " Rerun this script after installing python3."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

echo "Looking for systemctl..."
if ! command -v systemctl > /dev/null; then
	echo "Not found."
	echo ""
	echo "======================================================================================================"
	echo " This daemon requires systemctl to be present"
	echo "======================================================================================================"
	echo ""
	exit 1
fi

echo "Creating working dir for daemon..."
mkdir -p "${DAEMON_WORKDIR}"

echo "Downloading daemon script..."
curl --location --progress-bar "${GITHUB_URL}/${REPO}/${TAG}/node-agent/config-watcher-daemon.py" > "${LOCAL_DAEMON_FILE}"
chmod a+x "${LOCAL_DAEMON_FILE}"

echo "Downloading ConfigWatcher service config..."
curl --location --progress-bar "${GITHUB_URL}/${REPO}/${TAG}/node-agent/ConfigWatcher.service" > "${LOCAL_CONFIGWATCHER_SERVICE}"
chmod 664 "${LOCAL_CONFIGWATCHER_SERVICE}"

echo "Starting ConfigWatcher..."
systemctl daemon-reload
systemctl enable ConfigWatcher
service ConfigWatcher restart

echo "All good, now copy config.json to the directory ${DAEMON_WORKDIR}"
