# <span style="vertical-align: middle;"><img src='../Software_Downloads/logos/starship-logo.png' alt="Starship_Logo" style="width:60px;height:auto; margin-bottom: -3px;"></span> Starship Prompt Installation Script 

This folder contains a Bash script `linux-starship-install.sh` and a PowerShell script `windows-starship-install.ps1` to automate the installation process of the Starship prompt, a highly customizable and fast shell prompt.

## Overview

The Starship Prompt Installation Script simplifies the process of setting up the [Starship prompt](https://starship.rs/) on your system. Starship is a powerful and versatile prompt designed to provide relevant information in your shell prompt efficiently.

<br><br>

## Installation Steps

- [Linux (Android, Arch, Debian, Fedora)](#linux-android-arch-debian-fedora)
    - [Step 1: Update the system and install wget](#step-1-update-the-system-and-install-wget)
    - [Step 2: Download and run the installation script](#step-2-download-and-run-the-installation-script)
    - [Step 3: Configure your terminal](#step-3-configure-your-terminal)
- [Windows](#windows)
    - [Step 1: Download the PowerShell installation script](#step-1-download-the-powershell-installation-script)
    - [Step 2: Run the installation script as Administrator](#step-2-run-the-installation-script-as-administrator)
    - [Step 3: Configure your terminal](#step-3-configure-your-terminal)


### Linux (Android, Arch, Debian, Fedora)

#### Step 1: Update the system and Install wget
Update the system and install wget using the following command:

**Android (Termux)**
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

#### Step 2: Download and run the Installation Script
Download the starship-install.sh script using wget and execute it:
```bash
cd && wget -O ~/linux-starship-install.sh https://raw.githubusercontent.com/Raqeeb27/MyResourceHub/refs/heads/main/Starship_Prompt/linux-starship-install.sh && bash linux-starship-install.sh && exit
```

#### Step 3: Configure your terminal.
Set the desired Nerd font from your terminal's settings to ensure all symbols display correctly.

<br><br>

### Windows

#### Step 1: Download the PowerShell Installation Script

Download the script from the repository or using PowerShell:
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Raqeeb27/MyResourceHub/refs/heads/main/Starship_Prompt/windows-starship-install.ps1" -OutFile "$HOME\windows-starship-install.ps1"
```

#### Step 2: Run the Installation Script as Administrator

Open **PowerShell** or **Windows Terminal** as Administrator, then run:
```powershell
Set-Location $HOME
powershell -ExecutionPolicy Bypass -File .\windows-starship-install.ps1
```

#### Step 3: Configure your terminal.
- Set the desired Nerd font (such as "CaskaydiaCove Nerd Font") from your terminal's settings to ensure all symbols display correctly.
- Restart your terminal or run `. $PROFILE` to apply changes.

<br>

## Features

- **Automated Installation:** Installs Starship prompt and its dependencies automatically.
- **Customizable:** Allows users to choose from various preset configurations or create a custom configuration.
- **Supports Multiple Distributions:** Configures Starship prompt for Android, Arch, Debian, Fedora, and Windows systems seamlessly.
- **Supports Multiple Terminals:** Configures Starship prompt for Bash, Zsh, Fish (Linux), and PowerShell (Windows).
- **Nerd Font Support:** Installs the Caskaydia Cove Nerd font for enhanced symbol support.
- **Easy to Use:** Simple and interactive script with prompts for user input.

## Supported Platforms

This script is tested and supported on:
- **Android (Termux)**
- **Arch Linux**
- **Debian/Ubuntu**
- **Fedora**
- **Windows 10/11 (PowerShell 5+ or PowerShell Core)**
