# Hadoop WordCount Automation Script

## Overview
This repository contains an automated setup script for running the Hadoop WordCount example. The script handles the configuration of Hadoop services, creation of directory structures, compilation of Java code, and execution of the WordCount job on Hadoop.

## Prerequisites
- [Hadoop](https://hadoop.apache.org/) installed on your system and properly configured. You can directly download it from [here](https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz).

## Usage
Run the below command:
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo apt install wget -y
   wget https://raw.githubusercontent.com/Raqeeb27/MyResourceHub/main/hadoop_files/word-count/hadoop_wordcount.sh && bash hadoop_wordcount.sh
