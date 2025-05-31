# Hadoop WordCount Automation Script

## Overview
This repository contains an automated `hadoop_wordcount.sh` script for running the Hadoop WordCount example. The script handles the configuration of Hadoop services, creation of directory structures, compilation of Java code, and execution of the WordCount job on Hadoop.

## Prerequisites
- [Hadoop](https://hadoop.apache.org/) installed on your system and properly configured. Run `hadoop version` command in yor terminal to verify. You can follow [this](https://github.com/Raqeeb27/MyResourceHub/blob/main/hadoop_files/README.md) guide for the setup.

## Usage
### Install wget

**Arch**
```bash
sudo pacman -Sy --noconfirm wget
```
**Debian**
```bash
sudo apt install wget -y
```
**Fedora**
```bash
sudo dnf install wget -y
```
### Download and run the Hadoop WordCount Automation Script
```bash
cd && wget -O ~/hadoop_wordcount.sh https://raw.githubusercontent.com/Raqeeb27/MyResourceHub/refs/heads/main/hadoop_files/word-count/hadoop_wordcount.sh && bash hadoop_wordcount.sh
```
