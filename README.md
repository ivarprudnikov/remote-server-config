A bare bones server management system
=====================================

Just install the daemon on each of your servers (as a `root`). 
You will then be able to copy `config.json` to the server 
directory `/var/configwatcher` and the daemon will apply it (if it changed).

## Architecture

There are two parts to this. First, there needs to be a running daemon on the remote server (see `Installation`). 
This daemon is responsible for checking if the configuration changes and then executing the commands in that 
configuration. Secondly, the configuration (`config.json`) needs to be synced to each remote server from your 
preferred host. It is effectively a rudimentary push based system.

### Changes

Change detection compares two files before determining if it needs to be applied - `config.json` and `config.current.json`.
The latter will be set to `{}` on the first run. When you copy over `config.json` then any change in the content will 
trigger execution of the recognised script directives.

### Script execution

Configuration scripts will be executed in a separate bash shell.

### Success

If configuration succeeds then it will be copied over to `config.current.json` and will represent the current state. 
Further configuration changes will be compared against it.

### Failure

In a case when daemon is not capable to execute the given commands the system will interpret it as a configuration 
failure. It will restart after a timeout and will rerun the commands in the same order.

If the failure causes the daemon to die then it will be respawned by a ConfigWatcher service.

## Usage

### Installation

**Prerequisites**

* run as `root`
* server must have 
    * `curl` - to download installation files
    * `python3` - to run the daemon
    * `systemctl` - to enable a service which will run the daemon

**Install daemon**

On each of your servers run as a `root`:

```shell
curl -s "https://raw.githubusercontent.com/ivarprudnikov/remote-server-config/v1.1/node-agent/install.sh" | bash
```

### Change configuration

See `Configuration` section below to understand the contents of `config.json`.

Copy the `config.json` to each of the servers that have the daemon running:

```shell
for HOST in server1 server2 server3; do
    scp config.json $HOST:/var/configwatcher/config.json
done
```

## config.json

Configuration consists of 3 directives:

* `preinstall` - bash command (string or array of strings)
* `install` - bash command (string or array of strings)
* `postinstall` - bash command (string or array of strings)

The running daemon will concat the commands in the given order and will execute in a separate bash shell.

Commands must successfully execute within 5 minutes, otherwise the operation will 
be considered unsuccessful (see `Failure` above).

### Example

Install Apache server, start it and host a PHP file. 

```json
{
  "preinstall": "DEBIAN_FRONTEND=noninteractive apt update",
  "install": "DEBIAN_FRONTEND=noninteractive apt -y install apache2 php7.2 libapache2-mod-php7.2 curl",
  "postinstall": [
    "mkdir -p /var/www/html/",
    "touch /var/www/html/index.html",
    "mv /var/www/html/index.html /var/www/html/index.php",
    "echo '<?php header(\"Content-Type: text/plain\"); echo \"Hello, world!\\n\"; ?>' > /var/www/html/index.php",
    "chmod 0644 /var/www/html/index.php",
    "chown nobody:nogroup /var/www/html/index.php",
    "service apache2 restart",
    "curl localhost"
  ]
}
```
