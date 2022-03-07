#!/bin/bash

wget https://golang.org/dl/go1.16.7.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.7.linux-amd64.tar.gz
