# FA Move

Once DTI_fit has been run with Eddy Correction and we have a file called "DTI_FA.nii.gz" in the subjects DTI directory in the folder DTI, we need to move these particular files for all subjects relative to the experiment into the Analysis/DTI/FA folder to start running TBSS processing.  To do this, we use the following script, FA_move.sh.  You need to edit the script to include all of your subjects under the variable "Subjects" and you also need to make sure that the output directory exists (EXPERIMENT/Analysis/DESIGN_NAME/DTI/FA

To submit on command line:
```
qsub -v EXPERIMENT=FIGS.01  FA_move.sh     10
#                                          DTI FOLDER
```

## THE SCRIPT

```
#!/bin/sh

#-------------FA_move.sh---------------------------------------
 
# This script takes the FA niftis produced by DTI.py, located in the subject's specified DTI folder in
# Data/SUBJECT/DTI_FOLDER/DTI, renames it to include the subject ID, and moves it to the Analysis/Faces/DTI/FA 
# folder for further procesing

# ---------WHEN DO I RUN THIS?------------
# In the pipeline, you should run this script after you have completed running fq.sh and want to
# compile your results in a single file for analysis

# --------WHAT DO I NEED TO CHANGE?------------
# the email to direct the successful run of the script
# You need to change the variable "Subjects to include all the subjects with a particular dti folder 
# 

#------------SUBMISSION ON COMMAND LINE---------------

# [abc1@head ~]$ qsub -v EXPERIMENT=Dummy.01 fq_read.sh   FACES      10        
#                                                        Design    DTI Folder


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
# echo "----JOB [$JOB_NAME.$JOB_ID] START [`date`] on HOST [$HOSTNAME]----" 
# -- END PRE-USER --
# **********************************************************
 
# -- BEGIN USER DIRECTIVE --
# Send notifications to the following address
#$ -M name@email.com
 
# -- END USER DIRECTIVE --
 
# -- BEGIN USER SCRIPT --
    
# SET OUR VARIABLES

DTI_FOLDER=$1  #this is the folder under the subject directory that contains DTI data and a DTI folder

SUBJECTS="123 343 432 432"
          #insert subjects in quotes, with a space between each one
 
OUTPUT=$EXPERIMENT/Analysis/DTI/FA

for SUBJ in $SUBJECTS; do

# specify our nifti FA file and directory
DTI_DIR=$EXPERIMENT/Data/$SUBJ/$DTI_FOLDER/DTI
DTI_NIFTI=$DTI_DIR/DTI_FA.*

# Go to that directory
cd $DTI_DIR

# rename the FA nifti to include the subject ID
mv $DTI_NIFTI $SUBJ"_FA".nii.gz

# copy new FA nifti into the Analysis directory (only if successfully renamed)
cp $SUBJ"_FA".nii.gz $OUTPUT


done

echo "The following subjects were moved with this script:"
echo "$SUBJECTS"

# -- END USER SCRIPT -- #
 
# **********************************************************
# -- BEGIN POST-USER -- 
OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis/DTI/FA}
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
```
