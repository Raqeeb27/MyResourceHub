# Pig-0.17.0 Installation Guide

## Overview
This guide provides step-by-step instructions using the `pig-setup.sh` script to automate the installation of Pig-0.17.0 on a Arch, Fedora and Ubuntu/Debian-based Linux distributions. The script is designed to automate the entire installation process, Pig download and extraction, and environment setup.

## Prerequisites
Before you begin, ensure that you have the following prerequisites:

- Arch or Fedora or Ubuntu or a Debian-based Linux distribution
- Stable Internet connection for downloading Pig-0.17.0
- [Hadoop](https://hadoop.apache.org/) installed on your system and properly configured. Run `hadoop version` command in yor terminal to verify. You can follow [this](https://github.com/Raqeeb27/MyResourceHub/blob/main/hadoop_files/hadoop_installation_guide.md) guide for the setup.


## Installation Steps

### Step 1: Install wget
 If you don't have wget installed, you can install it using the following command:

```bash
sudo apt-get install wget -y
```

### Step 2: Download the Installation Script
Download the pig-setup.sh script using wget:
```bash
cd && wget -N https://raw.githubusercontent.com/Raqeeb27/MyResourceHub/main/hadoop_files/pig-setup.sh && bash pig-setup.sh && exit
```

### Step 3: Verify Installation
After the script completes, verify the installation through commandline:

```bash
pig version
```

## Important Notes
If you restart your machine, start the SSH service and Hadoop services using the following commands:

```bash
sudo service ssh start
start-all.sh
```

## Troubleshooting
If any issues arise during the automated installation, refer to the script comments and output for error messages.

## Conclusion
Congratulations! You have successfully installed the Pig-0.17.0 using the automated `pig-setup.sh` script.