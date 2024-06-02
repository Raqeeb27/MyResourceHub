#!/bin/bash

# Script: pig-setup.sh
# Description: Automated setup script for PIG setup
# Author: Mohammed Abdul Raqeeb
# Date: 10/02/2024

# ------- Automated PIG Setup Script -------

## ===========================================================================
### Functions


#Function to print blank lines and sleep
log_and_pause(){
    sleep 2
    echo -e "\n"
}

## --------------------------------------------------------------------------
# Function to check Hadoop installation
check_hadoop_availability(){
    if ! command -v hadoop &> /dev/null; then
        echo -e "Error: 'hadoop' command not found. Please make sure Hadoop is installed and in your PATH.\n"
        sleep 1

        echo -e "You can follow the Hadoop Installation guide at https://github.com/Raqeeb27/MyResourceHub/blob/main/hadoop_files/README.md for the Hadoop Installation\n"
        sleep 1
        
        echo -e "Exiting....\n"
        sleep 1
        exit 1
    fi
}

## --------------------------------------------------------------------------
# Function to determine Linux distribution
detect_linux_distribution() {
    # Check for distribution type
    if [ -f /etc/arch-release ]; then
        LINUX_DISTRO="Arch"
        START_SSH_COMMAND="sudo systemctl start sshd"
    elif [ -f /etc/debian_version ]; then
        LINUX_DISTRO="Ubuntu/Debian"
        START_SSH_COMMAND="sudo service ssh start"
    elif [ -f /etc/fedora-release ]; then
        LINUX_DISTRO="Fedora"
        START_SSH_COMMAND="sudo systemctl start sshd"
    else
        echo -e "\nUnsupported Linux distribution.\n\nExiting...\n"
        exit 1
    fi
}

## --------------------------------------------------------------------------
# Function to remove bsdgames package based on Linux distribution
remove_bsdgames_if_installed() {
    case "$LINUX_DISTRO" in
        "Ubuntu/Debian")
            # Check if bsdgames package is installed
            if dpkg -l | grep -q "^ii.*bsdgames"; then
                # Remove bsdgames package
                sudo apt-get remove --purge -y bsdgames && sudo apt autoremove -y && log_and_pause && echo -e "\n'bsdgames' package has been removed.\n" || echo "Failed to remove 'bsdgames' package."
            fi
            ;;
        "Arch")
            if pacman -Qs bsd-games >/dev/null 2>&1; then
                # Remove bsd-games package
                sudo pacman -Rs --noconfirm bsd-games && echo -e "\n'bsd-games' package has been removed.\n" || echo "Failed to remove 'bsd-games' package."                
            elif paru -Qs bsd-games >/dev/null 2>&1; then
                # Remove bsd-games package
                paru -Rns --noconfirm bsd-games && echo -e "\n'bsd-games' package has been removed.\n" || echo "Failed to remove 'bsd-games' package."
            fi
            ;;
        "Fedora")
            if dnf list installed bsd-games >/dev/null 2>&1; then
                # Remove bsd-games package
                sudo dnf remove -y bsd-games && echo -e "\n'bsd-games' package has been removed.\n" || echo "Failed to remove 'bsd-games' package."
            fi
            ;;
        *)
            echo "Unsupported distribution."
            ;;
    esac
}

## --------------------------------------------------------------------------
# Function to start SSH service
start_ssh_service() {
    echo "Starting SSH service..."

    $START_SSH_COMMAND || { echo -e "\nError: Failed to start SSH service. \nExiting...\n"; exit 1; }

    echo -e "\nSSH service started successfully."
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to restart Hadoop services
restart_hadoop_services() {
    # Stop Hadoop services
    echo -e "Stopping Hadoop services if any...\n"
    sleep 1

    stop-all.sh || { echo -e "\nError stopping Hadoop services!! \nExiting....\n"; sleep 1.5; exit 1; }

    echo -e "\n\n"
    sleep 1

    # Start Hadoop services
    echo -e "Starting Hadoop services...\n"
    sleep 1

    start-all.sh || { echo -e "\nError starting Hadoop services!! \nExiting....\n"; sleep 1.5; exit 1; }

    echo -e "\nHadoop services started successfully."

    sleep 1
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to prompt user for download confirmation
confirm_download() {
    read -p "The PIG tar file is around 220MB in size. Do you want to proceed with the download? (Y/N): " -r choice

    # Convert the user input to lowercase for case-insensitive comparison
    case "${choice,,}" in
        y|yes|"") return 0 ;;  # Accept 'y', 'yes', 'Y', 'YES', 'Yes', or Enter key
        *) return 1 ;;          # Any other input is considered negative
    esac
}

