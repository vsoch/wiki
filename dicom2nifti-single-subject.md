# Dicom2Nifti Single Subject

```
#!/bin/sh

# -------- DICOM 2 NIFTI ---------
# This script is intended for converting raw dicom images into a 4D nifti file
# through use of the BIAC XCEDE TOOLS

# -------- SUBMITTING JOB ON COMMAND LINE --------------
 
# >  qsub -v EXPERIMENT=FIGS.01 dicom2nifti.sh    Anat          series002      Faces     01252010_21546
#                                                 Anat or Func?  Folder name   Out-pre   Subject ID
 
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

# --- LONG VARIABLE DEFINITIONS ---

TYPE=$1     # this is either going to be "Anat" or "Func"
FOLDER=$2   # this is the series folder name
OUTPRE=$3   # this is the name you want for the resulting nifti
SUBJECT=$4  # this is the subject ID

OUTDIR=$EXPERIMENT/Data/$TYPE/$SUBJECT/$FOLDER/
 
# ------- LONG SCRIPT ------------------

cd $OUTDIR
# here we navigate to the folder with the dicoms to run the command

bxhreorient --orientation=LAS $FOLDER.bxh LAS.bxh
# here we are changing the orientation from LPS to LAS, (TO Radiological) for use in FSL

OUTPUT=$OUTPRE"_LAS"
# here we are appending _LAS to the end of the name to indicate the orientation of the new file
                    
bxh2analyze --nii -b LAS.bxh $OUTPUT
# -nii indicates that we want an uncompressed nifti
# -b suppresses the output of a second bxh file 
 
 
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
