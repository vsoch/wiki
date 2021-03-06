# preprocess bash template

```bash
#!/bin/sh

# -------- PREPROCESSING TEMPLATE ---------

# This script is intended for converting raw dicom images into a 4D nifti file
# through use of the bxhtools and bxh header provided by BIAC
# This script is run with a python script, dicom2nifti.py
 
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
#$ -M SUB_USEREMAIL_SUB
 
# -- END USER DIRECTIVE --
 
# -- BEGIN USER SCRIPT --
# User script goes here

# --- LONG VARIABLE DEFINITIONS ---

ANAT_FOLDER=SUB_ANATFOLDER_SUB   # this is the anatomical series folder name
FUNC_FOLDER=SUB_FUNCFOLDER_SUB   # this is the functional series folder name
VOLUME=SUB_VOLUME_SUB            # this is the volume to remove in the format "196" (three places
SUBJECT=SUB_SUBNUM_SUB           # this is the subject ID
BETVALUE=SUB_BETVALUE_SUB        # this is the bet value
ANATFILE=SUB_ANATFILE_SUB        # this is the name of the nifti to be used for the anatomical

ANAT_OUTDIR=$EXPERIMENT/Data/Anat/$SUBJECT/$ANAT_FOLDER
FUNC_OUTDIR=$EXPERIMENT/Data/Func/$SUBJECT/$FUNC_FOLDER
 
# ------- LONG SCRIPT ------------------

# FIRST WE WILL PREPROCESS THE ANATOMICALS
# 1. Reorient from LPS to LAS
# 2. Convert from dicom to nifti
# 3. Perform brain extraction

cd $ANAT_OUTDIR
# here we navigate to the folder with the dicoms to run the command

bxhreorient --orientation=LAS $ANAT_FOLDER.bxh reoriented_LAS.bxh
# here we are changing the orientation from LPS to LAS, (TO Radiological) for use in FSL
  
bxh2analyze --nii -b -s reoriented_LAS.bxh Anat_LAS
# -nii indicates that we want an uncompressed nifti
# -b suppresses the output of a second bxh file 
# -s suppresses the writing of an spm .mat for each image file
# the output is called "Anat_LAS" to be used in the brain extraction

# BRAIN EXTRACTION ANATOMICALS
# First we make the BET directory in the anatomical directory
mkdir -p BET

# Now we print the command, in case we need to check it in the output
echo "bet Anat_LAS.nii BET/$ANATFILE -S -f $BETVALUE"
bet Anat_LAS.nii BET/$ANATFILE -S -f $BETVALUE

# NEXT WE WILL PREPROCESS THE FUNCTIONAL DATA
# 1. Create header file for images for SPM use
# 2. Re-orient from LPS to LAS
# 3. Create nifti, remove last image
# 4. Create final, correctly oriented nifti

cd $FUNC_OUTDIR
# here we navigate to the folder with the raw analyze files to run the commands

# Here we create the SPM headers for Pittsburgh processing
mkdir -p NiftiHeaders
# create an outdirectory to put the Nifti Headers

bxh2analyze --niftihdr -b -s $FUNC_FOLDER.bxh NiftiHeaders/NiftiHeaders_$FUNC_FOLDER"_"$SUBJECT"_"
# create the headers and put them in the output directory

#delete the last volume 
TO_DELETE=$(($VOLUME+1))
echo "the volume to delete is $TO_DELETE"

rm NiftiHeaders/NiftiHeaders_$FUNC_FOLDER"_"$SUBJECT"_0"$TO_DELETE.img
rm NiftiHeaders/NiftiHeaders_$FUNC_FOLDER"_"$SUBJECT"_0"$TO_DELETE.hdr
 
bxhreorient --orientation=LAS $FUNC_FOLDER.bxh reoriented_$FUNC_FOLDER.bxh
# here we reorient the data from LPS to LAS format for analysis within FSL

bxh2analyze --preferanalyzetypes --niigz reoriented_$FUNC_FOLDER.bxh reoriented_func
# here we create a 4D nifti from the reoriented data

fslsplit reoriented_func.nii.gz -t
# now we split the new 4D image in time

VOLUME_REMOVE="vol0"$VOLUME".nii.gz"
rm $VOLUME_REMOVE
# here we delete the last volume

fslmerge -t Func_LAS vol*.nii.gz
# now we recompile the nifti files to make the final, correctly oriented nifti file for analysis

rm vol*.nii.gz
# now we remove all of the extra volume niftis, since we are done with them.

# -- END USER SCRIPT -- #
 
# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${OUTDIR:-$EXPERIMENT/Data/Anat/$SUBJECT}
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
```
