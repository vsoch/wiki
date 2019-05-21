# DNS VBM Bash Script

This script is submit once per subject by the python.  It performs the main VBM Analysis.

## How does it work?
  - It takes in a subject ID, anatomical name, and whether GMMODULATION is set to 1 or 2.  When gmmodulation is set to 1, this mean that we are performing the SPM Default Modulation (affine and non-linear), and the script produces an output folder of this name under SUBJECT/anat/  When gmmodulation is set to 2, this means that we are performing the SPGR (non-linear only) and the output directory created is called SPGR.
  - The script first creates this directory under anat based on the type of modulation, and then pulls the first 6 letters of the anatomical image (specified by the user) to be used to name the output images.  Since our DNS dataset fluctuates between images starting with sDNS01 and sdns01, I decided to have this variable automatically converted from uppercase to lowercase so all output images would have the same name.
  - The script then navigates to DNS/Analysis/Scripts/SPM/VBM, and uses vbm.m as a template script, feeding in all the correct variables and paths.  This matlab script is either saved as vbm_1 (for SPM Default) or vbm_2 (for SPGR), and this subject specific copy is saved in the output directory.  You can [[http://www.vsoch.com/LONG/Vanessa/MATLAB/SPM/VBM/DNS/vbm8.m|see this script here]]
  - Next, we navigate to this folder and run the script.  It will take about 10 minutes / run per subject.  Depending on the type of gmmodulation, the script produces different files, so the matlab script is set up to first perform the VBM analysis, and then smooth the two resulting images, with slightly different names depending on the type of gmmodulation.
  - Lastly, we shoot back to the batch script when the matlab script finishes, and we copy our newly created files to the SPGR or SPM_Default_Modulation directory, and delete them from under anat.


```
#!/bin/sh

# --------------SPM BATCH VBM TEMPLATE ----------------
# 
# This script takes anatomical and functional data located under
# Data/fund and Data/anat and performs all preprocessing
# by creating and utilizing two matlab scripts, and running spm
# After this script is run, output should be visually checked
#
# ----------------------------------------------------

# There are 2 USER sections 
#  1. USER DIRECTIVE: If you want mail notifications when
#     your job is completed or fails you need to set the 
#     correct email address.
#		   
#  2. USER SCRIPT: Add the user script in this section.
#     Within this section you can access your experiment 
#     folder using $EXPERIMENT. All paths are relative to this variable
#     eg: $EXPERIMENT/Data $EXPERIMENT/Analysis	
#     By default all terminal output is routed to the " Analysis "
#     folder under the Experiment directory i.e. $EXPERIMENT/Analysis
#     To change this path, set the OUTDIR variable in this section
#     to another location under your experiment folder
#     eg: OUTDIR=$EXPERIMENT/Analysis/GridOut 	
#     By default on successful completion the job will return 0
#     If you need to set another return code, set the RETURNCODE
#     variable in this section. To avoid conflict with system return 
#     codes, set a RETURNCODE higher than 100.
#     eg: RETURNCODE=110
#     Arguments to the USER SCRIPT are accessible in the usual fashion
#     eg:  $1 $2 $3
# The remaining sections are setup related and don't require
# modifications for most scripts. They are critical for access
# to your data  	 

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


# ------------------------------------------------------------------------------
#
#  Variables and Path Preparation
#
# ------------------------------------------------------------------------------

# Initialize input variables (fed in via python script)
SUBJ=SUB_SUBNUM_SUB                # This is the full subject folder name under Data
RUN=SUB_RUNNUM_SUB                 # This is a run number, if applicable
ANATFOLDER=SUB_ANATFOL_SUB         # This is the name of the anatomical folder
GMMODULATION=SUB_MODULATIONGM_SUB  # This is set to 1, meaning we want the SPM default
ANATNAME=SUB_ANATNAME_SUB

# Set the folder name based on the GMMODULATION choice
if [ $GMMODULATION == 1 ]
then
FOLDER="SPM_Default_Modulation"
fi

if [ $GMMODULATION == 2 ]
then
FOLDER="SPGR"
fi


#Make the subject specific output directories
mkdir -p $EXPERIMENT/Analysis/SPM/Processed/$SUBJ/$ANATFOLDER/$FOLDER
SPGR_OUTDIR=$EXPERIMENT/Analysis/SPM/Processed/$SUBJ/$ANATFOLDER/$FOLDER
  
# Initialize other variables to pass on to matlab template script
OUTDIR=$EXPERIMENT/Analysis/SPM/Processed/$SUBJ       # This is the subject output directory top
SCRIPTDIR=$EXPERIMENT/Scripts/SPM/VBM                 # This is the location of our MATLAB script templates
BIACROOT=/usr/local/packages/MATLAB/BIAC              # This is where matlab is installed on the custer

# Pull the first four characters of the anat name to rename the file:
ANATPRE=$(echo $ANATNAME | cut -c1-6)

# Since we have differing formats, make sure to convert to lowercase.
ANATPRE=$(echo $ANATPRE | tr '[:upper:]' '[:lower:]')



# ------------------------------------------------------------------------------
#  Running VBM
# ------------------------------------------------------------------------------

# Change into directory where template exists, save subject specific script
cd $SCRIPTDIR

# Loop through template script replacing keywords
for i in 'vbm8.m'; do
sed -e 's@SUB_BIACROOT_SUB@'$BIACROOT'@g' 
 -e 's@SUB_SCRIPTDIR_SUB@'$SCRIPTDIR'@g' 
 -e 's@SUB_SUBJECT_SUB@'$SUBJ'@g' 
 -e 's@SUB_MOUNT_SUB@'$EXPERIMENT'@g' 
 -e 's@SUB_NAMEOFANAT_SUB@'$ANATNAME'@g' 
 -e 's@SUB_GMMODULATION_SUB@'$GMMODULATION'@g' 
 -e 's@SUB_ANATFOLDER_SUB@'$ANATFOLDER'@g' <$i> $OUTDIR/vbm8_${GMMODULATION}.m
done
 
# Change to output directory and run matlab on input script
cd $OUTDIR

/usr/local/bin/matlab -nodisplay < vbm8_${GMMODULATION}.m

echo "Done running spm_vbm.m in matlabn"


case $GMMODULATION in

1 )
# Copy data into mprage folder
cd $EXPERIMENT/Analysis/SPM/Processed/$SUBJ/$ANATFOLDER/
cp sm0wp2$ANATNAME.nii $SPGR_OUTDIR/sm0wp2_$ANATPRE.nii
cp wm$ANATNAME.nii $SPGR_OUTDIR/wm_$ANATPRE.nii
cp m0wp2$ANATNAME.nii $SPGR_OUTDIR/m0wp2_$ANATPRE.nii
cp mwp1$ANATNAME.nii $SPGR_OUTDIR/mwp1_$ANATPRE.nii
cp smwp1$ANATNAME.nii $SPGR_OUTDIR/smwp1_$ANATPRE.nii
cp $ANATNAME"_seg8".mat $SPGR_OUTDIR/$ANATPRE"_seg8".mat
cp p$ANATNAME"_seg8".txt $SPGR_OUTDIR/p_$ANATPRE"_seg8".txt

# Delete old files
rm sm0wp2$ANATNAME.nii
rm wm$ANATNAME.nii
rm m0wp2$ANATNAME.nii 
rm mwp1$ANATNAME.nii
rm smwp1$ANATNAME.nii
rm $ANATNAME"_seg8".mat
rm p$ANATNAME"_seg8".txt;;

2 )
cd $EXPERIMENT/Analysis/SPM/Processed/$SUBJ/$ANATFOLDER/
cp sm0wp2$ANATNAME.nii $SPGR_OUTDIR/sm0wp2_$ANATPRE.nii
cp sm0wp1$ANATNAME.nii $SPGR_OUTDIR/sm0wp1_$ANATPRE.nii
cp wm$ANATNAME.nii $SPGR_OUTDIR/wm_$ANATPRE.nii
cp m0wp2$ANATNAME.nii $SPGR_OUTDIR/m0wp2_$ANATPRE.nii
cp m0wp1$ANATNAME.nii $SPGR_OUTDIR/m0wp1_$ANATPRE.nii
cp $ANATNAME"_seg8".mat $SPGR_OUTDIR/$ANATPRE"_seg8".mat
cp p$ANATNAME"_seg8".txt $SPGR_OUTDIR/$ANATPRE"_seg8".txt

# Delete old files
rm sm0wp2$ANATNAME.nii
rm sm0wp1$ANATNAME.nii
rm m0wp2$ANATNAME.nii 
rm m0wp1$ANATNAME.nii
rm $ANATNAME"_seg8".mat
rm p$ANATNAME"_seg8".txt
rm wm$ANATNAME.nii;;

esac

# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis/SPM/Processed/$SUBJ}
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
```
