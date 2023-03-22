#!/bin/bash

# Check if the user has sudo privileges
if [ "$(whoami)" != "root" ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Determine the package manager
if [ -x "$(command -v apt-get)" ]; then
    # Update the package lists
    apt-get update

    # Upgrade packages
    apt-get upgrade -y

    # Remove unnecessary packages
    apt-get autoremove -y

    # Clean up package cache
    apt-get clean

    echo "System update complete."
elif [ -x "$(command -v yum)" ]; then
    # Update package lists
    yum check-update

    # Upgrade packages
    yum update -y

    echo "System updated."
else
    echo "Unsupported package manager. Please use apt or yum."
    exit 1
fi
