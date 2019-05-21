```bash
#!/bin/sh

# -------- PREPROCESSING FEAT TEMPLATE ---------
# to be used with PREPROCESS_FEAT.py
 
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
DESIGN=SUB_DESIGN_SUB            # this is the design name / type (Block or Event)
ORDER=SUB_ORDER_SUB              # this is the design order, 1,2,3,4 for Faces, or 1 for Cards
RUN=SUB_RUNNAME_SUB              # this is the runname, usually run01
TASK=SUB_TASK_SUB                # this is the task name, either FACES or CARDS
ANATPRE=SUB_ANATPRE_SUB          # this determines if we want to preprocess anatomicals as well
FUNCPRE=SUB_FUNCPRE_SUB          # this determines if we want to preprocess the functionals
FEATRUN=SUB_FEATRUN_SUB          # this determines if we want to run FEAT

ANAT_OUTDIR=$EXPERIMENT/Data/Anat/$SUBJECT/$ANAT_FOLDER
FUNC_OUTDIR=$EXPERIMENT/Data/Func/$SUBJECT/$FUNC_FOLDER
 
# ------- LONG SCRIPT ------------------

# FIRST WE WILL PREPROCESS THE ANATOMICALS
# 1. Reorient from LPS to LAS
# 2. Convert from dicom to nifti
# 3. Perform brain extraction

if [ $ANATPRE == 'yes' ]; then
        
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

fi

# NEXT WE WILL PREPROCESS THE FUNCTIONAL DATA
# 1. Create header file for images for SPM use
# 2. Re-orient from LPS to LAS
# 3. Create nifti, remove last image
# 4. Create final, correctly oriented nifti

if [ $FUNCPRE == 'yes' ]; then

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

fi

#NOW WE WILL RUN THE FIRST LEVEL FEAT

if [ $FEATRUN == 'yes' ]; then

#make directory to put the output FEAT
mkdir -p $EXPERIMENT/Analysis/$TASK/First_level/$DESIGN/$SUBJECT

#Set the directories
ANAT=$ANAT_OUTDIR/BET/$ANATFILE.nii
EVDIR=$EXPERIMENT/Analysis/$TASK/First_level/Design/$DESIGN/$ORDER
OUTDIR=$EXPERIMENT/Analysis/$TASK/First_level/$DESIGN/$SUBJECT
 
#Set some variables
OUTPUT=$OUTDIR/$RUN
DATA=$FUNC_OUTDIR/Func_LAS.nii.gz

# make the output directory and go to the template directory
mkdir -p $OUTDIR
cd $EVDIR

#Makes the fsf file using the template
for i in 'design.fsf'; do
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@ANAT@'$ANAT'@g' \
-e 's@EVDIR@'$EVDIR'@g' \
-e 's@DATA@'$DATA'@g' <$i> ${OUTDIR}/FEAT_${RUN}.fsf
done
 
cd $OUTDIR
#Run feat analysis
feat ${OUTDIR}/FEAT_${RUN}.fsf

fi

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