## --------------------------------------------------------------------------
# Function to download and extract PIG
download_and_extract_pig() {
    echo -e "\nDownloading and extracting Pig..."
    log_and_pause

    # Call confirm_download to check if the user wants to proceed
    confirm_download || { sleep 1; echo -e "\nAborting Pig installation..."; sleep 1; echo -e "Exiting...\n"; sleep 1; exit 1; }

    # Check if pig tar file already exists in Downloads
    if [ -f ~/hadoop-3.3.6/pig-0.17.0.tar.gz ]; then
        rm ~/hadoop-3.3.6/pig-0.17.0.tar.gz
    fi

    # Download pig tar file
    wget -O ~/hadoop-3.3.6/pig-0.17.0.tar.gz https://dlcdn.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz || { echo -e "\nAn error occured while downloading PIG-0.17.0\n\nExiting...\n"; sleep 1; exit 1; }

    # Check if pig-0.17.0 directory already exists
    if [ -d ~/hadoop-3.3.6/pig-0.17.0 ]; then
        rm -rf ~/hadoop-3.3.6/pig-0.17.0
    fi

    log_and_pause
    echo -e "Extracting pig-0.17.0.tar.gz .... (Estimated time: 10 Seconds)\n "
    sleep 1

    # Extract pig tar file
    tar -zxf ~/hadoop-3.3.6/pig-0.17.0.tar.gz -C ~/hadoop-3.3.6 || { echo -e "An error occured during the extraction process.\n\nExiting...\n"; sleep 1; exit 1; }
    log_and_pause

    echo -e "Successfully downloaded and extracted Pig!"
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to remove pig existing environment variables
remove_existing_pig_env_variables() {
    sed -i '/export PIG_HOME=\$HADOOP_HOME\/pig-0.17.0/d' ~/.bashrc
    sed -i '/export PATH=\$PATH:\$PIG_HOME\/bin/d' ~/.bashrc
    sed -i '/export PIG_CLASSPATH=\$PIG_HOME\/conf/d' ~/.bashrc
}

## --------------------------------------------------------------------------
# Function to configure Java environment variables
configure_pig_environment() {
    echo -e "\nConfiguring PIG environment variables in .bashrc..."

    echo -e "\n\nexport PIG_HOME=\$HADOOP_HOME/pig-0.17.0" >> ~/.bashrc
    echo "export PATH=\$PATH:\$PIG_HOME/bin" >> ~/.bashrc
    echo "export PIG_CLASSPATH=\$PIG_HOME/conf" >> ~/.bashrc

    # Check if the line is present in .bashrc
    if grep -qF "eval \"\$(starship init bash)\"" ~/.bashrc; then
        # Remove the line from .bashrc
        sed -i '/eval "\$(starship init bash)"/d' ~/.bashrc
        # Append the line to .bashrc after export statements
        echo -e "\neval \"\$(starship init bash)\"" >> ~/.bashrc
    fi

    log_and_pause
    echo "Configured!"
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to display success message
display_success_message() {
    echo -e "\n\n----- Automated PIG setup completed successfully -----\n"

    #echo "Please open your any browser and navigate to \"http://localhost:9870\""
    #log_and_pause
    #sleep 1.5

    #echo "Note:- When you restart your machine, run the following commands:"
    #echo -e "$START_SSH_COMMAND\nstart-all.sh"

    log_and_pause
    echo -e "\n-------- SUCCESS --------\n"
    sleep 1
}

### ===========================================================================
## Main function to execute all the steps
#

main() {
    set -e  # Exit script if any command returns a non-zero status

    clear

    sudo echo -e "\n ------- Automated PIG Setup Script -------"
    log_and_pause

    # Run functions in sequence
    check_hadoop_availability
    detect_linux_distribution
    remove_bsdgames_if_installed
    start_ssh_service
    restart_hadoop_services
    download_and_extract_pig
    remove_existing_pig_env_variables
    configure_pig_environment

    # Display success message
    display_success_message

    echo
    read -n 1 -s -r -p "Press any key to Exit..."
    sleep 0.5
}

# Execute the main function
main
