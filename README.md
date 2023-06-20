# StackScripts

StackScripts is a collection of command line scripts (shell, python, ansible) intended for use as Linode 
StackScripts, now a part of Akamai Connected Cloud. These scripts are designed to automate the setup and 
configuration of various software stacks on Linode servers.

## Table of Contents

- [About](#about)
- [Scripts](#scripts)
- [Usage](#usage)
- [License](#license)

## About

This repository contains a curated collection of command line scripts that can be used as Linode StackScripts. 
Linode StackScripts provide a flexible way to automate the provisioning and configuration of Linode servers, 
making it easier to set up software stacks, deploy applications, and perform system configurations.

The scripts in this repository are written in various scripting languages like shell, Python, and Ansible, 
allowing you to choose the one that suits your needs. 

## Scripts

The following scripts are currently available in this repository:

- `script1.sh`: Shell script that sets up a LAMP stack for hosting PHP applications.
- `script2.py`: Python script that installs and configures a Django application server.
- `script3.yml`: Ansible playbook that deploys a Node.js application with Nginx as a reverse proxy.

Feel free to explore each script's directory for more information on usage and customization.

## Usage

To use a script from this repository as a Linode StackScript, follow these steps:

1. Copy the contents of the desired script to your clipboard.
2. Log in to your Linode account.
3. Navigate to the StackScripts section in the Linode Manager.
4. Click the "Create New StackScript" button.
5. Provide a name, description, and choose a script language.
6. Paste the copied script into the StackScript creation form.
7. Customize any variables or parameters within the script as needed.
8. Save and publish the StackScript.
9. You can now select the StackScript when deploying new Linode instances.

Please note that before using any script, it's important to review and understand its functionality to ensure 
it meets your specific requirements. Always exercise caution when running scripts, especially in production 
environments.

## License

This repository is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute the 
scripts within this repository, subject to the terms and conditions of the license.


