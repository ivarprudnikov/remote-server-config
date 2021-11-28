#!/usr/bin/env python3

import json
import os.path
import shutil
import subprocess
import time

EXTERNAL_CONFIG_FILE = 'config.json'
CURRENT_CONFIG_FILE = 'config.current.json'
KEY_PREINSTALL = 'preinstall'
KEY_INSTALL = 'install'
KEY_POSTINSTALL = 'postinstall'
TIMEOUT_SEC = 300.0
WATCH_SLEEP_SEC = 10


def read_config(filename):
    if not os.path.exists(filename):
        print('%s missing' % filename)
        return None
    with open(filename, 'r') as f:
        try:
            return json.load(f)
        except ValueError:
            print('could not parse %s' % filename)
            return None


def check_current_config_exists():
    if not read_config(CURRENT_CONFIG_FILE):
        with open(CURRENT_CONFIG_FILE, 'w') as file:
            file.write('{}')


def apply_config(config):
    all_commands = []
    for k in [KEY_PREINSTALL, KEY_INSTALL, KEY_POSTINSTALL]:
        if k in config:
            cmd = config.get(k)
            if type(cmd) is list:
                all_commands += config.get(k)
            elif type(cmd) is str:
                all_commands.append(cmd)

    if len(all_commands):
        try:
            subprocess.run(';'.join(all_commands),
                           shell=True,  # because the commands might use some shell features
                           check=False,  # do not throw if error
                           executable='/bin/bash',  # make the life a bit easier and allow [[]]
                           timeout=TIMEOUT_SEC)  # make sure the program is not stuck
        except subprocess.TimeoutExpired:
            print('Scripts take longer than %s' % TIMEOUT_SEC)
        except subprocess.SubprocessError:
            print('Scripts fail :(')
        else:
            try:
                shutil.copyfile(EXTERNAL_CONFIG_FILE, CURRENT_CONFIG_FILE)
            except shutil.SameFileError:
                print("Config did not change")
    return None


if __name__ == '__main__':
    print('Starting config-watcher-daemon')
    while True:
        check_current_config_exists()
        cfg_current = read_config(CURRENT_CONFIG_FILE)
        cfg_external = read_config(EXTERNAL_CONFIG_FILE)
        if cfg_external and cfg_external != cfg_current:
            print('Changes found - applying')
            apply_config(cfg_external)

        time.sleep(WATCH_SLEEP_SEC)
