# Create Cluster Masks

```
#!/bin/sh

#-------------create_cluster_masks.sh---------------------------------------
 
# This script takes the cluster_index.nii as input from a groupFEAT directory
# GroupFEAT/name.gfeat/cope1.feat/stats/cluster_index.nii
# and creates the specified masks based on different intensities in the cluster_index,
# These masks are intended to be used as ROI masks in the featquery.

# ---------WHEN DO I RUN THIS?------------
# In the pipeline, you should create the masks after running cluster_roi.sh
# to create the cluster_index, and after looking at the output from
# this index and deciding which intensities you want to create masks for.
# This script is the SECOND step in creating the MASK that featquery will use

# --------WHAT DO I NEED TO CHANGE?------------
# the email to direct the successful run of the script
# You also need to change the variable "COPES" to specify which copes you 
# want to create cluster_masks for!

#------------SUBMISSION ON COMMAND LINE---------------

# [abc1@head ~]$ qsub -v EXPERIMENT=Dummy.01 BET.sh  Faces            run01
#                                                    design          runname

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

DESIGN=$1
RUNNAME=$2

GFEATDIRECTORY=$EXPERIMENT/Analysis/FACES/GroupFEAT/$DESIGN/$RUNNAME/$RUNNAME.gfeat
MASKS="20 21 22 23 24 25" # YOU MUST WRITE THE MASKS YOU WANT TO MAKE HERE!
COPES="2" # YOU MUST SPECIFY THE COPE DIRECTORY TO CREATE MASKS IN.  
          # NOTE THAT IF YOU SELECT MORE THAN ONE, THEY MUST BOTH HAVE
	  # cluster_index.nii with the chosen intensities to make masks

for COPE in $COPES; do

COPEDIR=$GFEATDIRECTORY/cope$COPE.feat/stats
INFILE=$COPEDIR/cluster_index.nii.gz

cd $COPEDIR
mkdir -p $COPEDIR/Cluster_masks

for MASK in $MASKS; do

fslmaths $INFILE -thr $MASK -uthr $MASK.5 Cluster_masks/cluster$MASK.nii 

done

done

 
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
