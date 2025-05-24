#!/bin/bash

# Script: starship-install.sh
# Description: Install Starship prompt with any desired preset, configure terminals, and set fonts.
# Author: Mohammed Abdul Raqeeb
# Date: 31/01/2024


# ------- Automated Starship Installation Script -------

## ===========================================================================
### Functions

#Function to print blank lines and sleep
log_and_pause(){
    sleep 2
    echo -e "\n"
}

## --------------------------------------------------------------------------
# Function to determine the distro
determine_distro() {
    # Check for distribution type
    if [ -d ~/.termux ]; then
        distro="android"
    elif [ -f /etc/arch-release ]; then
        distro="arch"
    elif [ -f /etc/debian_version ]; then
        distro="debian"
    elif [ -f /etc/fedora-release ]; then
        distro="fedora"
    else
        echo "Unsupported distribution."
        exit 1
    fi
}

## --------------------------------------------------------------------------
# Function to install required dependencies
install_dependencies() {
    echo -e "\nInstalling dependencies..."
    log_and_pause

    case $distro in
        "android")
            apt install -y curl wget unzip sl || { echo "Error: Dependencies installation failed."; exit 1 ;}
            ;;
        "arch")
            sudo pacman -Sy --noconfirm curl wget unzip || { echo "Error: Dependencies installation failed."; exit 1 ;}
            ;;
        "debian")
            sudo apt install curl wget unzip -y || { echo "Error: Dependencies installation failed."; exit 1 ;}
            ;;
        "fedora")
            sudo dnf install curl wget unzip -y || { echo "Error: Dependencies installation failed."; exit 1 ;}
            ;;
    esac

    log_and_pause
}

## --------------------------------------------------------------------------
# Function to install Starship
install_starship(){
    # Check if Starship is installed
    if ! command -v starship &>/dev/null; then
        echo "Starship not found, installing..."
        log_and_pause
        # Open a new terminal window to perform the update interactively
        case $distro in
            "android")
                apt install -y starship || { echo "Error: Starship installation failed."; exit 1 ;}
                ;;
            "arch")
                sudo pacman -Sy --noconfirm starship || { echo "Error: Starship installation failed."; exit 1 ;}
                ;;
            "debian")
                sudo curl -sS https://starship.rs/install.sh | sh -s -- -y || { echo "Error: Starship installation failed."; exit 1 ;}
                ;;
            "fedora")
                sudo curl -fsSL https://starship.rs/install.sh | bash -s -- -y || { echo "Error: Starship installation failed."; exit 1 ;}
                ;;
        esac
    else
        echo -e "Starship is already installed.\n"
    fi

    log_and_pause
}

## --------------------------------------------------------------------------
# Function to prompt user for preset selection
select_starship_preset() {
    echo -e "\nSelect a Starship prompt preset:\n"

    echo " 1. Nerd Font Symbols"
    echo " 2. No Nerd Font"
    echo " 3. Bracketed Segments"
    echo " 4. Plain Text Symbols"
    echo " 5. No Runtime Versions"
    echo " 6. No Empty Icons"
    echo " 7. Pure Preset"
    echo " 8. Pastel Powerline"
    echo " 9. Tokyo Night"
    echo " 10. Gruvbox Rainbow"
    echo " 11. Custom Starship Configuration - 1"
    echo " 12. Custom Starship Configuration - 2"
    echo -e " 13. None, Exit\n"

    sleep 1
    read -p "Enter the number corresponding to your choice: " choice

    case $choice in
        1) apply_starship_preset "nerd-font-symbols" ;;
        2) apply_starship_preset "no-nerd-font" ;;
        3) apply_starship_preset "bracketed-segments" ;;
        4) apply_starship_preset "plain-text-symbols" ;;
        5) apply_starship_preset "no-runtime-versions" ;;
        6) apply_starship_preset "no-empty-icons" ;;
        7) apply_starship_preset "pure-preset" ;;
        8) apply_starship_preset "pastel-powerline" ;;
        9) apply_starship_preset "tokyo-night" ;;
        10) apply_starship_preset "gruvbox-rainbow" ;;
        11) custom_starship_configuration "1";;
        12) custom_starship_configuration "2";;
        13) echo -e "\nExiting..."; log_and_pause; exit 1 ;;
        *) echo -e "\nInvalid choice. Exiting..."; log_and_pause; exit 1 ;;
    esac
}

