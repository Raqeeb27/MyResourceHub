#!/bin/bash

# Script: hadoop_wordcount.sh
# Description: Automated setup script for executing the Hadoop WordCount example.
# Author: Mohammed Abdul Raqeeb
# Date: 06/01/2024

# ------- Hadoop WordCount Script -------

## ===========================================================================
### Functions

# Function to start SSH service
start_ssh_service() {
    echo "Starting SSH service..."
    sudo service ssh start

    # Check if SSH service started successfully
    if [ $? -eq 0 ]; then
        echo
        echo "SSH service started successfully."
    else
        echo
        echo "Error: Failed to start SSH service. Exiting."
        exit 1
    fi
}

## --------------------------------------------------------------------------
# Function to restart Hadoop services
restart_hadoop_services() {
    # Stop Hadoop services
    echo "Stopping Hadoop services..."
    echo
    sleep 1
    stop-all.sh

    echo -e "\n\n"
    sleep 1

    # Start Hadoop services
    echo "Starting Hadoop services..."
    echo
    sleep 1
    start-all.sh

    echo
    echo "Hadoop services started successfully."
}

## --------------------------------------------------------------------------
# Function to create directory structure for WordCount
create_directory_structure() {
    echo "Creating directory structure..."
    
    mkdir -p hadoop_wordcount/example_classes
    mkdir -p hadoop_wordcount/input_data
    sleep 2
    echo

    # Setting variables for directory names
    wordcount_directory="hadoop_wordcount"
    example_classes_directory="example_classes"
    input_data_directory="input_data"

    echo "'$wordcount_directory' directory with subdirectories '$example_classes_directory' & '$input_data_directory' created successfully."
}

## --------------------------------------------------------------------------
# Function to Create/Edit input.txt
edit_input_file(){
    
    echo "Opening input.txt file......"
    sleep 3
    echo "Please provide input data in the editor that opens..."
    
    echo
    sleep 4
    
    echo "# Erase this line and input your text. Then press ctrl+s to Save and ctrl+x to Exit" > input.txt
    nano input.txt

    input_file=~/hadoop_wordcount/input_data/input.txt
    
    # Check if the file is empty or contains only spaces/blank lines
    if [[ ! -s "$input_file" ]] || [[ ! "$(grep -v '^[[:space:]]*$' "$input_file")" ]]; then
    
        # File is empty or contains only spaces/blank lines, exit
        sleep 1
        echo "File was empty or contained only spaces/blank lines."
        
        log_and_pause
        echo "Exiting...."
        
        echo
        sleep 2
    	exit 0
    fi
    sleep 1
    echo "\"input.txt\" file saved successfully.."
}

## --------------------------------------------------------------------------
# Function to setup HADOOP_CLASSPATH Environment variable
set_hadoop_classpath(){
    echo "Setting up HADOOP_CLASSPATH...."
    echo
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
}

## --------------------------------------------------------------------------
# Function to setup WordCount Directory in HDFS
setup_hdfs_wordcount_dir(){
    echo "Creating WordCount directory structure in HDFS..."

    echo
    
    # Create WordCount directory if it doesn't exists
    hadoop fs -mkdir -p /WordCount/tmp
    
    # Remove all the contents of WordCount directory
    hadoop fs -rm -r /WordCount/*
    
    # Create 'Input' directory within 'WordCount' directory
    hadoop fs -mkdir -p /WordCount/Input
    
    echo
    echo "Successfully created \"WordCount\" and \"Input\" directories in HDFS."
    sleep 1
    
    # upload local 'input.txt' file to Input directory in HDFS
    hadoop fs -put -f ~/hadoop_wordcount/input_data/input.txt /WordCount/Input/
    echo
    echo "Uploaded input.txt file to Input directory in HDFS.."
    sleep 2
    
    echo
    echo
    echo "HDFS operations completed successfully."
}

## --------------------------------------------------------------------------
# Function to compile WordCount.java file
compile_wordcount_java(){
    echo "Compiling WordCount.java..."
    javac -classpath ${HADOOP_CLASSPATH} -d ~/hadoop_wordcount/example_classes ~/hadoop_wordcount/WordCount.java
    sleep 2

    echo
    echo "Compilation successful."

    echo
    sleep 3

    # Navigate to example_classes directory
    cd example_classes/

    # List compiled classes
    echo "Compiled classes:"
    ls
}

## --------------------------------------------------------------------------
# Function to create JAR file
create_jar(){
    echo "Creating JAR file..."
    echo
    sleep 2
    jar -cvf FirstTutorial.jar -C ~/hadoop_wordcount/example_classes .

    echo
    sleep 1
    
    echo "JAR file created successfully."
    echo
    sleep 3

    # List JAR file
    echo "Created JAR file:"
    ls
}

## --------------------------------------------------------------------------
# Function to run WordCount job on hadoop
run_hadoop_wordcount_job(){
    echo "Running WordCount job on Hadoop..."
    echo
    sleep 1.5
    hadoop jar ~/hadoop_wordcount/FirstTutorial.jar WordCount /WordCount/Input/ /WordCount/Output/

    echo
    sleep 0.5
    echo "WordCount job completed successfully."
}

## --------------------------------------------------------------------------
# Funtion to display output
display_output(){
    echo "Displaying WordCount job output..."
    echo
    sleep 2
    hadoop fs -cat /WordCount/Output/*
}

## ----------------------------------------------------------------------------
#Function to print blank lines and sleep
log_and_pause(){
    sleep 2
    echo -e "\n\n"
}
### ===========================================================================
## Main
#

set -e  # Exit script if any command returns a non-zero status

clear

sudo echo -e "\n ------- Hadoop WordCount Script -------"

log_and_pause

# Start SSH service
start_ssh_service

log_and_pause

# Stop and Start hadoop services
restart_hadoop_services

sleep 1
log_and_pause

# Navigate to home directory
cd ~

# Create directory structure for WordCount
create_directory_structure

sleep 2.5
log_and_pause

# Navigate to input_data directory
cd hadoop_wordcount/input_data

# Create input.txt file with user input
edit_input_file

# Navigate back to the main directory
cd ..

log_and_pause

# Create WordCount.java
echo "Creating WordCount.java..."
sleep 2
cat << 'EOF' > WordCount.java
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

# Set HADOOP_CLASSPATH ENVIRONMENT variable
set_hadoop_classpath


sleep 1
log_and_pause

# Create WordCount directory structure in HDFS
setup_hdfs_wordcount_dir

log_and_pause

# Compile WordCount.java file
compile_wordcount_java

# Navigate back to the main directory
cd ..

sleep 2
log_and_pause

# Create JAR file
create_jar

sleep 2
log_and_pause

# Run WordCount job on Hadoop
run_hadoop_wordcount_job

log_and_pause

# Display output with the word counts
display_output

log_and_pause

# Display Success message
echo "----- SUCCESS -----"
echo