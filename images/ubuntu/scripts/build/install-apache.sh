#!/bin/bash -e
################################################################################
##  File:  install-apache.sh
##  Desc:  Install Apache HTTP Server
################################################################################

# Install Apache
apt-get install apache2

# Disable apache2.service
systemctl is-active --quiet apache2.service && systemctl stop apache2.service
systemctl disable apache2.service

# DEVZERO START - disabling as a hack cuz docker image and can't run things
sudo systemctl enable apache2.service
# DEVZERO STOP
# invoke_tests "WebServers" "Apache"
