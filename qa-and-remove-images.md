# QA and Remove Images

## Overview
This script is intended to run QA on a bxh_header, removing the specified number of saturation images at the beginning of the scan.  You want to run this script by way of a python script to submit multiple subjects (not yet written - ask Vanessa! :) )

**This script**
  - creates a bxh_header from raw dicom images
  - runs QA based on a specified starting image to account for saturation at the beginning of the scan
  - puts the output QA in a folder called "QA" in the functional directory

```bash
#!/bin/sh

# ------qa_remove_images-----------

# This script uses a bxh file to run QA, which checks for data
# accuracy!  It also takes in a user imput to start QA at a particular image
# in order to remove beginning saturation that is commonly seen with exams.
# If you just have raw dicom images, you must first run dicom2bxh to create the BXH header
# This script puts the QA results in a folder called QA within that same folder as the dicom images and BXH header.

#-------SUBMISSION ON COMMAND LINE-----------------
 
#
# >  qsub -v EXPERIMENT=Dummy.01 qa_remove_images.sh bxh_header 4 2 Subject
#

# --- BEGIN GLOBAL DIRECTIVE -- 
#$ -S /bin/sh
#$ -o $HOME/$JOB_NAME.$JOB_ID.out
#$ -e $HOME/$JOB_NAME.$JOB_ID.out
#$ -m ea
# -- END GLOBAL DIRECTIVE -- 
 
# -- BEGIN PRE-USER --
#Name of experiment whose data you want to access 
EXPERIMENT=${EXPERIMENT:?"Experiment not provided"}
 
source /etc/biac_sge.sh
 
EXPERIMENT=`biacmount $EXPERIMENT`
EXPERIMENT=${EXPERIMENT:?"Returned NULL Experiment"}
 
if [ $EXPERIMENT = "ERROR" ]
then
	exit 32
else 
#Timestamp
echo "----JOB [$JOB_NAME.$JOB_ID] START [`date`] on HOST [$HOSTNAME]----" 
# -- END PRE-USER --
# **********************************************************
 
# -- BEGIN USER DIRECTIVE --
# Send notifications to the following address
#$ -M mickeymouse@email.com
 
# -- END USER DIRECTIVE --
 
# -- BEGIN USER SCRIPT --

# --- LONG VARIABLE DEFINITIONS ---
# INPUT is the name of the bxh file to run QA on! (without the .bxh
# SUBJECT is the name of the subject's top folder
# FOLDER is the folder in "Subject" that contains the bxh file data

INPUT=$1 
FOLDER=$2
STARTVOL=$3
SUBJECT=$4
OUTDIR=$EXPERIMENT/Data/$SUBJECT/$FOLDER/
 
# ------- LONG SCRIPT ------------------

cd $OUTDIR

#we navigate to EXPERIMENT.01/Data/RawData/$SUBJECT/4/
#to create the header and output is dropped in this same folder
   
bxhabsorb --fromtype dicom *.dcm $INPUT.bxh  
                    
#Now we perform QA
 
fmriqa_generate.pl --overwrite --timeselect $STARTVOL: $INPUT.bxh QA
 
# $OUTPRE.bxh is the input that we just created
# QA is the output directory (this will create a QA folder in ${EXPERIMENT}/Data/Func)
 
# -- END USER SCRIPT -- #
 
# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis}
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
```
