#!/bin/bash
set -e

SSHD_PORT=2222
SSHD_FILE=/etc/ssh/sshd_config
SUDOERS_FILE=/etc/sudoers
  
# 0. update package lists
sudo apt-get update

# 0.1. reinstall sshd (workaround for initial version of WSL)
sudo apt remove -y --purge openssh-server
sudo apt install -y openssh-server

# 0.2. install basic dependencies
########
# Includes ARMEL cross-compilers and sshpass utility
########
sudo apt install -y cmake gcc clang gdb valgrind build-essential gcc-arm-linux-gnueabi g++-arm-linux-gnueabi sshpass unzip avahi-daemon avahi-utils

# 1.1. configure sshd
sudo cp $SSHD_FILE ${SSHD_FILE}.`date '+%Y-%m-%d_%H-%M-%S'`.back
sudo sed -i '/^Port/ d' $SSHD_FILE
########
# Not supported on Ubuntu 18.04
########
#sudo sed -i '/^UsePrivilegeSeparation/ d' $SSHD_FILE
sudo sed -i '/^PasswordAuthentication/ d' $SSHD_FILE
echo "# configured by CLion"      | sudo tee -a $SSHD_FILE
echo "Port ${SSHD_PORT}"          | sudo tee -a $SSHD_FILE
########
# Not supported on Ubuntu 18.04
########
#echo "UsePrivilegeSeparation no"  | sudo tee -a $SSHD_FILE
echo "PasswordAuthentication yes" | sudo tee -a $SSHD_FILE
# 1.2. apply new settings
sudo service ssh --full-restart
  
# 2. autostart: run sshd 
sed -i '/^sudo service ssh --full-restart/ d' ~/.bashrc
# We also need dbus and Avahi
sed -i '/^sudo /etc/init.d/dbus start/ d' ~/.bashrc
sed -i '/^sudo /etc/init.d/avahi-daemon start/ d' ~/.bashrc
# Allow running make as sudo without password prompt
echo "%sudo ALL=(ALL) NOPASSWD: /usr/sbin/service ssh --full-restart, /usr/bin/make, /etc/init.d/dbus start, /etc/init.d/avahi-daemon start" | sudo tee -a $SUDOERS_FILE
cat << 'EOF' >> ~/.bashrc
dbus_status=$(/etc/init.d/dbus status)
if [[ $dbus_status = *"is not running"* ]]; then
  sudo /etc/init.d/dbus start
fi
avahi_status=$(/etc/init.d/avahi-daemon status)
if [[ $avahi_status = *"is not running"* ]]; then
  sudo /etc/init.d/avahi-daemon start
fi
sshd_status=$(service ssh status)
if [[ $sshd_status = *"is not running"* ]]; then
  sudo service ssh --full-restart
fi
EOF
  

# summary: SSHD config info
echo 
echo "SSH server parameters ($SSHD_FILE):"
echo "Port ${SSHD_PORT}"
########
# Not supported on Ubuntu 18.04
########
#echo "UsePrivilegeSeparation no"
echo "PasswordAuthentication yes"