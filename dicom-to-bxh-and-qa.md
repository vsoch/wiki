# Dicom2Bxh and QA

```
#!/bin/sh

# ------dicom2bxh_qa-----------

# The purpose of this script is twofold.  It first takes raw dicom images and creates 
# a bxh header, and then uses that bxh file to run QA.  QA checks for data
# accuracy!  If you want to separate these two steps, first run dicom2bxh on your raw dicom images
# and then the script qa!  dicom2bxh_qa places the resulting BXH in the same dicom folder and
# the QA results in a folder called QA within that same folder

#-------SUBMISSION ON COMMAND LINE-----------------
 
#
# >  qsub -v EXPERIMENT=Dummy.01 dicom2bxh_qa.sh bxh_header 4 Subject1 Subject2 Subject3
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
#$ -M user@email.com
 
# -- END USER DIRECTIVE --
 
# -- BEGIN USER SCRIPT --
# User script goes here

# --- LONG VARIABLE DEFINITIONS ---
# OUTPRE is the beginning name of the output!
# SUBJECT is the name of the subject's top folder
# FOLDER is the folder in "Subject" that contains the bxh file data

OUTPRE=$1 
FOLDER=$2
SUBJECT=$3
OUTDIR=$EXPERIMENT/Data/RawData/$SUBJECT/$FOLDER/
 
# ------- LONG SCRIPT ------------------

cd $OUTDIR

#we navigate to FIGS.01/Data/RawData/$SUBJECT/4/
#to create the header and output is dropped in this same folder
                    
bxhabsorb --fromtype dicom *.dcm $OUTPRE
#Now we perform QA
 
fmriqa_generate.pl $OUTPRE QA
 
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