custom_starship_configuration(){
    local custom=$1
    echo -e "\n\n\nApplying Custom Starship - $custom preset..."
    log_and_pause

    mkdir -p ~/.config && touch ~/.config/starship.toml
    wget -O ~/.config/starship.toml https://raw.githubusercontent.com/Raqeeb27/MyResourceHub/main/Starship_Prompt/custom_starship_config-$custom.toml

    echo -e "Custom Starship - $custom preset applied successfully.\n"
}

## --------------------------------------------------------------------------
# Function to apply selected Starship preset
apply_starship_preset() {
    local preset=$1
    echo -e "\n\n\nApplying Starship $preset preset..."
    log_and_pause

    mkdir -p ~/.config && touch ~/.config/starship.toml
    starship preset "$preset" -o ~/.config/starship.toml

    echo -e "Starship $preset preset applied successfully.\n"
}

## --------------------------------------------------------------------------
# Function to setup starship
setup_starship_config() {
    echo "Setting up starship configuration file..."
    log_and_pause

    if [ -f ~/.config/starship.toml ]; then
        echo "Starship is already configured."
        read -p "Do you want to configure a different preset? (Y/N): " choice

        # Convert the user input to lowercase for case-insensitive comparison
        case "${choice,,}" in
            y|yes|"")  # Accept 'y', 'yes', 'Y', 'YES', 'Yes', or Enter key
                sleep 1 ; select_starship_preset ;;
            *)
                echo -e "\nConfiguration file is unchanged." ;;
        esac
    else
        select_starship_preset
    fi

    log_and_pause
}

## --------------------------------------------------------------------------
# Function to confirm changes to ~/.bashrc file
confirm_bashrc(){
    touch ~/.bashrc
    if [ -f ~/.bashrc ]; then
        # Check if the ~/.bashrc file contains the line 'eval "$(starship init bash)"'
        if grep -q 'eval "$(starship init bash)"' ~/.bashrc; then
            echo -e "Starship is already configured in ~/.bashrc\n"
            return
        fi

        read -p "Do you want to configure the ~/.bashrc file? (y/n, default: yes): " bash_response

        # Convert the user input to lowercase for case-insensitive comparison
        case "${bash_response,,}" in
            y|yes|"") configure_bashrc ;;  # Accept 'y', 'yes', 'Y', 'YES', 'Yes', or Enter key
            *) echo -e "\nSkipped ~/.bashrc configuration."; log_and_pause ;;    # Any other input is considered negative
        esac
    fi
}

## --------------------------------------------------------------------------
# Function to configure Starship in ~/.bashrc
configure_bashrc() {
    echo "Configuring the ~/.bashrc file..."
    log_and_pause

    sed -i '/export PROMPT_COMMAND="echo"/d' ~/.bashrc
    sed -i '/eval "$(starship init bash)"/d' ~/.bashrc
    echo -e '\nexport PROMPT_COMMAND="echo"\neval "$(starship init bash)"' >> ~/.bashrc

    echo "Done!"
    font_cache=1
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to confirm changes to config.fish file
confirm_fish(){
    if [ -f ~/.config/fish/config.fish ]; then
        # Check if the ~/.config/fish/config.fish file contains the line 'starship init fish | source'
        if grep -q 'starship init fish | source' ~/.config/fish/config.fish; then
            echo -e "Starship is already configured in ~/.config/fish/config.fish\n"
            return
        fi

        read -p "Do you want to configure the ~/.config/fish/config.fish file? (y/n, default: yes): " fish_response

        # Convert the user input to lowercase for case-insensitive comparison
        case "${fish_response,,}" in
            y|yes|"") configure_fish ;;  # Accept 'y', 'yes', 'Y', 'YES', 'Yes', or Enter key
            *) echo -e "\nSkipped config.fish configuration."; log_and_pause ;;    # Any other input is considered negative
        esac
    fi
}

