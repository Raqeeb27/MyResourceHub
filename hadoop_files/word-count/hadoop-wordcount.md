# Hadoop WordCount Automation Script

## Overview
This repository contains an automated `hadoop_wordcount.sh` script for running the Hadoop WordCount example. The script handles the configuration of Hadoop services, creation of directory structures, compilation of Java code, and execution of the WordCount job on Hadoop.

## Prerequisites
- [Hadoop](https://hadoop.apache.org/) installed on your system and properly configured. Run `hadoop version` command in yor terminal to verify. You can follow [this](https://github.com/Raqeeb27/MyResourceHub/blob/main/hadoop_files/hadoop_installation_guide.md) guide for the setup.

## Usage
### Run the below commands:

   Update and upgrade system packages
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
   Install wget
   ```bash
   sudo apt install wget -y
   ```
   Download and run the Hadoop WordCount Automation Script
   ```bash
   cd && wget -N https://raw.githubusercontent.com/Raqeeb27/MyResourceHub/main/hadoop_files/word-count/hadoop_wordcount.sh && bash hadoop_wordcount.sh
   ```
