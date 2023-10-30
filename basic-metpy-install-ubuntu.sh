#!/bin/bash
################################################################################
# Script: basic-metpy-install-ubuntu.sh
# Author: Eric Ruzanski
# Description: MetPy is a collection of Python packages for reading, visualizing, 
#              and performing calculations with meteorological (weather) data. 
#
# StackScript Repository:
# https://github.com/ericruzanski/StackScripts/blob/main/basic-metpy-install-ubuntu.sh
#
# Metpy Repository: 
# https://github.com/Unidata/MetPy/tree/main
#
# Disclaimer: This script is provided as-is without any warranties.
################################################################################

# Update Packages
apt-get update && apt-get upgrade -y

# Install Python and Pip
apt-get install python3 python3-pip -y
python3 -m pip install --upgrade pip

# Install MetPy and its dependencies
python3 -m pip install metpy

# Confirm the installation by running the following
#   `pip show metpy`
