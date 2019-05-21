# FSL Cheat Sheet

## FSLUTILS - Image and Data Manipulation

Full FSLUTILS descriptions can be found here:  http://www.fmrib.ox.ac.uk/fsl/avwutils/index.html 

  * [[fslmaths]] 
  * [[fslcreatehd]] 
  * [[fsledithd]] 
  * [[fslsplit]] 
  * [[fslmerge]] 
  * [[fslhd]] 
  * [[fslinfo]] 
  * [[fslorient]] ----- used to check the orientation 
  * [[fslswapdim]] ---- used to change the orientation 

## SAMPLE COMMANDS - Image and Data Manipulation

```bash
# Resample image into reference image's space (so change matrix dimensions, (image size) and voxel size) 
flirt -ref <image in space you want to be in> -in <input image> -out <input image in new space> -nosearch -interp trilinear 
```

Registration with FNIRT - linear

We have functional data (func.nii) and structrural data (struct.nii) that we want in the MNI152_T1_2mm_brain.nii.gz space

```bash
# Register func.nii to struc.nii
flirt -ref struct.nii -in func.nii -omat func2struct.mat -dof 6 

# Output is func2struct.mat, tells how to transform the functional into space of anatomical 
# Now brain extract the anatomical and map struc.nii onto the standard template
# output will be struc2standard_aff.mat - how to map the structural to standard
bet struct.nii struct_bet -ref MNI152_T1_2mm_brain.nii -in struct_bet.nii -omat struct2standard_aff.mat

# Now use with fnirt...
fnirt --ref=MNI152_T1_2mm_brain.nii.gz --in=struct.nii --aff=struct2standard_aff.mat --cout=struct2standard_warp.nii

# Now get functional into standard space
applywarp --ref=MNI152_T1_2mm_brain.nii.gz --in=func.nii --out=func_standard.nii --coef=struct2standard_warp.nii --premat=func2struct.mat
```

Do a brain extraction on an anatomical, then register functional data to the standard space and the extracted anatomical    

```bash
#------------------------------------------------------------
# BET Brain Extraction
#------------------------------------------------------------
echo "Performing BET brain extraction on " $ANATFILE
bet $ANATPATH/$ANATFILE.nii.gz $ANATPATH/mprage_bet.nii.gz -S -f .225
#-------------------------------------------------------------
# FLIRT LINEAR REGISTRATION
#-------------------------------------------------------------
echo "Registering " $FUNCDATA " to mprage_bet"
flirt -ref $ANATPATH/mprage_bet.nii.gz -in $FUNCDATA.nii.gz -dof 7 -omat $FUNCDATA"_func2struct.mat";
flirt -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -in $ANATPATH/mprage_bet.nii.gz -omat $ANATPATH/affine_trans.mat;
fnirt --in=$ANATPATH/$ANATFILE.nii.gz --aff=$ANATPATH/affine_trans.mat --cout=$ANATPATH/nonlinear_trans --config=T1_2_MNI152_2mm
applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=$FUNCDATA.nii.gz --warp=$ANATPATH/nonlinear_trans --premat=$FUNCDATA"_func2struct.mat" --out=$FUNCDATA"_warped_func";
```


## BXH/XCEDE Tools
Tools descriptions by Syam Gadde can be found here: http://www.biac.duke.edu/home/gadde/xmlheader-docs/

### Navigation

  * cd -- moves back to highest directory
  * cd .. moves up to the parent directory
  * cd - moves to your previous directory
  * pwd prints the present working directory
  * mkdir makes a directory
  * cp (file to be copied) (destination directory)
  * rm (file name here) DELETES a file - be cautious with this one

### Cluster Communication

  * qinteract ----- launches qinteract from head node, for setting up experimental design
  * qstat ----- checks status of jobs you have submitted
  * qstatall ----- shows status of all jobs from all users
  * lnexp EXPERIMENT.01 ----- mounts an experiment in qinteract, to show up in "experiments" folder
  * qsub -v EXPERIMENT=NAME.01 script_name.sh ----- the basic format for submitting a script
