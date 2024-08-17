# StackScripts

The StackScripts repository is a collection of command line scripts (shell, python, ansible) intended for use on Akamai Connected Cloud.

## Table of Contents

- [About](#about)
- [Documentation](#documentation)
- [Usage](#usage)
- [License](#license)

## About

StackScripts automate the deployment and configuration of cloud servers (compute instances or "Linodes" on Akamai Connected Cloud), streamlining the setup of software stacks, application deployment, and overall system configurations. Note, they are simply scripts that run at instance deployment. StackScripts differ from metadata.

## Documentation

To learn more about StackScripts on Akamai Connected Cloud, you can visit the following links:

- [StackScripts Product Page](https://www.linode.com/products/stackscripts/): This page provides an overview of StackScripts on Akamai Connected Cloud, highlighting their benefits and features.

- [StackScripts Documentation](https://www.linode.com/docs/products/tools/stackscripts/): The official documentation offers comprehensive guidance on using StackScripts, including usage instructions and examples.

## Usage

To use a script from this repository as an Akamai Connected Cloud StackScript, simply follow these easy steps:

1. Copy the script to your clipboard.
2. Log in to your Akamai Cloud Manager account.
3. Under StackScripts, create a new StackScript.
4. Give the new StackScript a name, description, and assign it the appropriate image(s).
5. Paste the clipboard script into the appropriate section of the StackScript creation form.
6. Check for errors and customize any variables or parameters within the script as desired.
7. Save and publish the new StackScript. 

You can now deploy the StackScript when creating new compute instances on Akamai Connected Cloud.

*DISCLAIMER* - Before using any script, it's important to review and understand its functionality to ensure it achieves your specific intentions. Always exercise caution when running these scripts.

## License

This repository is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute the scripts within this repository, subject to the terms and conditions outlined in the license.
