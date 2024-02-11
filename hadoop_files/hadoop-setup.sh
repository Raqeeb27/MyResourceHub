#!/bin/bash

# Script: hadoop-setup.sh
# Description: Fully automated setup script for installing Java, Hadoop, configuring environment, and setting up SSH.
# Author: Mohammed Abdul Raqeeb
# Date: 30/01/2024

# ------- Automated Hadoop Setup Script -------

## ===========================================================================
### Functions

#Function to print blank lines and sleep
log_and_pause(){
    sleep 2
    echo -e "\n"
}

# Function to determine Linux distribution
detect_linux_distribution() {
    if command -v apt &> /dev/null; then
        LINUX_DISTRO="Ubuntu/Debian"
    elif command -v pacman &> /dev/null; then
        LINUX_DISTRO="Arch"
    elif command -v paru &> /dev/null; then
        LINUX_DISTRO="Arch"
    elif command -v dnf &> /dev/null; then
        LINUX_DISTRO="Fedora"
    else
        echo -e "\nUnsupported Linux distribution.\n\nExiting...\n"
        exit 1
    fi
}

# Function to install packages based on Linux distribution
update_and_install_packages() {
    echo -e "\nUpdating System and Installing Dependencies (openssh wget Java JDK-8)...."
    log_and_pause

    case "$LINUX_DISTRO" in
        "Ubuntu/Debian")
            sudo apt update && sudo apt upgrade -y;
            echo;
            sudo apt install -y openjdk-8-jdk wget ssh openssh-server
            ;;
        "Arch")
            sudo pacman -Syu --noconfirm || sudo paru -Syu --noconfirm;
            echo;
            sudo pacman -Sy --noconfirm jdk8-openjdk wget openssh || sudo paru -Sy --noconfirm jdk8-openjdk wget openssh;
            ;;
        "Fedora")
            sudo dnf upgrade -y;
            echo;
            sudo dnf install -y java-1.8.0-openjdk wget openssh-server
            ;;
    esac
    log_and_pause

    echo "System is now up to date and packages are installed successfully"
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to prompt user for download confirmation
confirm_download() {
    read -p "The Hadoop tar file is around 700MB in size. Do you want to proceed with the download? (Y/N): " -r choice

    # Convert the user input to lowercase for case-insensitive comparison
    case "${choice,,}" in
        y|yes|"") return 0 ;;  # Accept 'y', 'yes', 'Y', 'YES', 'Yes', or Enter key
        *) return 1 ;;          # Any other input is considered negative
    esac
}

