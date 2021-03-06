# PPI Processing Pipeline

We use the familiar combination of a python, bash, and matlab script for running subjects through PPI analysis.

## Running the Scripts
**Script Locations**  The user can copy the bash and python scripts to his or her head node, and the matlab template script to somewhere accessible on the running cluster.

### Instructions
The user must simply fill in all user variables in the python script, including the experiment name, subject IDs, task name, roi name, and output folder name.  Depending on the task design, the script may or may not require an order number.  Below is a general overview of the PPI Pipeline that can be applied to multiple tasks. 

### Details
**PPI Python** This script takes all of the input variables from the user.  This script will submit one iteration of the bash script template for each subject. Since we run the scripts on the cluster, this means that we can process up to 200 subjects at the same time.

**PPI SHELL TEMPLATE** is the bash template script for which one is run for each subject.  It does the following:
  - reads in subject specific variables from the python.  It checks that the order number and task is valid, and then navigates to the directory with the MATLAB script template to shove the user variables into the template and save a subject-specific version to the subject's output directory.  We then set up the virtual display and submit this script to run in matlab. 
  - Creates a VOI that can either be defined by a mask (how you might do a cluster, saved from a group map), a sphere, or a cube.  The VOI is copied from the single subject SPM.mat directory into a single subject "VOIs" folder.
  - A folder is created under the single subject PPI folder with the specified name of the output folder.
  - We next do the PPI analysis.  Note that the matrices that are fed into the PPI analysis to specify the contrast of interest are always a 3 X n matrix with each group of three representing a condition from the SPM.mat that you want incorporated into the analysis.  The format is the following:  `condition#1  1  weight;  condition#2  1  weight`.  For example, if we wanted to model "One > Two" and One was the 3rd condition in the SPM.mat, and Two was the first, we could use the matrix `[1 1 -1; 3 1 1]`. The original pipelines that I created fed in the matrix from the python script, but since this makes running complicated and increases the chance of user error, these matrices are now hard coded into the matlab scripts.  For tasks that have one order OR the matrix is the same for all subjects regardless of order, the python script does not require an order number.  For tasks with specific orders, it does.  Look at the matlab templates for a full overview of the matrices used.  
 
[PPI ALLFACES 3 Regressors](scripts/PPI_ALLFACES.m) matlab template does the PPI analysis followed by a single subject analysis including the three regressors produced by the PPI analysis.  The [PPI ALLFACES Python](ppi-allfaces-python.md) and [PPI ALLFACES Bash](ppi-allfaces-bash.md) should be used to run it.  If you are ONLY interested in Faces > Shapes you should use this script!  If you are interested in another contrast, use PPI FACES 11 regressor (below). This 3 regressor model script does the following:
  - Adds necessary paths for BIAC and Subject directories
  - Goes to the ROI directory, creates the subject specific VOI with a threshold of 1 so that ALL voxels are included, and copies this file as "VOI.mat" into the subject's task specific first level analysis directory.
  - changes the paths of the SPM.mat in this directory from local machine (N:/NAME.01/...) to the temporary cluster path it is using (/ram/mnt/abc1....)
  - loads the SPM.mat and runs the PPI analysis by calling the script "spm_peb_ppi" with the VOI.mat, the task specific matrix, and the specified output folder and name.  The result is a matrix called PPI_(outputname).mat - which gets copied into the subjects PPI output folder.  The graphical output is printed to a file called "output.jpg" which is then moved to the subject's output PPI folder.
  - The time series that we have extracted from the seed ROI at this time are active in MATLAB under the variables PPI.ppi (PPI), PPI.P (Conditions), and PPI.Y (Seed Activity).
  - The script then sets up single subject analysis with the preprocessed images from the task of choice, and the extracted values are fed in as three regressors (in the order above, 1,2,3, respectively).  Additionally, we feed in the ART motion outliers from the subject's previous first level analysis for whatever task we are currently running.  We can do this because we are using the the same swu images, and the motion outliers are based on these images!
  - The contrasts created are Positive PPI (1), Negative PPI (2), Positive functional connectivity (3). and Negative Functional Connectivity (4).
  - The script, after setting up the details of the job with the spm_jobman, runs the job (saved under matlabbatch) with the "run_nogui" option specified.
  - We lastly change paths in both the old SPM.mat used for the PPI analysis and the new SPM.mat produced afterwards... from cluster to local.
  - Lastly, we shoot back to the PPI Bash template and clean up the memory that was allocated for the virtual display, and delete the lock file so the random allocation is free for someone else to use!  This concludes the running of the PPI analyses.

**NOTE** that this script works well for input matrices that include all blocks of the task.  If you want to model individual contrasts and use include multiple regressors (one for each condition) then you should look at:

[PPI FACES 11 Regressors](scripts/PPI_FACES.m) Matlab template run with [PPI FACES Python](ppi-faces-python.md) and [PPI FACES Bash](ppi-faces-bash.md), and works similarly, except it takes in an order number variable, creates the VOI, and then a PPI analysis is done for each condition of the task, and 30 contrasts are created for various combinations.  Please see the matlab template script for these contrasts and the matrices.  Although this script creates a Faces contrast, the 3 regressor model (outlined above) should be used if you are only interested in Faces > Shapes PPI.  You should use this script to run PPI analysis for any contrast other than Faces > Shapes.

[PPI CARDS 7 Regressors](scripts/PPI_CARDS.m) Matlab template run with [[PPI CARDS Python](ppi-cards-python.m) and [PPI CARDS Bash](ppi-cards-bash.md), and works similarly by creating a VOI, and then a PPI analysis is done for each condition of the task (control, positive, and negative feedback), and 14 contrasts are created for various combinations.  Please see the matlab template script for these contrasts and the matrices. 
