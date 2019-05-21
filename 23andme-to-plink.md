# 23andme to Pink

## Overview

This is bash code that is intended to take raw 23andme text files with individual participant data and prepare individual and group Plink .map and .ped files.  I will provide an overview, and little snippets from the bash script that can be modified to fit the runtime environment.  I will try to provide examples and suggestions that can be used as a skeleton to be modified to fit various needs.  The script takes in the following variables:
  * A list of IDs for males, females, unspecifieds (each member of these lists is an individual ID)
    * Depending on which list the person is added to, this sets a sex variable
  * A paternal ID (0)
  * A maternal ID (0) 
  * A family ID (0)
  * A phenotype (0)

Plink requires most of the above variables to be in a .tfam file to make the .ped and .map, and since we don't have the data, we set defaults to zero.

**The process works as follows:** 
  - Raw data is downloaded, unzipped, de-identified, and saved to a raw data folder, from 23andme.com
  - The output directory (where Analyzed Genetic Data is stored) should be set up with folders named Individual Group, csv, Merge_Lists, and Logs.
  - Individual output goes to OUTPUT/Individual/IDXXXX.ped/.map  
  - Group output goes to OUTPUT/Group/YYYYmmmdd_group.ped/.map
  - Text files used to create group merges go to OUTPUT/Group/Merge_Lists

**Instructions for Submission** 
  - Add lists of new subjects to variables below under either male or female
  - The other variables do not need to be changed!
  - Save and submit on command line:

```bash
qsub -v EXPERIMENT=NAME.01 plink_convert.sh
```

**The Cluster Script Works as Follows** 
  - Connects to the experiment from the cluster
  - Adds plink to the path
  - Cycles through the lists of males, females, and unknowns, and for each:
    - Sets the sex variable
    - Calls the function "make_plink" that:
      - Checks to see that the raw data file exists.  Logs error if does not, and skips ID.
      - Creates the .tfam file with the family, individual, paternal, material ID, sex, and phenotype, and saves in the Individual folder.
      - In the case that the file was opened in Windows, runs dos2unix on it!
      - Uses sed to skip over a huge comment section in the beginning of the text file, outputs a .nocomment file
      - Prints a .tped file, which is the same data formatted in the correct way for Plink
      - .tped file is saved in Individual folder
      - Prints a .csv file, saved in csv folder
      - Uses a plink command to create individual .ped/.map files, also saved in Individual folder
    - When all individuals are processed, it creates a text file of all the current .ped/.map files.
    - From this text file it creates a $DATE_group.map/.ped file, including all subjects in the Individuals folder, and puts it in the Group folder.  These are the files that will be grabbed by researchers to use with Plink!

### Code Snippets and Walkthrough

**Don't forget a good header!** 

```bash
#!/bin/bash

# ------plink_convert----------------------------------------------------
# This script reads in new, raw genetic text data files downloaded from
# from 23andme in the INPUT folder and first converts them all to 
# .ped/.map files, and then creates a new master .ped/.map file 
# (with all subjects) appended with the date to OUTPUT folders.
#
</code>

**Input Variables** 
<code bash>
#############################################################
# VARIABLES
# Specify input folder (with raw text files) and output
INPUT="L:/Path/to/input"
OUTPUT="L:/Path/to/output"
# Formatting for individual IDs under male and female 
# should be ( XXX0001 XXX0002 )  #(see spaces)
maleID=( XXX0060 XXX0113 XXX0242 XXX0259 XXX0042 XXX0188 XXX0252 )  
femID=( XXX0260 XXX0107 XXX0208 )   
uID=( )     # In the case of unidentified gender
fid=0       # Family ID
pid=0       # Paternal ID
mid=0	    # Maternal ID
pheno=0     # Phenotype
#############################################################
```

The input directory should obviously have your raw input text files, unzipped from 23andme and renamed to at least start with the subject ID, but not modified otherwise.  The script looks for the text file that starts with the subject ID and can have anything come after the name before the ".txt" so you could name it something like "XXX0001_genetics_date.txt."  It's important to not have any spaces in the name, otherwise the file found will only have the first part fed into the variable.  You could of course modify the script to account for this!

