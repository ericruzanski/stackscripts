#!/bin/bash

# Update the repos. 
sudo apt-get update && sudo apt-get dist-upgrade

# WGET will be installed by default. Let's fetch the stack. Agreeing to the license limits the need for user input. 
wget -nv -O- https://lambdalabs.com/install-lambda-stack.sh | I_AGREE_TO_THE_CUDNN_LICENSE=1 sh -

# Reboot the system. 
sudo reboot