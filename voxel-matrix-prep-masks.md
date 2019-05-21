```bash
#!/bin/sh

#-------------Voxel_Matrix_Prep_Masks-----------------------------------

# This script is intended to prepare the Preprocessed SPM5 functional data
# in order to create a matrix with all of the voxel intensities in MATLAB with SPM5
# This script is different from Voxel_Matrix_Prep because it uses more than one mask,
# resulting in THREE niftis to create three matrices from.

# This script first makes the 3D swrf images into one 4D image
# It next uses the subject's standard space mask to clean up the 4D image
# and saves it as nifti to create a matrix from.  It then applies an SPM
# standard space mask to the nifti to create a second image, and lastly,
# it applies a ROI mask, (specified by the user)

# It then runs a brain extraction on the first 4D image to remove the eyeballs
# Next, these images are ready for processing in MATLAB

# ***********OUTPUT IS THE FOLLOWING************
#
# faces_4D_swrf_submasked_noeyes.nii  --- the image with only the subject mask applied
# faces_4D_swrf_stanmasked.nii --- the image with the subject and standard mask
# faces_4D_swrf_ROI.nii --- the image with the subject, standard, and ROI mask
#

# ---------WHEN DO I RUN THIS?------------
# You should use this script AFTER you have preprocessed the SPM5 data

# --------WHAT DO I NEED TO CHANGE?------------
# the email to direct the successful run of the script
# the BET value
# It is expected that the data is located under Data/SPMFaces/SPM2Processed/$SUBJECT/Faces
# The SPM standard mask is coded in to be Analysis/ROI/Masks/SPM_Mask.nii
# change these if necessary

#------------SUBMISSION ON COMMAND LINE---------------

# [abc1@head ~]$ qsub -v EXPERIMENT=Dummy.01 Voxel_Matrix_Prep.sh  SPMFaces   ROIname
#                                                                 data name   name of mask ROI 
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
#$ -M email@place.com
 
# -- END USER DIRECTIVE --
 
# -- BEGIN USER SCRIPT --
# User script goes here

DATANAME=$1
ROI=$2 #this is the name of the ROI mask to apply, located under Analysis/ROI/Masks

SUBJECTS="123 343 242"

SUBJDIR=$EXPERIMENT/Data/$DATANAME/SPM2Processed
ROIMASK=$EXPERIMENT/Analysis/ROI/Masks/Amygdala/$ROI.nii
SPM_MASK=$EXPERIMENT/Analysis/ROI/Masks/Standard/SPM_brain_mask_smaller.nii
  
for SUBJ in $SUBJECTS; do

cd $SUBJDIR/$SUBJ/Faces

SUBMASK=$EXPERIMENT/Data/$DATANAME/SPM5Processed/$SUBJ/mask.img
COMMANDLINE="faces_4D_swrf swrf*.img"

fslmerge -t $COMMANDLINE
# create the 4D image from the 195 3D images

fslmaths faces_4D_swrf.* -mas $SUBMASK faces_4D_swrf_submasked
# apply the subject mask to the 4D image to clean it up, create faces_4D_swrf_submasked

fslmaths faces_4D_swrf_submasked.* -mas $SPM_MASK faces_4D_swrf_stanmasked
# apply the standard space mask to the subject mask, create faces_4D_swrf_stanmasked

fslmaths faces_4D_swrf_stanmasked.* -mas $ROIMASK faces_4D_swrf_ROI
# apply the ROI mask, create faces_4D_swrf_ROI

BETVALUE=0.225
#INFILE=$SUBJDIR/faces_4D_swrf_masked.nii
#OUTPRE=$SUBJDIR/faces_4D_swrf_masked_noeyes
bet faces_4D_swrf_submasked.nii faces_4D_swrf_submasked_noeyes -f $BETVALUE
# brain extraction on the nifti to remove the eyeballs

fslchfiletype NIFTI faces_4D_swrf_stanmasked.nii.gz
fslchfiletype NIFTI faces_4D_swrf_ROI.nii.gz
fslchfiletype NIFTI faces_4D_swrf_submasked_noeyes.nii.gz
# uncompress the niftis so they work in matlab with SPM
  
done
 
# -- END USER SCRIPT -- #
 
# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${OUTDIR:-$EXPERIMENT/Data/SPMFaces}
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
```
