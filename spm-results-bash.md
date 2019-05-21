```bash
#!/bin/sh

# --------------SPM RESULTS TEMPLATE ----------------
# launches script to create results reports for faces,
# cards, and T1, and save to output folder
# ----------------------------------------------------

# Return Codes 
#     Successful completion: return 0
#     If you need to set another return code, set the RETURNCODE
#     variable in this section. To avoid conflict with system return 
#     codes, set a RETURNCODE higher than 100.
#     eg: RETURNCODE=110

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
#  Variables and Path Preparation
# ------------------------------------------------------------------------------

# Initialize input variables (fed in via python script)
SUBJ=SUB_SUBNUM_SUB          # This is the full subject folder name under Data
RUN=SUB_RUNNUM_SUB           # This is a run number, if applicable
FACESRUN=SUB_FACESRUN_SUB    # yes runs, no skips processing faces task
CARDSRUN=SUB_CARDSRUN_SUB    # yes runs, no skips processing cards task
TONERUN=SUB_TONERUN_SUB      # yes runs, no skips processing rest task
NOW=$(date +"%Y%b%d")

# Initialize other variables to pass on to matlab template script
SCRIPTDIR=$EXPERIMENT/Scripts/MATLAB/Vanessa             # This is the location of our MATLAB script templates
BIACROOT=/usr/local/packages/MATLAB/BIAC              # This is where matlab is installed on the custer
OUTDIR=$EXPERIMENT/Analysis/SPM/Processed/$SUBJ/

# ------------------------------------------------------------------------------
#  Step 1: Create subject specific template script
# ------------------------------------------------------------------------------

# Change into directory where template exists, save subject specific script
cd $SCRIPTDIR

# Loop through template script replacing keywords
for i in 'results_report.m'; do
sed -e 's@SUB_BIACROOT_SUB@'$BIACROOT'@g' \
 -e 's@SUB_SCRIPTDIR_SUB@'$SCRIPTDIR'@g' \
 -e 's@SUB_SUBJECT_SUB@'$SUBJ'@g' \
 -e 's@SUB_RUNFACES_SUB@'$FACESRUN'@g' \
 -e 's@SUB_RUNCARDS_SUB@'$CARDSRUN'@g' \
 -e 's@SUB_RUNREST_SUB@'$RESTRUN'@g' \
 -e 's@SUB_MOUNT_SUB@'$EXPERIMENT'@g' \
 -e 's@SUB_TONE_SUB@'$TONERUN'@g' <$i> $OUTDIR/results_report.m
done
 
# ------------------------------------------------------------------------------
#  Step 2: Preparing Virtual Display
# ------------------------------------------------------------------------------

#First we choose an int at random from 100-500, which will be the location in
#memory to allocate the display
RANDINT=$[( $RANDOM % ($[500 - 100] + 1)) + 100 ]
echo "the random integer for Xvfb is ${RANDINT}";

#Now we need to see if this number is already being used for Xvfb on the node.  We can
#tell because when it is active, it will have a "lock file"

while [ -e "/tmp/.X11-unix/X${RANDINT}" ]
do
      echo "lock file was already created for $RANDINT";
      echo "Trying a new number...";
      RANDINT=$[( $RANDOM % ($[500 - 100] + 1)) + 100 ]
      echo "the random integer for Xvfb is ${RANDINT}";
done

#Initialize Xvfb, put buffer output in TEMP directory
Xvfb :$RANDINT -fbdir $TMPDIR &
cd $OUTDIR; /usr/local/bin/matlab -display :$RANDINT < results_report.m

echo "Done running spm_results_report.m in matlab"

If the lock was created, delete it
if [ -e "/tmp/.X11-unix/X${RANDINT}" ]
      then
      echo "lock file was created";
      echo "cleaning up my lock file";
      rm /tmp/.X${RANDINT}-lock;
      rm /tmp/.X11-unix/X${RANDINT};
      echo "lock file was deleted";
fi

# ------------------------------------------------------------------------------
#  Step 3: Convert .ps to .pdf
# ------------------------------------------------------------------------------

PSFILE=$SUBJ"_"$NOW.ps

# Faces
cd $EXPERIMENT/Graphics/Data_Check/Faces/block
if [ -e "$PSFILE" ]; then
ps2pdf $PSFILE
rm $PSFILE
fi

# Cards
cd $EXPERIMENT/Graphics/Data_Check/cards
if [ -e "$PSFILE" ]; then
ps2pdf $PSFILE
rm $PSFILE
fi

# T1
cd $EXPERIMENT/Graphics/Data_Check/T1
if [ -e "$PSFILE" ]; then
ps2pdf $PSFILE
rm $PSFILE
fi

# Lastly, delete results script
cd $OUTDIR
rm results_report.m
 
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
