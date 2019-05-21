# SPM_TIMESERIES
It is probably incorrect to label this as a timeseries extraction tool, because it is currently configured to extract a list of activation values for each subject in a group analysis, as opposed to a series of mean activations for a single subject over time.  The name comes from the fact that the SPM VOI tool can be used to do either.  The broad goal of this script is to create a consistent standard for extracting group BOLD values that might e used with another application that deals with genetic, behavioral, and clinical data.

## What does it do?
This script can be used to automatically extract a list of BOLD activation values from a group map, and print those values with a list of subjects from the analysis to a user specified output folder.  This would be equivalent to loading a group SPM.mat into the results editor, selecting a contrast, threshold type, threshold, and mask, and then clicking "eigenvariate" to create a VOI (volume of interest) based on the same mask.  Running this manually, a VOI_name.mat would be created in the group analysis directory, and the list of extracted values spit out into the MATLAB window.  

### Whole Brain vs Masked Thresholding
The script is currently set up to extract based on a mask, meaning that we first threshold the SPM.mat with the mask, and THEN pull the mean across the mask.  If you want to threshold with a wholebrain analysis and then extract from the mean within a specified mask, please use [SPM Timeseries Wholebrain](scripts/dns_timeseries_wholebrain.m). 

### Single Subject vs. Group SPM.mat

It should be noted that the equivalent might be done for a single subject SPM.mat, except we would be extracting a timeseries (mean activation over time).  The script is currently set up to check that the selected SPM.mat is for a group, and NOT a single subject analysis.  It could be adapted to support single subject timeseries, if needed.

### How does it work?

Broadly, the script collects all user input, including an optional id lookup table that can match any sort of study ID with the exam ID (associated with the data). These inputs can come either from command line or, if the script is called with zero input arguments, selected via a GUI.  After all input is selected and checked for accuracy, the script hijacks the function wfu_spm_getSPM from Pickatlas to threshold and mask the input data, and then feeds this thresholded and masked SPM.mat output into the spm_jobman, with a job configured to use the VOI tool to extract based on a this thresholded SPM and a mask.  For empty regions it catches these as errors, and records the job ID to print to a error_log.txt file.  It then, for each successful VOI extraction, goes to the user specified output folder, and prints a .csv file with the list of subject id's from the lookup file, the exam ids embedded with the data, and the values extracted for the particular mask.

### How do I run it?
For detailed comments about functionality, please refer to the documentation in the script itself.  If anything is unclear, please don't hesitate to ask! [SPM Timeseries](scripts/dns_timeseries.m)

### Dependencies
You need MATLAB installed, with SPM8 and Pickatlas 3.0 installed on the computer and added to the path.  The script will check for your spm installation, and the file "wfu_spm_getSPM()" to check for Pickatlas.  Note that I did not test this for other versions of SPM or Pickatlas.

### Running from Command Line
You can run it either with zero, seven, or eight arguments, as follows:

```matlab
% Will prompt user for all input, allows one or more runs, and the selection of a common output folder
dns_timeseries

% Will do one extraction with no lookup table
dns_timeseries(spmmat,threshtype,thresh,extent,output,mask,contrast)

% Will do one extraction with a lookup table
dns_timeseries(spmmat,threshtype,thresh,extent,output,mask,contrast,lookup)
```

The input parameters are as follows:
  * (1) spmmat:      the full path location to the group SPM.mat (string)
  * (2) threshtype:  must be fwe or none (string)
  * (3) thresh:      the threshold % (string or number)
  * (4) extent:      the voxel extent (string or number)
  * (5) output:      the output folder (string)
  * (6) mask:        pull path to mask image (string)
  * (7) contrast:    the contrast number (string or number) (usually 1)
  * (8) lookup:      an excel (.xls, .xlsx, or .csv) lookup table, should have "dns_id" and "exam_id" columns.

### Batch Running
You could set up a simple script to run many iterations of dns_timeseries, perhaps for multiple masks/contrasts/tasks at a data freeze.  An example is provided below.

```matlab
% Setup global (nonchanging) variables for each run:
threshtype = 'FWE';
thresh = '.05';
extent = 0;
contrast = 1;
lookup = 'L:\Path\to\TIMESERIES\lookup.xls';
output = 'L:\Path\to\output\TIMESSERIES\masked\XXXs';

%% TASK1 EXTRACTIONS
spmmat = 'L:\Path\to\task1\group\map\SPM.mat';

% Contrast > One Mask1
mask = 'L:\Path\to\Mask1.nii';
dns_timeseries(spmmat,threshtype,thresh,extent,output,mask,contrast,lookup);

% Contrast > Two Mask2
contrast = 2;
mask = 'L:\Path\to\Mask2.img';
dns_timeseries(spmmat,threshtype,thresh,extent,output,mask,contrast,lookup);

%% TASK2 EXTRACTIONS
spmmat = 'L:\Path\to\task2\group\map\SPM.mat';

% Contrast > One Mask3
mask = 'L:\Path\to\Mask3.img';
dns_timeseries(spmmat,threshtype,thresh,extent,output,mask,1,lookup);

% etc...
```

### General Comments

  * **Rounding:** It should be noted that, performing a VOI in the GUI, the values that are spit out are either rounded or truncated in some way.  My script maintains the full seven decimal places.
  * **Modification:** Please see "MODIFY" in the script header for information about how to modify this script for a different study.  The script expects the lookup table to have columns "dns_id" and "exam_id" - and expects the format of the exam ID embedded in the subject paths in the SPM.xY.P variable to be "XXXXXXXX_XXXXX"  For a different standard, this will obviously need to be modified!
  * **Multiple extractions / file?** The reason that each extracted timeseries is put into its own .csv is because the subject IDs are pulled from the SPM.mat, so each extracted timeseries has a different group SPM.mat (and subject IDs), mask file, threshold, correction, etc.  I also decided to make one list per file so that the files could be more easily utilized by other tools.  
  * **Output Name:** The name of the .csv files corresponds to the details of the extraction in the format contrast_mask_correction_threshold, however more detailed information can be found by looking at the VOI_(name).mat and .img/.hdr files, which should still be in the group folder.  I decided to not delete these in the case that they might be useful at some later point. 
  * For both scripts - I decided to hold off on adding the option to extract a VOI based on a sphere or square.  If you are interested in a cluster of activation within a mask or a particular spehere / box, the easiest thing to do is to create a mask image of this region to use with the script. 
  * The script does not currently support extracting a peak voxel - all extractions are means across a specified mask.  Vanessa will add this functionality to both scripts if she has time, however it is currently only setup to handle extractions based on a mask. To add other functionality and essentially use the VOI tool to extract based on something else (max voxel, sphere, etc), you can either create a copy of the script and modify the matlabbatch section, and add a user variable to select the type of extraction, as well as all of the details.  In this case you would also want to add another input argument(s) on command line to take in this information.
