#!/bin/bash

# Install Surfshark VPN
sudo apt  install curl
curl -f https://downloads.surfshark.com/linux/debian-install.sh --output surfshark-install.sh
sh surfshark-install.sh