#!/bin/bash

# Script: hadoop_wordcount.sh
# Description: Automated setup script for executing the Hadoop WordCount example.
# Author: Mohammed Abdul Raqeeb
# Date: 06/01/2024

# ------- Hadoop WordCount Script -------

## ===========================================================================
### Functions

# Function to check hadoop installation
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
        START_SSH_COMMAND="sudo systemctl start sshd"
    elif [ -f /etc/debian_version ]; then
        START_SSH_COMMAND="sudo service ssh start"
    elif [ -f /etc/fedora-release ]; then
        START_SSH_COMMAND="sudo systemctl start sshd"
    else
        echo -e "\nUnsupported Linux distribution.\n\nExiting...\n"
        exit 1
    fi
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
# Function to create directory structure for WordCount
create_directory_structure() {
    echo "Creating directory structure..."
    
    # Check if Hadoop_WordCount directory already exists
    if [ -d ~/hadoop_wordcount ]; then
        rm -rf ~/hadoop_wordcount
    fi

    mkdir -p ~/hadoop_wordcount/{wordcount_classes,input_data}
    sleep 2

    echo -e "\n'hadoop_wordcount' directory with subdirectories 'wordcount_classes' & 'input_data' created successfully."

    sleep 2.5
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to Create/Edit input.txt
edit_input_file(){
    
    echo "Opening input.txt file......"
    sleep 3
    echo -e "Please provide input data in the editor that opens...\n"

    sleep 4
    
    echo "# Erase this line and input your text. Then press ctrl+s to Save and ctrl+x to Exit" > ~/hadoop_wordcount/input_data/input.txt
    nano ~/hadoop_wordcount/input_data/input.txt

    input_file=~/hadoop_wordcount/input_data/input.txt
    
    # Check if the file is empty or contains only spaces/blank lines
    if [[ ! -s "$input_file" ]] || [[ ! "$(grep -v '^[[:space:]]*$' "$input_file")" ]]; then
    
        # File is empty or contains only spaces/blank lines, exit
        sleep 1
        echo "File was empty or contained only spaces/blank lines."
        
        log_and_pause
        echo -e "Exiting....\n"
        
        sleep 2
    	exit 0
    fi
    sleep 1
    echo "\"input.txt\" file saved successfully.."

    log_and_pause
}

## --------------------------------------------------------------------------
# Function to Create WordCount.java file
create_wordcount_java(){
    echo "Creating WordCount.java..."
    sleep 2

    cat << 'EOF' > ~/hadoop_wordcount/WordCount.java
import java.io.IOException;
import java.util.StringTokenizer;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class WordCount {
  public static class TokenizerMapper extends Mapper<Object, Text, Text, IntWritable>{
    private final static IntWritable one = new IntWritable(1);
    private Text word = new Text();

    public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
      StringTokenizer itr = new StringTokenizer(value.toString());
      while (itr.hasMoreTokens()) {
        word.set(itr.nextToken());
        context.write(word, one);
      }
    }
  }

  public static class IntSumReducer extends Reducer<Text,IntWritable,Text,IntWritable> {
    private IntWritable result = new IntWritable();

    public void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
      int sum = 0;
      for (IntWritable val : values) {
        sum += val.get();
      }
      result.set(sum);
      context.write(key, result);
    }
  }

  public static void main(String[] args) throws Exception {
    Configuration conf = new Configuration();
    Job job = Job.getInstance(conf, "word count");
    job.setJarByClass(WordCount.class);
    job.setMapperClass(TokenizerMapper.class);
    job.setCombinerClass(IntSumReducer.class);
    job.setReducerClass(IntSumReducer.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(IntWritable.class);
    FileInputFormat.addInputPath(job, new Path(args[0]));
    FileOutputFormat.setOutputPath(job, new Path(args[1]));
    System.exit(job.waitForCompletion(true) ? 0 : 1);
  }
}
EOF
    echo
    echo "\"WordCount.java\" file saved successfully.."

    sleep 1
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to setup HADOOP_CLASSPATH Environment variable
set_hadoop_classpath(){
    echo -e "Setting up HADOOP_CLASSPATH....\n"
    sleep 2.5

    # Check if HADOOP_CLASSPATH is already set
    if [ -z "$HADOOP_CLASSPATH" ]; then
    
        # If not set, then set it
        export HADOOP_CLASSPATH=$(hadoop classpath)
        echo "HADOOP_CLASSPATH set to: $HADOOP_CLASSPATH"

    else
        echo "HADOOP_CLASSPATH is already set."
        sleep 1.5
        echo "HADOOP_CLASSPATH : $HADOOP_CLASSPATH"
    fi

    sleep 1
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to setup WordCount Directory in HDFS
setup_hdfs_wordcount_dir(){
    echo -e "Creating WordCount directory structure in HDFS...\n"

    # Create WordCount directory if it doesn't exists
    hadoop fs -mkdir -p /WordCount/tmp
    
    # Remove all the contents of WordCount directory
    hadoop fs -rm -r /WordCount/*
    
    # Create 'Input' directory within 'WordCount' directory
    hadoop fs -mkdir -p /WordCount/Input
    
    echo
    echo -e "Successfully created \"WordCount\" and \"Input\" directories in HDFS.\n"
    sleep 1
    
    # upload local 'input.txt' file to Input directory in HDFS
    hadoop fs -put -f ~/hadoop_wordcount/input_data/input.txt /WordCount/Input/

    echo -e "\nUploaded input.txt file to Input directory in HDFS.."
    sleep 2
    
    echo -e "\n\nHDFS operations completed successfully."

    log_and_pause
}

## --------------------------------------------------------------------------
# Function to compile WordCount.java file
compile_wordcount_java(){
    echo "Compiling WordCount.java..."
    javac -classpath ${HADOOP_CLASSPATH} -d ~/hadoop_wordcount/wordcount_classes ~/hadoop_wordcount/WordCount.java
    sleep 2

    echo -e "\nCompilation successful.\n"

    sleep 3

    # List compiled classes
    echo "Compiled classes:"
    ls ~/hadoop_wordcount/wordcount_classes

    sleep 2
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to create JAR file
create_jar(){
    echo -e "Creating JAR file...\n"
    sleep 2

    cd ~/hadoop_wordcount
    jar -cvf Wordcount.jar -C ~/hadoop_wordcount/wordcount_classes .
    cd ~

    echo
    sleep 1
    
    echo -e "JAR file created successfully.\n"
    sleep 3

    # List JAR file
    echo "Created JAR file: Wordcount.jar"
    ls ~/hadoop_wordcount/

    sleep 2
    log_and_pause
}

## --------------------------------------------------------------------------
# Function to run WordCount job on hadoop
run_hadoop_wordcount_job(){
    echo -e "Running WordCount job on Hadoop...\n"
    sleep 1.5

    hadoop jar ~/hadoop_wordcount/Wordcount.jar WordCount /WordCount/Input/ /WordCount/Output/

    echo
    sleep 0.5
    echo "WordCount job completed successfully."

    log_and_pause
}

## --------------------------------------------------------------------------
# Funtion to display output
display_output(){
    echo -e "Displaying WordCount job output...\n"
    sleep 2

    hadoop fs -cat /WordCount/Output/*
    log_and_pause
}

## ----------------------------------------------------------------------------
#Function to print blank lines and sleep
log_and_pause(){
    sleep 2
    echo -e "\n\n"
}
### ===========================================================================
## Main function to execute all the steps
#

main() {
    set -e  # Exit script if any command returns a non-zero status

    clear

    sudo echo -e "\n ------- Hadoop WordCount Script -------"
    log_and_pause

    check_hadoop_availability
    start_ssh_service
    restart_hadoop_services
    create_directory_structure
    edit_input_file
    create_wordcount_java
    set_hadoop_classpath
    setup_hdfs_wordcount_dir
    compile_wordcount_java
    create_jar
    run_hadoop_wordcount_job

    # Display output
    display_output

    # Display Success message
    echo -e "----- SUCCESS -----\n"
}

# Execute the main function
main
