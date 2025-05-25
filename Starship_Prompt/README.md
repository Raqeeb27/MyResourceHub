# Starship Prompt Installation Script

This folder contains a Bash script `linux-starship-install.sh` and a Powershell script `wimdows-starship-install.ps1` to automate the installation process of the Starship prompt, a highly customizable and fast shell prompt.

## Introduction

The Starship Prompt Installation Script simplifies the process of setting up the [Starship prompt](https://starship.rs/) on your system. Starship is a powerful and versatile prompt designed to provide relevant information in your shell prompt efficiently.
<br><br>

## Installation Steps

### Step 1: Update the system and Install wget
Update the system and install wget using the following command:

**Android(Termux)**
```bash
apt update && apt upgrade -y && apt install wget -y
```
**Arch**
```bash
sudo pacman -Syu --noconfirm && sudo pacman -Sy --noconfirm wget
```
**Debian**
```bash
sudo apt update && sudo apt upgrade -y && sudo apt install wget -y
```
**Fedora**
```bash
sudo dnf check-update -y && sudo dnf upgrade -y && sudo dnf install wget -y
```

### Step 2: Download and run the Installation Script
Download the starship-install.sh script using wget and execute it:
```bash
cd && wget -O ~/starship-install.sh https://raw.githubusercontent.com/Raqeeb27/MyResourceHub/main/Starship_Prompt/starship-install.sh && bash starship-install.sh && exit
```

### Step 3: Configure your terminal.
Follow the prompts to select a Starship prompt preset and configure your terminal.
<br><br>

## Features

- **Automated Installation:** Installs Starship prompt and its dependencies automatically.
- **Customizable:** Allows users to choose from various preset configurations or create a custom configuration.
- **Supports Multiple Distributions** Configures Starship prompt for Android, Arch, Debian and Fedora systems seamlessly.
- **Supports Multiple Terminals:** Configures Starship prompt for Bash, Zsh, and Fish shells.
- **Nerd Font Support:** Optionally installs the Caskaydia Cove Nerd font for enhanced symbol support.
- **Easy to Use:** Simple and interactive script with prompts for user input.

## Supported Platforms

This script is tested and supported on `Android`, `Arch`, `Debian` and `Fedora` systems.
