#!/bin/bash

# Script: automated_hadoop_setup.sh
# Description: Fully automated setup script for installing Java, Hadoop, configuring environment, and setting up SSH.
# Author: Your Name
# Date: 29/01/2024

# ------- Automated Hadoop Setup Script -------

## ===========================================================================
### Functions

# Function to update system
update_system(){
    echo -e "\nUpdating System.....\n"
    sleep 1
    sudo apt update && sudo apt upgrade -y
    log_and_pause
    echo "System is now up to date!"
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to prompt user for download confirmation
confirm_download() {
    read -p "The Hadoop tar file is around 700MB in size. Do you want to proceed with the download? (Y/N): " choice
    case "$choice" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

# Function to download and extract Hadoop
download_and_extract_hadoop() {
    echo -e "\nDownloading and extracting Hadoop..."
    log_and_pause

    # Call confirm_download to check if the user wants to proceed
    confirm_download || { echo "Aborting Hadoop installation."; exit 1; }

    # Check if Hadoop tar file already exists in Downloads
    if [ -f ~/Downloads/hadoop-3.3.6.tar.gz ]; then
        # echo "Hadoop tar file already exists in Downloads. Removing existing file..."
        rm ~/Downloads/hadoop-3.3.6.tar.gz
    fi

    # Download Hadoop tar file
    wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz -P ~/Downloads

    # Check if Hadoop directory already exists
    if [ -d ~/hadoop-3.3.6 ]; then
        # echo "Hadoop directory already exists. Removing existing directory..."
        rm -rf ~/hadoop-3.3.6
    fi

    log_and_pause
    echo -e "Extracting hadoop-3.3.6.tar.gz ....\n "
    sleep 1
    # Extract Hadoop tar file
    tar -zxvf ~/Downloads/hadoop-3.3.6.tar.gz
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to install Java JDK 8
install_java() {
    echo -e "\nInstalling Java JDK 8...\n"
    sleep 1
    sudo apt-get install openjdk-8-jdk -y
    log_and_pause
    echo "Java JDK 8 successfully installed!"
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to remove existing Hadoop-related environment variables from .bashrc
remove_existing_hadoop_env_variables() {
    # echo "Removing existing Hadoop-related environment variables from .bashrc..."
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
    # echo "Existing Hadoop-related environment variables removed from .bashrc."
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
# Function to install SSH
install_ssh() {
    echo -e "\nInstalling SSH..."
    log_and_pause
    sudo apt-get install ssh -y
    log_and_pause
    echo -e "SSH is installed successfully"
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
    # Use sed to replace "UserName" with the current username
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
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to update hadoop-env.sh
update_hadoop_env() {
    echo -e "\nUpdating hadoop-env.sh..."
    sed -i '37s/.*/JAVA_HOME=\/usr\/lib\/jvm\/java-8-openjdk-amd64/' ~/hadoop-3.3.6/etc/hadoop/hadoop-env.sh
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to set up SSH keys
setup_ssh_keys() {
    echo -e "\nSetting up SSH Keys....."
    log_and_pause
    # Configure SSH to automatically accept new host keys
    # echo -e "Host localhost\n  StrictHostKeyChecking no" >> ~/.ssh/config
    # chmod 0600 ~/.ssh/config

    # Check if SSH key already exists
    if [ ! -f ~/.ssh/id_rsa ]; then
        # Generate SSH key without passphrase
        ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
    else
        echo "SSH key already exists! Skipping key generation."
    fi

    # Append public key to authorized_keys
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 0600 ~/.ssh/authorized_keys

    # Test SSH connection to localhost
    # echo "Testing SSH connection to localhost..."
    # ssh localhost
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to create Hadoop data directories
create_hadoop_data_directories() {
    echo -e "\nCreating Hadoop data directories..."
    mkdir -p ~/hadoop-3.3.6/hadoop_data/{namenode,datanode}
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to format the Hadoop namenode/filesystem
format_hadoop_namenode() {
    echo -e "\nFormatting the Hadoop namenode/filesystem..."
    log_and_pause
    ~/hadoop-3.3.6/bin/hdfs namenode -format
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to start Hadoop services
start_hadoop_services() {
    echo -e "\nStopping Hadoop services if any..."
    log_and_pause
    stop-all.sh
    log_and_pause
    echo "Starting Hadoop services..."
    log_and_pause
    start-all.sh
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to display success message
display_success_message() {
    echo -e "\n\n----- Automated Hadoop setup completed successfully -----\n"
    echo "Please open your any browser and navigate to http://localhost:9870."
    log_and_pause
    sleep 2
    echo "Note:- When you restart your machine, run the following commands:"
    echo -e "sudo service ssh start\nstart-all.sh\n"
}

## --------------------------------------------------------------------------
log_and_pause(){
    sleep 2
    echo -e "\n"
}

### ===========================================================================
##
# Main

set -e  # Exit script if any command returns a non-zero status

clear

sudo echo -e "\n ------- Automated Hadoop Setup Script -------\n"

# Run functions in sequence
update_system
download_and_extract_hadoop
install_java
remove_existing_hadoop_env_variables
configure_java_environment
install_ssh
configure_hadoop_environment
edit_hadoop_configs
update_hadoop_env
setup_ssh_keys
create_hadoop_data_directories
format_hadoop_namenode
start_hadoop_services

# Display success message
display_success_message