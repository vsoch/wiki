# DTI Cluster Processing

The exact same processing that is outlined in the [DTI Manual Processing](dti-manual-processing.md) has been set up to do with scripts!

## Scripts
The following scripts work together to complete single subject DTI processing for DNS data for either ONE or TWO runs of DTI data. 
We currently do not have scripts to process any DTI data other than DNS in SPM.

**spm_batch_DIT.py** (the python script)

[SPM BATCH DTI PYTHON](spm-batch-dti-python.md)
takes in user variables to start the process.  This is the only script that the user will have to touch to process data to enter folder names and subject numbers, and whether or not the subjects have one run or two. This script (for each subject) creates an instance of...

**spm_batch_DTI_TEMPLATE.sh** (bash script)

[SPM BATCH DTI TEMPLATE](spm-batch-dti-template.md)
as a template, meaning that it fills in all the relevant variables for each subject, and submits one script to process each subject.  Once submit, this script takes two Matlab script files, spm_DTI2_1.m and spm_DTI2_2.m, and uses them as a template in the same way.  After creating these Matlab scripts, this script launches Matlab with the -nodisplay option to run...

**spm_DTI2_1.m** 

[SPM DTI BATCH 1](scripts/spm_DTI2_1.m)
takes care of pre-processing of the anatomical data.  It first creates all the necessary folders (based on the user's selection), copies all functional raw data over, and then preprocesses the diffusion weighted images.   When this script finishes running, we shoot back to spm_batch_DTI2_TEMPLATE, which then creates a virtual display on the node it is running on the cluster, and launches Matlab to use that virtual display and run....

**spm_DTI2_2.m** 

[SPM DTI BATCH 2](scripts/spm_DTI2_2.m) 
Depending on whether we have one or two DTI runs, the script either processes a total of 16 images (for one run) or 32 images(for two runs).  This script creates a single directory for each subject.  Raw images are deleted at the end, and paths partially changed (Currently the SPM.xY.P paths in the SPM.mat are NOT changed because it isn't clear that we need them changed.  The script to do this is in the DNS SPM script directory and is called spm_change_paths_dti.m.  If we need the paths changed, this script can be modified.  The wFAmasked.img is the output image with the whole brain FA values that we can use for higher analysis.