Since the script expects the folders "Group," "Logs," "Individual," "Merge_Lists," and "csv" under the OUTPUT folder variable, you you might want to add the functionality for the script to check for these each time and create them under the output folder if they do not exist. 

**Add Plink to the path** 

Plink is only run on command line, so there is no way to get around needing to do this step, unless your particular environment has it installed and automatically added to the path.  I'm not a linux pro, but I do know that each user has a "PATH" variable that holds all the places that are checked when a command is run.  It is the equivalent of the pathdef.m file in MATLAB.  If you type in command_name, it is going to search the PATH variable for a program with that name, and run it if it is found, and spit out an error if it is not.  We will likely need to add Plink to this PATH variable before using it, which can be accomplished with something like the following:

```bash
# Add plink to path
export PATH=/usr/local/packages/plink-1.07/:$PATH
```

**Set up the make_plink function** 
I knew that I wanted to have different lists of subjects, each list corresponding to a gender, and that I would want to be able to provide the gender as an input argument to a generalized function to convert the data for plink.  So I decided to make a function.  The basic setup of a function is as follows:

```bash
function name_of_function() {

first_input=$1
second_input=$2

# do things here!
}

# to call function
name_of_function "string" 2
# string is the first input, fed into the variable $first_input
# 1 is the second input, fed into the variable $second_input
```
Make sure that, if your script uses functions and is set up to run from top to bottom that you define them BEFORE using them!  Here are the important parts of the make_plink function:
```bash
#-------------------------------------------------------------------
# make_plink
# gets called or each sex to make the .ped and .map files
#-------------------------------------------------------------------
function make_plink() {
# Check to make sure input file exists
cd $INPUT
filename=$1*.txt
filename=`echo $filename`

if [ -f "$INPUT/$filename" ]; then
    # Go to individual output folder
    cd $OUTPUT/Individual/
    
    if [ ! -f "$OUTPUT/Individual/$1.ped" ]; then
	echo "Data " $filename" found. Creating plink files."
        
	# Give variables other names so that it doesnt get confused with awk
	# I actually don't think this is an issue, but I did this just in case!
        id=$1;famid=$2;patid=$3;matid=$4;gendr=$5;ptype=$6
	
    	# Create .tfam file
    	echo "$famid $id $patid $matid $gendr $ptype" > $OUTPUT/Individual/$id.tfam
   
    	# Make sure we don't have windows characters / carriage returns
    	dos2unix $INPUT/$filename
    
    	# Read only the data after the comment
    	sed '/^#/d' $INPUT/$filename > $id.nocomment
    
   	 # Print the tped file
    	awk '{ if (length($4)==1) print $2,$1,"0",$3,substr($4,1,1),substr($4,1,1); else
    	print $2,$1,"0",$3,substr($4,1,1),substr($4,2,1) }' $id.nocomment > $id.tped
    
    	# Print the csv file
    	awk '{ if (length($4)==1) print $2,",",$1,",","0",",",$3,",",substr($4,1,1),",",substr($4,1,1)","; else
    	print $2,",",$1,",","0",",",$3,",",substr($4,1,1),",",substr($4,2,1),","}' $id.nocomment > $OUTPUT/csv/$id"_"$7.csv
    
    	# Create Individual .ped/.map files - excluding tri-allelic SNPs in exclude_snp.txt
    	plink --tfile $id --out $id --recode --allele1234 --missing-genotype - --output-missing-genotype 0
    else
    	echo "Data " $id".ped already exists!  Skipping subject."
    fi
else
    echo "Cannot find " $id" text file.  Exiting!"
    # You can handle this error however you may like.  I chose to exit because one incorrect filename may mean other incorrect ones
    # and I would prefer to stop the script from running and check things over.  Another solution would be to let the script continue
    # running for the next subject, but log the name of the file that could not be found somewhere for troubleshooting.
    exit 32
fi    
}
```

It would be super cool (and I perhaps might do it if there is the need) to have this same functionality in bash, but instead of a script that you open up and feed variables into, a command that you can run with input arguments, and call different functions.  So instead of opening this script and adding the IDs and then submitting as is, you could do something like:

