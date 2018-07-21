#!/bin/bash
set -e

# Update package lists
sudo apt-get update

# Install basic dependencies
########
# Includes ARMEL cross-compilers and sshpass utility
########
sudo apt-get install -y cmake gdb build-essential gcc-arm-linux-gnueabi g++-arm-linux-gnueabi sshpass unzip avahi-daemon avahi-utils

# Set write permissions on headers & library installation paths
sudo chmod a+w /usr/local/include
sudo chmod a+w /usr/local/lib