# Function to download and extract Hadoop
download_and_extract_hadoop() {
    echo -e "\nDownloading and extracting Hadoop..."
    log_and_pause

    # Call confirm_download to check if the user wants to proceed
    confirm_download || { sleep 1; echo -e "\nAborting Hadoop installation..."; sleep 1; echo -e "Exiting...\n"; sleep 1; exit 1; }

    # Check if Hadoop tar file already exists in Downloads
    if [ -f ~/Downloads/hadoop-3.3.6.tar.gz ]; then
        rm ~/Downloads/hadoop-3.3.6.tar.gz
    fi

    # Download Hadoop tar file
    wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz -P ~/Downloads || { echo -e "\nAn error occured while downloading Hadoop-3.3.6\n\nExiting...\n"; sleep 1; exit 1; }

    # Check if Hadoop-3.3.6 directory already exists
    if [ -d ~/hadoop-3.3.6 ]; then
        rm -rf ~/hadoop-3.3.6
    fi

    log_and_pause
    echo -e "Extracting hadoop-3.3.6.tar.gz ....\n "
    sleep 1

    # Extract Hadoop tar file
    tar -zxvf ~/Downloads/hadoop-3.3.6.tar.gz -C ~ || { echo -e "An error occured during the extraction process.\n\nExiting...\n"; sleep 1; exit 1; }
    log_and_pause

    echo -e "Successfully downloaded and extracted Hadoop!"
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to remove existing Hadoop-related environment variables from .bashrc
remove_existing_hadoop_env_variables() {
    sed -i '/export JAVA_HOME=\/usr\/lib\/jvm\/java-8-openjdk-amd64/d' ~/.bashrc
    sed -i '/export PATH=\$PATH:\/usr\/lib\/jvm\/java-8-openjdk-amd64\/bin/d' ~/.bashrc
    sed -i '/export HADOOP_HOME=~/d' ~/.bashrc
    sed -i '/export PATH=\$PATH:\$HADOOP_HOME\/bin/d' ~/.bashrc
    sed -i '/export PATH=\$PATH:\$HADOOP_HOME\/sbin/d' ~/.bashrc
    sed -i '/export HADOOP_MAPRED_HOME=\$HADOOP_HOME/d' ~/.bashrc
    sed -i '/export YARN_HOME=\$HADOOP_HOME/d' ~/.bashrc
    sed -i '/export HADOOP_CONF_DIR=\$HADOOP_HOME\/etc\/hadoop/d' ~/.bashrc
    sed -i '/export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME\/lib\/native/d' ~/.bashrc
    sed -i '/export HADOOP_OPTS="-Djava.library.path=\$HADOOP_HOME\/lib\/native"/d' ~/.bashrc
    sed -i '/export HADOOP_STREAMING=\$HADOOP_HOME\/share\/hadoop\/tools\/lib\/hadoop-streaming-3.3.6.jar/d' ~/.bashrc
    sed -i '/export HADOOP_LOG_DIR=\$HADOOP_HOME\/logs/d' ~/.bashrc
    sed -i '/export PDSH_RCMD_TYPE=ssh/d' ~/.bashrc
    sed -i '/export PIG_HOME=\$HADOOP_HOME\/pig-0.17.0/d' ~/.bashrc
    sed -i '/export PATH=\$PATH:\$PIG_HOME\/bin/d' ~/.bashrc
    sed -i '/export PIG_CLASSPATH=\$PIG_HOME\/conf/d' ~/.bashrc
}

## --------------------------------------------------------------------------
# Function to configure Java environment variables
configure_java_environment() {
    echo -e "\nConfiguring Java environment variables in .bashrc..."

    echo -e "\n\nexport JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> ~/.bashrc
    echo "export PATH=\$PATH:/usr/lib/jvm/java-8-openjdk-amd64/bin" >> ~/.bashrc

    log_and_pause
    echo "Configured!"
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to configure Hadoop environment variables
configure_hadoop_environment() {
    echo -e "\nConfiguring Hadoop environment variables in .bashrc..."

    echo "export HADOOP_HOME=~/hadoop-3.3.6/" >> ~/.bashrc
    echo "export PATH=\$PATH:\$HADOOP_HOME/bin" >> ~/.bashrc
    echo "export PATH=\$PATH:\$HADOOP_HOME/sbin" >> ~/.bashrc
    echo "export HADOOP_MAPRED_HOME=\$HADOOP_HOME" >> ~/.bashrc
    echo "export YARN_HOME=\$HADOOP_HOME" >> ~/.bashrc
    echo "export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop" >> ~/.bashrc
    echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native" >> ~/.bashrc
    echo "export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_HOME/lib/native\"" >> ~/.bashrc
    echo "export HADOOP_STREAMING=\$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-3.3.6.jar" >> ~/.bashrc
    echo "export HADOOP_LOG_DIR=\$HADOOP_HOME/logs" >> ~/.bashrc
    echo "export PDSH_RCMD_TYPE=ssh" >> ~/.bashrc

    # Configure Hadoop Environment variables for current session
    export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
    export PATH=$PATH:/usr/lib/jvm/java-8-openjdk-amd64/bin
    export HADOOP_HOME=~/hadoop-3.3.6/
    export PATH=$PATH:$HADOOP_HOME/bin
    export PATH=$PATH:$HADOOP_HOME/sbin
    export HADOOP_MAPRED_HOME=$HADOOP_HOME
    export YARN_HOME=$HADOOP_HOME
    export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
    export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
    export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"
    export HADOOP_STREAMING=$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-3.3.6.jar
    export HADOOP_LOG_DIR=$HADOOP_HOME/logs
    export PDSH_RCMD_TYPE=ssh

    # Check if the line is present in .bashrc
    if grep -qF "eval \"\$(starship init bash)\"" ~/.bashrc; then
        # Remove the line from .bashrc
        sed -i '/eval "\$(starship init bash)"/d' ~/.bashrc
        # Append the line to .bashrc after export statements
        echo -e "\neval \"\$(starship init bash)\"" >> ~/.bashrc
    fi

    log_and_pause
    echo "Done!"
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to edit Hadoop configuration files
edit_hadoop_configs() {
    echo -e "\nEditing Hadoop configuration files..."

    # Edit core-site.xml
    cat << 'EOF' > ~/hadoop-3.3.6/etc/hadoop/core-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
  </property>
  <property>
    <name>hadoop.proxyuser.dataflair.groups</name>
    <value>*</value>
  </property>
  <property>
    <name>hadoop.proxyuser.dataflair.hosts</name>
    <value>*</value>
  </property>
  <property>
    <name>hadoop.proxyuser.server.hosts</name>
    <value>*</value>
  </property>
  <property>
    <name>hadoop.proxyuser.server.groups</name>
    <value>*</value>
  </property>
</configuration>
EOF

# ------------------------
    # Edit hdfs-site.xml
    cat << 'EOF' > ~/hadoop-3.3.6/etc/hadoop/hdfs-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
  <property>
    <name>dfs.name.dir</name>
    <value>/home/UserName/hadoop-3.3.6/hadoop_data/namenode</value>
  </property>
  <property>
    <name>dfs.data.dir</name>
    <value>/home/UserName/hadoop-3.3.6/hadoop_data/datanode</value>
  </property>
</configuration>
EOF

    # Get the current username using whoami
    USERNAME=$(whoami)
    # Using sed to replace "UserName" with the current username
    sed -i "s/UserName/$USERNAME/g" ~/hadoop-3.3.6/etc/hadoop/hdfs-site.xml

# ------------------------
    # Edit mapred-site.xml
    cat << 'EOF' > ~/hadoop-3.3.6/etc/hadoop/mapred-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
  <property>
    <name>mapreduce.application.classpath</name>
    <value>$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value>
  </property>
</configuration>
EOF

# ------------------------
    # Edit yarn-site.xml
    cat << 'EOF' > ~/hadoop-3.3.6/etc/hadoop/yarn-site.xml
<?xml version="1.0"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<configuration>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
  <property>
    <name>yarn.nodemanager.env-whitelist</name>
    <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
  </property>
</configuration>
EOF

    sleep 1
    echo -e "\nDone!"
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to update hadoop-env.sh
update_hadoop_env() {
    echo -e "\nUpdating hadoop-env.sh..."

    sed -i '37s/.*/JAVA_HOME=\/usr\/lib\/jvm\/java-8-openjdk-amd64/' ~/hadoop-3.3.6/etc/hadoop/hadoop-env.sh

    sleep 1
    echo -e "\nDone!"
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to set up SSH keys
setup_ssh_keys() {
    echo -e "\nSetting up SSH Keys....."
    log_and_pause

    # Check if SSH key already exists
    if [ ! -f ~/.ssh/id_rsa ]; then
        # Generate SSH key without passphrase
        ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
    else
        echo -e "SSH key already exists! Skipping key generation.\n"
    fi

    # Check if SSH key is in authorized_keys
    if [ -f ~/.ssh/authorized_keys ] && grep -qF "$(cat ~/.ssh/id_rsa.pub)" ~/.ssh/authorized_keys; then
        echo -e "SSH key already exists in authorized_keys. Skipping key addition.\n"
    else
        # Append public key to authorized_keys
        cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    fi

    chmod 0600 ~/.ssh/authorized_keys

    # Configure SSH to automatically accept new host keys
    echo -e "Host localhost\n    StrictHostKeyChecking no" >> ~/.ssh/config
    chmod 0600 ~/.ssh/config

    sleep 1
    echo -e "\nSSH Keys setup Completed!"
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to Start SSH service
start_ssh_service(){
    echo -e "\nStarting SSH service..."

    sudo service ssh start || { echo -e "\nError: Failed to start SSH service. \nExiting..."; log_and_pause; exit 1; }

    echo -e "\nSSH service started successfully!"
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to create Hadoop data directories
create_hadoop_data_directories() {
    echo -e "\nCreating Hadoop data directories..."

    mkdir -p ~/hadoop-3.3.6/hadoop_data/{namenode,datanode}

    sleep 1
    echo -e "\nDone!"
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to stop Hadoop services
stop_hadoop_services() {
    echo -e "\nStopping Hadoop services if any..."
    log_and_pause

    stop-all.sh || { echo -e "\nError in stopping Hadoop services!! \nExiting....\n"; sleep 1.5; exit 1; }
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to format the Hadoop namenode/filesystem
format_hadoop_namenode() {
    echo -e "\nFormatting the Hadoop namenode/filesystem..."
    log_and_pause

    ~/hadoop-3.3.6/bin/hdfs namenode -format

    sleep 1
    echo -e "\nNamenode formatted successfully."
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to start Hadoop services
start_hadoop_services() {
    echo -e "\nStarting Hadoop services..."
    log_and_pause

    start-all.sh || { echo -e "\nError in starting Hadoop services!! \nExiting....\n"; sleep 1.5; exit 1; }

    echo -e "\nHadoop services started successfully."
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to display success message
display_success_message() {
    echo -e "\n\n----- Automated Hadoop setup completed successfully -----\n"

    echo "Please open your any browser and navigate to \"http://localhost:9870\""
    log_and_pause
    sleep 1.5

    echo "Note:- When you restart your machine, run the following commands:"
    echo -e "sudo service ssh start\nstart-all.sh"

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

    sudo echo -e "\n ------- Automated Hadoop Setup Script -------"
    log_and_pause

    # Run functions in sequence
    detect_linux_distribution
    update_and_install_packages
    download_and_extract_hadoop
    remove_existing_hadoop_env_variables
    configure_java_environment
    configure_hadoop_environment
    edit_hadoop_configs
    update_hadoop_env
    setup_ssh_keys
    start_ssh_service
    create_hadoop_data_directories
    stop_hadoop_services
    format_hadoop_namenode
    start_hadoop_services

    # Display success message
    display_success_message

    echo
    read -n 1 -s -r -p "Press any key to Exit..."
    sleep 0.5
}

# Execute the main function
main
