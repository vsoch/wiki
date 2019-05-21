# Voxel Value Matrix

## Cluster Scripts
  * These scripts are intended to run on hugin.
  * These scripts run matlab from the cluster and use matlab exclusively
  * [vox_matrix_TEMPLATE.sh](vox-matrix-template.sh.md) prepares the matlab script for each subject to make the matrix.  Input with all variables comes from [vox_matrix.py](vox-matrix.py.md), which submits the runs.
  * The scripts create an instance of [vox_extract_cluster.m](scripts/vox_extract_cluster.m), written by Patrick Fisher and modified by Vanessa Sochat for use on the BIAC cluster. 
  * Takes a set of images under EXPERIMENT/Data/SPM(version)/AllPreprocessedData/Subject and applies a mask under Analysis/ROI/Masks/(Mask_Type) and extracts values into a matrix with the subject ID, output goes to Analysis/Matrices/(Design)/(Subject)

## Semi Cluster / Old Scripts=====
  * These scripts do not use matlab on the cluster, preprocessing happens on the cluster and matlab must be run on a local machine. \\
  * PLEASE NOTE that these steps and scripts use old data and utilize both SPM and FSL to mask and process the data.  For most data it is recommended to use the pipeline above! [Voxel Value Matrix FSL/SPM Local Machine](voxel-value-matrix-fsl-spm-local-machine.md)
