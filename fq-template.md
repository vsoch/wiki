# Fq Template

```bash
#!/bin/sh

#-------------FQ (featquery)---------------------------------------
 
# This script is intended to run a featquery with user created masks, 
# (functionally defined ROI masks, for example) These masks are located in
# the GroupFEAT/name.gfeat/stats/Cluster_masks directory with the format
# cluster$.nii  If you want to use an atlas, this is not the script to run!

# ---------WHEN DO I RUN THIS?------------
# In the pipeline, you should run featquery after finishing up with first and group level FEAT,
# AFTER you have created a series of cluster masks with cluster_mask.sh.  These cluster
# masks are used in featquery, and expected to be in the GroupFEAT/run01/run01.gfeat/stats/
# Cluster_masks folder

# --------WHAT DO I NEED TO CHANGE?------------
# the email to direct the successful run of the script
# scroll down to "THINGS YOU NEED TO CHANGE"

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
 

# input from the command line
DESIGN=SUB_DESIGN_SUB
FEAT_DESIGN=SUB_FEATDESIGN_SUB
GFEAT_DESIGN=SUB_GFEATDESIGN_SUB 
GFEAT_RUN=SUB_GFEATRUN_SUB #does not need .gfeat
FEAT_RUN=SUB_FEATRUN_SUB #does not need .feat
SUBJECT=SUB_SUBNUM_SUB
   

# paths to GFEAT and Single subject FEAT folders
GFEAT=$EXPERIMENT/Analysis/$DESIGN/GroupFEAT/$GFEAT_DESIGN/$GFEAT_RUN/$GFEAT_RUN.gfeat  # Set gfeat directory path
LEVEL1=$EXPERIMENT/Analysis/$DESIGN/First_level/$FEAT_DESIGN/$SUBJECT/$FEAT_RUN.feat  # Set FEAT first level data path   

cd $LEVEL1

# VANESSA NOTE TO SELF: In later versions of this script make it so I can enter ALL masks of
# interest for many different COPES, and make it do a check to see if the mask exists - if it
# doesn't, just keep going.

COPES="SUB_COPES_SUB" # Faces > SHAPES, etc.  #These are the copes specified in the GroupFEAT
MASKS="SUB_MASKS_SUB" # These are the numbers of the masks that you have created and want to use in featquery

                                            	
for COPE in $COPES; do
	
	ROIPATH=$GFEAT/cope$COPE.feat
		
		for MASK in $MASKS; do
	
			MASKPATH=$ROIPATH/Cluster_masks/cluster$MASK.nii
			
			# Setup variables to pass to featquery   
			INPATH=$LEVEL1 
			mkdir -p $EXPERIMENT/Analysis/ROI/$DESIGN/cope$COPE/Cluster_$MASK/$SUBJECT
			OUTPATH=$EXPERIMENT/Analysis/ROI/$DESIGN/cope$COPE/Cluster_$MASK/$SUBJECT
		
		   	STATS="6  stats/pe1 stats/cope1 stats/varcope1 stats/tstat1 stats/zstat1 thresh_zstat1" #Calculates all stats 
				  # Can calulate just cope1 stats by replacing above line with
				  # the following line:
				  #"1 stats/cope1"
				  # the number indicates the number of stats to run
				  
				  #All options for analysis are as follows: 
				  #stats/pe1 
				  #stats/cope1 
				  #stats/varcope1 
				  #stats/tstat1 
				  #stats/zstat1 
				  #thresh_zstat1"  
				            
			# FeatQuery arguments   
			# -a uses a selected atlas to generate label information                  
			# -b (popup in web browser)
			# -p (convert PE to % signal change)  DO WE WANT TO DO THIS?
			# -s creates time series plots   
			# -w (do not binarize mask), allow weighting
			# threshold stats images
			# -i affect size of resampled masks by changing
			# post-interpolation thresholding (default .5)
			
			ARGS="-p -s -w"
			
			# Run featquery
			
			echo "$SUBJECT"      
		  	featquery 1 $INPATH $STATS fq_$MASK $ARGS $MASKPATH
			
		done 
	  
	done
	
for COPE in $COPES; do
	
cd $LEVEL1
            	
for MASK in $MASKS; do

mkdir -p $EXPERIMENT/Analysis/ROI/$GFEAT_DESIGN/$GFEAT_RUN/cope$COPE/Cluster_$MASK/$SUBJECT		
mv fq_$MASK $EXPERIMENT/Analysis/ROI/$GFEAT_DESIGN/$GFEAT_RUN/cope$COPE/Cluster_$MASK/$SUBJECT  #moves the newly generated feat to the ROI directory

done

done                              
                                           

# -- END USER SCRIPT -- #
 
# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis/ROI/$GFEAT_DESIGN/$GFEAT_RUN/cope$COPE/Cluster_$MASK/$SUBJECT}
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
```
