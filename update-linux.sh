#!/bin/bash

# Check if the user has sudo privileges
if [ "$(whoami)" != "root" ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Update package lists
apt-get update

# Upgrade installed packages
apt-get upgrade -y

# Remove any unnecessary packages
apt-get autoremove -y

# Clean up the package cache
apt-get clean

echo "System updated."
