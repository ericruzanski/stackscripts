#!/bin/bash

# Check if the user has sudo privileges
if [ "$(whoami)" != "root" ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Update package lists
yum check-update

# Upgrade installed packages
yum update -y

echo "System updated."
