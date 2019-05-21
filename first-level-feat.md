# First Level Feat

```bash
#!/bin/sh

#----------first_level_FEAT.sh-----------
# This script runs level 1 feat, with the specification of the anatomical,
# functional, and subject directories in the command line.  The script assumes the
# brain extraction (BET) to be in a folder called BET within the anatomical
# directory.  If this is not the case, you must change ANAT= in the script!
# The path to the template must be specified after the design directory, so if the 
# path is FEAT/First_level/Design/4Block/design.fsf, you need to specify "4Block"
# The script assumes that the name of the design is design.fsf
 
#----------SUBMISSION ON COMMAND LINE----------------

#>  [user@head ~]$ qsub -v EXPERIMENT=Dummy.01 first_level_FEAT.sh    3        4      4Block         run01    34565434   
#                                                                  ANATDIR FUNCTDIR   design folder   run     subjFolder  
 
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
 
#-------------LONG VARIABLES------------------
#ANATDIR is the name of the anatomical directory under DATA
#FUNCDIR is the name of the functional directory under DATA
#DESIGN is the folder that the .fsf file is in under first_level/Design/DesignName and also the EVs 
#under FEAT/EVs/DesignName
#so if the path to our file is EXPERIMENT/Analysis/FEAT/First_level/4Block/design.fsf
#we would input 4Block/design.fsf
#SUBJ is the subject's folder name
#RUN is the name of the run
 
#Need to input EXPERIMENT, SUBJ and RUN NAME
#Example qsub -v EXPERIMENT=Dummy.01 first_level_FEAT.sh 99999 run01
ANATDIR=$1
FUNCDIR=$2
DESIGN=$3
RUN=$4
SUBJ=$5

#make directory to put the output FEAT
mkdir -p $EXPERIMENT/Analysis/FACES/First_level/$DESIGN/$SUBJ

#Set the directories
FUNCDATA=$EXPERIMENT/Data/$SUBJ/$FUNCDIR
#BEHAVDIR=$EXPERIMENT/Data/Behav/$SUBJ/FSL/$RUN
ANAT=$EXPERIMENT/Data/$SUBJ/$ANATDIR/BET/anat_brain.nii
TEMPLATEDIR=$EXPERIMENT/Analysis/FACES/First_level/Design/$DESIGN
EVDIR=$EXPERIMENT/Analysis/FACES/EVs/$DESIGN
OUTDIR=$EXPERIMENT/Analysis/FACES/First_level/$DESIGN/$SUBJ
 
#Set some variables
OUTPUT=$OUTDIR/$RUN
DATA=$FUNCDATA/*.nii
#ORIENT=$FUNCDIR/ORIENT.mat
 
#TARG=$BEHAVDIR/Targ.stf
#NEUT=$BEHAVDIR/NeutCorr.stf
#SCARY=$BEHAVDIR/ScaryCorr.stf
 
mkdir -p $OUTDIR
cd $TEMPLATEDIR
 
#Makes the fsf file using the template
for i in 'design.fsf'; do
sed -e 's@OUTPUT@'$OUTPUT'@g' 
-e 's@ANAT@'$ANAT'@g' 
-e 's@EVDIR@'$EVDIR'@g' 
-e 's@DATA@'$DATA'@g' <$i> ${OUTDIR}/FEAT_${RUN}.fsf
done
 
cd $OUTDIR
#Run feat analysis
feat ${OUTDIR}/FEAT_${RUN}.fsf
 
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
