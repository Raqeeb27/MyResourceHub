#!/bin/bash

# Script: install_starship.sh
# Description: Install Starship prompt with Pastel Powerline preset, configure terminals, and set fonts.
# Author: Mohammed Abdul Raqeeb
# Date: 31/01/2024


# ------- Automated Starship Installation Script -------

## ===========================================================================
### Functions

# Function to install required dependencies
install_dependencies() {
    echo -e "\nInstalling dependencies..."
    log_and_pause

    sudo apt install curl wget unzip -y

    echo
    sudo curl -sS https://starship.rs/install.sh | sh -s -- -y || { echo "Error: Starship installation failed."; exit 1 ;}

    log_and_pause
}

## --------------------------------------------------------------------------
# Function to prompt user for preset selection
select_starship_preset() {
    echo -e "Select a Starship prompt preset:\n"
    
    echo "1. Nerd Font Symbols"
    echo "2. No Nerd Font"
    echo "3. Bracketed Segments"
    echo "4. Plain Text Symbols"
    echo "5. No Runtime Versions"
    echo "6. No Empty Icons"
    echo "7. Pure Preset"
    echo "8. Pastel Powerline"
    echo "9. Tokyo Night"
    echo "10. Gruvbox Rainbow"
    echo -e "11. None, Exit\n"

    sleep 1.5
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
        11) echo -e "\nExiting..."; log_and_pause; exit 1 ;;
        *) echo -e "\nInvalid choice. Exiting..."; log_and_pause; exit 1 ;;
    esac
}
## -------------------------------
# Function to apply selected Starship preset
apply_starship_preset() {
    local preset=$1
    echo -e "\n\nApplying Starship $preset preset..."
    log_and_pause

    mkdir -p ~/.config && touch ~/.config/starship.toml
    starship preset "$preset" -o ~/.config/starship.toml
    
    echo -e "Starship $preset preset applied successfully.\n"
}
## -------------------------------
# Function to create starship configuration file
setup_starship_config() {
    echo "Setting up starship configuration file..."
    log_and_pause

    if [ -f ~/.config/starship.toml ]; then
        echo "Starship is already configured."
        read -p "Do you want to configure a different preset? (Y/N): " choice

        case "$choice" in
            [Yy]|[Yy][Ee][Ss])
                log_and_pause ; select_starship_preset ;;
            *)
                echo -e "\nExiting without making changes."; log_and_pause; exit 1 ;;
        esac
    else
        select_starship_preset
    fi
    
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to add starship init bash to .bashrc
configure_bashrc() {
    echo "Configuring the ~.bashrc file..."
    log_and_pause

    if [ ! -f ~/.bashrc ]; then
        touch ~.bashrc
    fi

    sed -i '/PROMPT_COMMAND="echo"/d' ~/.bashrc
    sed -i '/eval "$(starship init bash)"/d' ~/.bashrc
    echo -e '\nPROMPT_COMMAND="echo"\neval "$(starship init bash)"' >> ~/.bashrc

    echo "Done!"
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to add starship init fish to config.fish
configure_fish() {
    if [ -f ~/.config/fish/config.fish ]; then

        echo -e "\nConfiguring the ~/.config/fish/config.fish file..."
        log_and_pause

        sed -i '/starship init fish | source/d' ~/.config/fish/config.fish
        echo -e "\nstarship init fish | source" >> ~/.config/fish/config.fish

        echo "Done!"
        log_and_pause
    fi
}

## --------------------------------------------------------------------------
# Function to add starship init zsh to .zshrc
configure_zshrc() {
    if [ -f ~/.zshrc ]; then

        echo -e "\nConfiguring the  ~/.zshrc file..."
        log_and_pause

        sed -i '/eval "$(starship init zsh)"/d' ~/.zshrc
        echo -e "\neval \"$(starship init zsh)\"" >> ~/.zshrc

        echo "Done!"
        log_and_pause
    fi
}

## --------------------------------------------------------------------------
# Function to install Nerd Font for Pastel Powerline preset
install_nerd_font() {
    echo -e "\nInstalling Nerd Font for preset..."
    log_and_pause

    # Download CascadiaCode Nerd Font
    echo "Downloading CascadiaCode Nerd Font..."
    log_and_pause

    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip -P ~
    log_and_pause

    # Unzip the downloaded font file
    echo "Unzipping CascadiaCode.zip..."
    log_and_pause

    mkdir ~/CascadiaCode
    unzip ~/CascadiaCode.zip -d ~/CascadiaCode
    log_and_pause

    # Create the fonts directory if it doesn't exist
    echo -e "\nUpdating ~/.local/share/fonts/ directory..."
    log_and_pause

    mkdir -p ~/.local/share/fonts/
    mv ~/CascadiaCode/*.ttf ~/.local/share/fonts/

    echo "Done!"
    log_and_pause

    # Remove the downloaded zip file
    # echo "Removing CascadiaCode.zip..."
    rm -r ~/CascadiaCode.zip
    rm -rf ~/CascadiaCode

    # Update the font cache
    echo "Updating font cache..."
    log_and_pause

    fc-cache -f -v
    log_and_pause
    sleep 1

    echo -e "\nInstallation Completed."
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to set the font in the terminal
# set_terminal_font() {
    # echo "Setting the font in the terminal..."
    # Instructions for setting the font in the terminal
    # (This step may vary depending on the terminal emulator)
# }

## --------------------------------------------------------------------------
#Function to print blank lines and sleep
log_and_pause(){
    sleep 2
    echo -e "\n"
}

### ===========================================================================
## Main function to execute all the steps
#

main() {
    set -e  # Exit script if any command returns a non-zero status

    clear

    sudo echo -e "\n------- Automated Starship Installation Script -------"
    log_and_pause

    install_dependencies
    setup_starship_config
    configure_bashrc
    configure_fish
    configure_zshrc
    install_nerd_font

    echo -e "\nStarship Installation Successfull!!!\n\n\n----- SUCCESS -----"
    log_and_pause
}

# Execute the main function
main
