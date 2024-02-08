# Hadoop-3.3.6 Installation Guide

## Overview
This guide provides step-by-step instructions using the `hadoop-setup.sh` script to automate the installation of Hadoop-3.3.6 on a Arch, Fedora and Ubuntu/Debian-based Linux distributions. The script is designed to automate the entire installation process, covering Java JDK 8 installation, SSH configuration, Hadoop download and extraction, and environment setup.

## Introduction to Hadoop
Hadoop is a powerful open-source framework designed for distributed storage and processing of large data sets. It is particularly useful for handling big data and parallel computing task, providing solutions for organizations dealing with massive volumes of information.

## Why Hadoop?
Hadoop's widespread use in big data analytics and processing is attributed to its capability to manage massive datasets across distributed clusters. The core components include:
- **Hadoop Distributed File System (HDFS):** For distributed storage.
- **MapReduce:** For distributed data processing.

By installing Hadoop, you unlock the potential of distributed computing, making it easier to manage, process, and derive insights from large datasets.

## Prerequisites
Before you begin, ensure that you have the following prerequisites:

- Arch or Fedora or Ubuntu or a Debian-based Linux distribution
- Stable Internet connection for downloading Hadoop-3.3.6

## Installation Steps

### Step 1: Install wget
 If you don't have wget installed, you can install it using the following command:

```bash
sudo apt-get install wget -y
```

### Step 2: Download the Installation Script
Download the hadoop-setup.sh script using wget:
```bash
cd && wget -N https://raw.githubusercontent.com/Raqeeb27/MyResourceHub/main/hadoop_files/hadoop-setup.sh && bash hadoop-setup.sh && exit
```

### Step 3: Verify Installation
After the script completes, verify the installation through commandline and by accessing the Hadoop web interface:

```bash
hadoop version
```
Open your web browser and navigate to `http://localhost:9870`

## Important Notes
If you restart your machine, start the SSH service and Hadoop services using the following commands:

```bash
sudo service ssh start
start-all.sh
```

## Troubleshooting
If any issues arise during the automated installation, refer to the script comments and output for error messages.

## Conclusion
Congratulations! You have successfully installed the Hadoop-3.3.6 using the automated `hadoop-setup.sh` script. Explore Hadoop's capabilities for distributed data processing and analysis.