```bash
plink_convert --help 
#
# Spit out documentation here
#
plink_covert --make-plink filepath
```

For now I am content with a simple script to be edited and submit, however it is on my mind how I might convert this to a more robust and customizable tool.

**Running the Function** 

Now we just want to run the function for each subject in each gender list.  If a list is empty, then the loop simply doesn't run.  It makes sense to set the date variable now, since the date is the last input parameter into the function, which is done to append the date to the end of the csv file that is created.  I also chose to have the group files labeled by date.  This standard labels with a year, month, and day, and a time could be added to that if it might be run more than once a day.

```bash
# Format date variable
NOW=$(date +"%Y%b%d")

# Make sure that exclude_snp text file exists, exit if it doesn't
if [ ! -f "$EXPERIMENT/Analysis/Genetic/exclude_snp.txt" ]; then
	echo "exclude_snp.txt not found under " $EXPERIMENT"/Analysis/Genetic."
	echo " -- this is a single column text list of tri-allelic SNPs to not include"
	echo " -- please make this file and run again."
	exit 32
fi

# Cycle through the list of males and females

# MALES 
for idm in ${maleID[@]}
do 
    make_plink $idm $fid $pid $mid 1 $pheno $NOW
done
   
# FEMALES
for idf in ${femID[@]} 
do 
    make_plink $idf $fid $pid $mid 2 $pheno $NOW
done

# UNIDENTIFIED
for idu in ${uID[@]}
do 
    make_plink $idu $fid $pid $mid 0 $pheno $NOW
done
```

**Merged Group File** 

And of course once we have the .ped and .map files produced for each individual, we want to make a list at runtime of all the individual files that we have, and give this list to plink to make a "master" .ped/.map file.

```bash
#-------------------------------------------------------------------
# make text file with all individual .ped/.maps and make merged file
#-------------------------------------------------------------------
cd $OUTPUT/Individual/
for file in *.ped; do 
    name=${file%.*}
    echo $name.ped $name.map >> $OUTPUT/Merge_Lists/$NOW"_group.txt"
done

# Create new master .ped/.map file
plink --merge-list $OUTPUT/Merge_Lists/$NOW"_group.txt" --out $OUTPUT/Group/$NOW"_group" --recode
```

**The Plink Commands** 
```bash
# Create Individual .ped/.map files
plink --tfile $dnsid --exclude $EXPERIMENT/Analysis/Genetic/exclude_snp.txt --out $dnsid --recode --allele1234 --missing-genotype - --output-missing-genotype 0
    # input tfile is named by the ID, output files will also be named by the ID
    # Letters are converted to numbers (1234) for each allele, since SPSS will be used for analysis
    # The missing genotype in the 23andme data is coded as -
    # We code missing values as 0 for Plink
```

```bash
# Create new master .ped/.map file
plink --merge-list $EXPERIMENT/Analysis/Genetic/Merge_Lists/$NOW"_dns.txt" --out $EXPERIMENT/Analysis/Genetic/Group/$NOW"_dns" --recode

# Check for the MISSNP file, meaning that there was a strand error.
if [ -f "$EXPERIMENT/Analysis/Genetic/Group/"$NOW"_dns.missnp" ]; then

	# If there was a strand error (ERROR: Stopping due to mis-matching SNPs-- check +/- strand?) try re-running with --flip
	plink --merge-list $EXPERIMENT/Analysis/Genetic/Merge_Lists/$NOW"_dns.txt" --flip $EXPERIMENT/Analysis/Genetic/Group/$NOW"_dns.missnp" --out $EXPERIMENT/Analysis/Genetic/Group/$NOW"_dns_missnp" --recode
fi
```

**LOG FILES** 
It is also advisable to have all terminal output written to a text file, and saved in the "Logs" folder.  I'm not extremely experienced with plink, but I would guess that subject specific errors are likely to pop up, and it's extremely important to look over the entirety of each run, always, as opposed to processing blindly and assuming that the output is correct.  