## --------------------------------------------------------------------------
# Function to configure Starship in config.fish file
configure_fish(){
    echo -e "\nConfiguring the ~/.config/fish/config.fish file..."
    log_and_pause

    sed -i '/starship init fish | source/d' ~/.config/fish/config.fish
    echo -e "\nstarship init fish | source" >> ~/.config/fish/config.fish

    echo "Done!"
    font_cache=1
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to confirm changes to ~/.zshrc file
confirm_zshrc(){
    if [ -f ~/.zshrc ]; then
        # Check if the ~/.zshrc file contains the line 'eval "$(starship init zsh)"'
        if grep -q 'eval "$(starship init zsh)"' ~/.zshrc; then
            echo -e "Starship is already configured in ~/.zshrc\n"
            return
        fi

        read -p "Do you want to configure the ~/.zshrc file? (y/n, default: yes): " zsh_response

        # Convert the user input to lowercase for case-insensitive comparison
        case "${zsh_response,,}" in
            y|yes|"") configure_zshrc ;;  # Accept 'y', 'yes', 'Y', 'YES', 'Yes', or Enter key
            *) echo -e "\nSkipped .zshrc configuration."; log_and_pause ;;    # Any other input is considered negative
        esac
    fi
}

## --------------------------------------------------------------------------
# Function to configure Starship in ~/.zshrc file
configure_zshrc() {
    echo -e "\nConfiguring the  ~/.zshrc file..."
    log_and_pause

    sed -i '/eval "$(starship init zsh)"/d' ~/.zshrc
    echo -e "\neval \"$(starship init zsh)\"" >> ~/.zshrc

    echo "Done!"
    font_cache=1
    log_and_pause

}

## --------------------------------------------------------------------------
# Function to check Caskaydia Cove Nerd font if installed
check_caskaydia_font() {
    echo -e "\nChecking whether Caskaydia Cove Nerd font is installed..."
    log_and_pause

    mkdir -p ~/.local/share/fonts/

    if ls ~/.local/share/fonts/ | grep Caskaydia > /dev/null; then
        echo -e "Caskaydia Cove Nerd font is already installed...\n"
    else
        # Install Nerd Font
        download_nerd_font
        unzip_nerd_font
        update_fonts_dir
    fi

    log_and_pause
}

## --------------------------------------------------------------------------
# Function to download Nerd Font for Starship preset
download_nerd_font() {
    echo "Downloading CascadiaCode Nerd Font for Preset..."
    log_and_pause

    wget -O ~/CascadiaCode.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to download Nerd Font for Starship preset
unzip_nerd_font() {
    echo "Unzipping CascadiaCode.zip..."
    log_and_pause

    mkdir ~/CascadiaCode
    unzip ~/CascadiaCode.zip -d ~/CascadiaCode
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to download Nerd Font for Starship preset
update_fonts_dir() {
    echo -e "\nUpdating ~/.local/share/fonts/ directory..."
    log_and_pause

    mv ~/CascadiaCode/*.ttf ~/.local/share/fonts/

    echo "Done!"

    rm -r ~/CascadiaCode.zip
    rm -rf ~/CascadiaCode
}

## --------------------------------------------------------------------------
# Function to download Nerd Font for Starship preset
update_font_cache() {
    if [ "$font_cache" = "1" ]; then
        # Update the font cache
        echo "Updating font cache..."
        log_and_pause

        fc-cache -f -v
        log_and_pause
        sleep 1

        echo -e "\nInstallation Completed."
        log_and_pause
    fi
}

## --------------------------------------------------------------------------
# Function to set the font in the terminal
# set_terminal_font() {
    # echo "Setting the font in the terminal..."
    # Instructions for setting the font in the terminal
    # (This step may vary depending on the terminal emulator)
# }


### ===========================================================================
## Main function to execute all the steps
#

main() {
    set -e  # Exit script if any command returns a non-zero status

    clear

    # Assigning font_cache variable
    font_cache=0

    echo -e "\n------- Automated Starship Installation Script -------"
    log_and_pause

    determine_distro
    install_dependencies
    install_starship
    setup_starship_config
    confirm_bashrc
    confirm_fish
    confirm_zshrc
    check_caskaydia_font
    update_font_cache

    echo -e "\nStarship Installation Successfull!!!\n\n\n----- SUCCESS -----\n\n"

    read -n 1 -s -r -p "Press any key to Exit..."
    sleep 0.5

    if [ "$distro" = "android" ]; then
        sl --help
    fi

    # Execute source command based on the shell
    # case "$(basename "$SHELL")" in
        # "bash")
            # source ~/.bashrc
            # ;;
        # "fish")
            # source ~/.config/fish/config.fish
            # ;;
        # "zsh")
            # source ~/.zshrc
            # ;;
        # *)
            # echo "Unknown shell. Unable to source configuration file."
            # ;;
    # esac

}

# Execute the main function
main
