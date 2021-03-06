```bash
#!/bin/sh

#-------------TBSS_postreg.sh---------------------------------------

# This script must be run AFTER TBSS_reg.sh is complete, This script 
# applies the nonlinear transforms found in the previous stage to all subjects 
# to bring them into standard space.

# The script results in a standard-space version of each subject's FA image; 
# next these are all merged into a single 4D image file called all_FA, created 
# in a new subdirectory called stats. Next, the mean of all FA images is 
# created, called mean_FA, and this is then fed into the FA skeletonisation 
# program to create mean_FA_skeleton. 

# --------WHAT DO I NEED TO CHANGE?------------
# the email to direct the successful run of the script
# You need to change the variable "Subjects to include all the subjects with a particular dti folder
#

#------------SUBMISSION ON COMMAND LINE---------------

# [abc1@head ~]$ qsub -v EXPERIMENT=Dummy.01 TBSS_postreg.sh   
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
# echo "----JOB [$JOB_NAME.$JOB_ID] START [`date`] on HOST [$HOSTNAME]----"
# -- END PRE-USER --
# **********************************************************

# -- BEGIN USER DIRECTIVE --
# Send notifications to the following address
#$ -M user@email.com

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --

# Go to the FA folder with FAi as a subdirectory
cd $EXPERIMENT/Analysis/DTI/FAALL

# Perform the post registration
tbss_3_postreg -S

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
