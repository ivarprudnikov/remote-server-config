#!/usr/bin/env python3

import json
import os.path
import time


def read_config():
    print('reading config')
    if not os.path.exists('config.json'):
        print('config.json missing')
        return None
    f = open('config.json', "r")
    try:
        data = json.load(f)
    except ValueError:
        print('could not parse config.json')
        return None
    if f:
        f.close()
    return data


if __name__ == '__main__':
    print('Starting config-watcher-daemon')
    while True:
        cfg = read_config()

        time.sleep(5)
