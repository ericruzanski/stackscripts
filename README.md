# StackScripts

The StackScripts repository is a collection of command line scripts (shell, python, ansible) 
intended for use on Linode, now Akamai Connected Cloud. 

## Table of Contents

- [About](#about)
- [Documentation](#documentation)
- [Usage](#usage)
- [License](#license)

## About

StackScripts automate the deployment and configuration of Linode cloud servers, streamlining 
the setup of software stacks, application deployment, and overall system configurations. Note, they
are simply a script that runs at VPS deployment. StackScripts differ from cloud-init/metadata. 

## Documentation

To learn more about Linode StackScripts, you can visit the following 
links:

- [Linode StackScripts Product 
Page](https://www.linode.com/products/stackscripts/): This page provides 
an overview of Linode StackScripts, highlighting their benefits and 
features.

- [Linode StackScripts 
Documentation](https://www.linode.com/docs/products/tools/stackscripts/): 
The official documentation offers comprehensive guidance on using 
StackScripts, including usage instructions and examples.

## Usage

To use a script from this repository as a Linode StackScript, simply follow these easy steps:

1. Copy the script to your clipboard.
2. Log in to your Linode account.
3. Under StackScripts, create a new StackScript.
4. Give the new StackScript a name, description, and assign it the appropriate Linode image(s). 
6. Paste the clipboard script into the appropriate section of the StackScript creation form.
7. Customize any variables or parameters within the script as desired.
8. Save and publish the new StackScript.

You can now deploy the StackScript when creating new Linode instances.

To view all of my public StackScripts on Linode, type "username:ericruzanski" in the Community
StackScripts search bar. 

*DISCLAIMER* - Before using any script, it's important to review and understand its 
functionality to ensure it achieves your specific intentions. Always exercise caution 
when running these scripts. 

## License

This repository is licensed under the [MIT License](LICENSE). You are free to use, modify, 
and distribute the scripts within this repository, subject to the terms and conditions outlined 
in the license.
