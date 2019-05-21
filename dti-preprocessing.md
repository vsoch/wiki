# DTI Preprocessing

This script takes dti data converted to nifti with MRICro (which also produces the necessary bvec and bval files) from a stated DTI directory.  If you need help with the dicom to nifti conversion, see [Convert Dicom to NIFTII](convert-dicom-to-nifti.md)

  * first performs the eddy current correction (places output in the DTI DIRECTORY/DTI)
  * then creates a mask from the corrected data (places mask in DTI DIRECTORY/BET)
  * and finally performs DTIfit with the corrected data, the mask, the bvec, and the bval files to produce the following output:
   * DTI_V1 - 1st eigenvector
   * DTI_V2 - 2nd eigenvector
   * DTI_V3 - 3rd eigenvector
   * DTI_L1 - 1st eigenvalue
   * DTI_L2 - 2nd eigenvalue
   * DTI_L3 - 3rd eigenvalue
   * DTI_MD - mean diffusivity
   * DTI_FA - fractional anisotropy
   * DTI_S0 - raw T2 signal with no diffusion weighting


To run the script on the command line:

<code bash>
qsub -v EXPERIMENT=FIGS.01 DTI.sh 10 050112807043   
#Where "10" is the DTI directory within EXPERIMENT/Data/Subject, and "050112807043" is the subject number
</code>

=====The Script=====
<code bash>
#!/bin/sh

#-------------DTI---------------------------------------
 
# This script is intended to perform a Brain extraction, eddy current
# correction, and dtifit on a nifti of DTI data. The brain extraction, DTI_brain
# is put in a folder called "BET" within the DTI directory

# ---------WHEN DO I RUN THIS?------------
# In the pipeline, you should first run the data through QA to eliminate any bad apples, 
# then convert functional and anatomicals to nifti, and then BET with McFlirt before FEAT
#

# --------WHAT DO I NEED TO CHANGE?------------
# the email to direct the successful run of the script
# check if you want a different OUTDIR path (if not in folder 3, etc)
# the BET value

#------------SUBMISSION ON COMMAND LINE---------------

# [abc1@head ~]$ qsub -v EXPERIMENT=Dummy.01 DTI.sh   10        0405174398
#                                                    DTIfolder    Subject
 
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

DTI=$1   #this is the folder that contains the DTI data in the subject's directory
SUBJECT=$2

DTIDIR=$EXPERIMENT/Data/$SUBJECT/$DTI

cd $DTIDIR 
 
mkdir -p $DTIDIR/BET
mkdir -p $DTIDIR/DTI
  
#You must first drop the DTI folder for conversion using MRIcro - this will create the
#dti.nii, the bvec, and bval files required for DTIFit  
  
  
# Perform Eddy Current Correction
eddy_correct $DTIDIR/*.nii $DTIDIR/DTI/data_corrected 0
  
# BET on the dti brain to make the mask
bet $DTIDIR/DTI/data_corrected $DTIDIR/BET/nodif_brain -F -f .3
    
#Running dtifit with input data, brain mask, output directory, bvecs and bval files
dtifit -k $DTIDIR/DTI/data_corrected.nii -m $DTIDIR/BET/nodif_brain_mask.nii -o $DTIDIR/DTI -r $DTIDIR/.bvec -b $DTIDIR/.bval
 
 
# -- END USER SCRIPT -- #
 
# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${OUTDIR:-$EXPERIMENT/Data/$SUBJECT/$DTI/DTI}
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
</code>
