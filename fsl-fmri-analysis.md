# FSL Fmri Analysis

## Overview
[FSL](http://www.fmrib.ox.ac.uk/fsl/) is a powerful tool for the analysis of many times of neuroimaging data, including BOLD / fMRI.  I put together some scripts and a general pipeline to go through the multiple steps of processing, and sharing them might be helpful for learning or establishing a pipeline in a different environment.

**GUI Tutorial**  

 - [Preparing for FSL](preparing-for-fsl.md)
 - [Manual First Level Feat](manual-first-level-feat.md) This is single subject analysis 
 - [Manual Second Level Analysis](manual-second-level-analysis.md) This is combining multiple runs for one subject 
 - [Manual Third Level Analysis](manual-third-level-analysis.md) This is a group analysis 

**Pipeline** 

 - [Preprocessing and Single Subject Analysis](#preprocessing-and-single-subject-analysis) 
 - [The Scripts](#the-scripts) 
 - [Organize Your Script Runs](#organize-your-script-runs) 
 - [Level 2 Analysis - Multiple Runs within the Same Subject](#level-2-analysis) 
 - [Third Level Analysis](#third-level-analysis) 
 - [Creating ROIs](#creating-rois) 


## Preprocessing and Single Subject Analysis

The first part of this pipeline is intended to move subject data from raw data through First Level Analysis.  For a detailed description of each step of this process, see [fMRI Analysis Piecewise](fmri-analysis-piecewise.md). fMRI Analysis Piecewise includes running QA, which is not included in the new fMRI Analysis Pipeline because it is done automatically on the scanner.  

  * This pipeline is set up based on the assumption that FSL is installed on a cluster, run with scripts submit to various nodes in some sort of unix environment that can connect to the data.  
  * Some sort of Quality Analysis should be done on the raw data to check for excessive motion, (rotational and translational) as well as approprite SNR and SFNR values.  A good tool for this is called QA, and is also part of the [BIAC XCEDE tools](http://www-calit2.nbirn.net/tools/bxh_tools/index.shtm).  Additionally, data should be visually checked.  At Duke QA is run automatically off of the scanner and can be checked by logging into the BIAC dashboard.  For instructions to check QA, see [Checking QA](checking-qa.md).  It is advisable for having QA standards and a method for flagging subjects that do not pass QA.  
  * You will also need to create your design template file.  See [Manual First Level FEAT](manual-first-level-feat.md) for these instructions.  Save the .fsf file along with your Excel design and EVs in a location that the script running on the cluster can access.  The scripts detailed in this documentation for example have a  TASK variable, as well as a Design Name (Block or Event), in the case that there is more than one design for a task.  Additionally, an Order ("1" "2" "3")... might be necessary for multiple order numbers, or you can just "1" for one order.

## The Scripts

Once the design is ready and QA checked, the entire process is run with a set of scripts:
**For all Preprocessing and FEAT Analysis** 
  *  - [PREPROCESS_FEAT](preprocess-feat.md) is the python script where you must input all your variables.
  *  - [PREPROCESS_FEAT_TEMPLATE](preprocess-feat-template.md) is the bash script that is filled in by the python script.
  * In these scripts, you can choose to run anatomical preprocessing and/or functional preprocessing, or just FEAT.
  *  - [First Level Feat Quality Check](first-level-feat-quality-check.md) 

**These scripts do the following:** 

  * **Conversion DICOM to NIFTI:** The raw data comes off of the scanner in a format called "dicom" (for the anatomicals) and 3D niftis (for the functionals) for which there is one image file taken every two seconds, or 1 TR.  During this time, the entire head is scanned, which includes 34 slices.  The first step of preprocessing that must be done to the functional and anatomical data is to convert these 3D image files into ONE 4D file called a nifti, that FSL uses for analysis.  To do this, the scripts use the [BIAC XCEDE tools](http://www-calit2.nbirn.net/tools/bxh_tools/index.shtm).
  * **Conversion of Data for SPM** In the case that we have ANALYZE files off of the scanner, we need to create NiftiHeaders for each of these.  The script is currently set up to perform this functionality, and this section can be eliminated if the data comes off of the scanner as 3D nifti.
  * ** Change Orientation from LPS to LAS** The orientation that FSL wants is LAS, RADIOLOGICAL ORIENTATION. (Right-->Left)  (Posterior-->Anterior) (Inferior-->Superior).  It comes off of the scanner as LPS, so the script fixes this.
  * **BET Brain Extraction** The Brain extraction is done on the anatomical nifti.  (This is the brain extraction that is done automatically for the functional data when we run FEAT).  The script produces "anat_brain" as the output in a folder called BET in the anatomical directory, which is what FEAT level 1 uses. See [BET Threshold](bet-threshold.md) for choosing a threshold value for the python script.
  * **FEAT Level 1 Analysis:** The last thing the script does is move the subject through FEAT Level 1 Analysis - looking for significance within one subject for one run.

## Organization of Script Running
This is the first time that you are running a script!  See [Running Scripts](running-scripts.md) for an overview.  

**Script Text Log**

It would be a good standard to have a place/file to keep track of script running, since each run will likely require various checks and you might want to make notes about data to leave for future users.  You might have different sections to keep track of order numbers, tasks and design, contrasts, as well as an organizational tab to keep track of folders, and a data log to keep track of who has what. 

## Running the Scripts
Save the scripts to your head node on your cluster as PREPROCESS_FEAT.py and PREPROCESS_FEAT_TEMPLATE.sh, insert all relevant variables into the python, make sure to make them both executable with:

```bash
chmod u+x PREPROCESS_FEAT.py
chmod u+x PREPROCESS_FEAT_TEMPLATE.sh
```

and then to run, type:

```bash
python PREPROCESS_FEAT.py
```

It's good to test on one dummy subject before submitting a huge batch.  When you finish with Preprocessing and First Level FEATS, you must do  [FEAT Level 1 Quality Check](feat-level-1-quality-check.md) before any group analysis.

If you want to do just preprocessing, or just FEAT, use these scripts:

**For just Preprocessing** 
  * - [FSL PREPROCESS PYTHON](fsl-preprocess-python.md) 
  * - [FSL PREPROCESS BASH TEMPLATE](fsl-preprocess-bash-template.md) 

**For just FEAT** 
  * Use the Python above, modify if necessary
  * - [FSL FIRST LEVEL FEAT TEMPLATE BASH](first-level-feat-template-bash.md)

## Level 2 Analysis

If we want to combine runs, then we use FEAT level 2 analysis.  Level 2 produces a .gfeat file for each subject. Running the second analysis creates COPE files for each subject, and eliminates the messy organization of subject by design type.  If we only have one run, then we don't need to do level 2 analysis.  We can then move on to Level 3, which is a group analysis.  My lab never did any combination of runs for level 2, so I never put together a script.

## GROUP FEAT Analysis

Just like with first Level FEAT, the setup for a group level FEAT is done in the GUI.  

  * [FSL Third Level Analysis](fsl-third-level-analysis.md)

## Quality Check

  * [Group FEAT Quality Checking](group-feat-quality-check.md)

## ROI

**Drawing ROIs** 

We next need to create ROIs for each subject, using the significantly activated regions as a mask found in the GroupFEAT analysis.  To do this, we must first create the mask, then use it in featquery, and then compile results.

1. [Create ROI Masks](create-roi-masks.md) 
  * for functional data: can be done with a script that extracts the main clusters, or drawn in MRIcron
  * for anatomical data: we can use an atlas

### A FEW MASKING OPTIONS

  * **To apply your mask to a group Analysis**, you can simply select the file under "Pre-threshold Masking" in the FEAT GUI (or create a variable to read from the simple_group_FEAT script)
  * **To extract parameter estimates** alone, then you need to use FeatQuery.
  * **If you want to extract parameter estimates from a functionally defined region:** Another option, which we are doing, is using an anatomical mask in the Group FEAT GUI, and then taking the significantly activated voxels within that area and making a functional mask to use in FeatQuery to extract parameter estimates.

 2.  [Featquery](featquery.md) runs via scripts and you must define your subjects, cope numbers of interest, and masks of interest 
 3.  [fq_read](fq-read.md) takes the individual featquery output and compiles them into one text file, the script output file

  * Once you are done running FeatQuery and have your results text docs after running fq_read, it is advisable to organize and name folders to best describe the analysis, and document absolutely everything!
