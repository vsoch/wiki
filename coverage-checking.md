## Why do I need to check coverage

For any group analysis, the voxels included in the group analysis are the ones that we have signal at for EVERY SUBJECT.  So, if we have one subject with signal loss, this means we will lose that voxel in the group analysis.  We need to be able to identify these subjects that are decreasing the size of the group mask, and then potentially omit them from the analysis.  

Originally, individual registrations had to be checked against an ROI mask in [[xjView]], which would be very time intensive.  FSL had a smart strategy of creating a master image that showed the voxels that were not included in the group mask because they were missing for one subject.  The intensity values of this image would represent the number of the subject.  I decided to write a script that would bring that same functionality to our SPM group analysis.

### How can I check coverage?
covcheck_free() Alpha by Vanessa Sochat

#### Overview

When doing a group analysis in FSL or SPM, if any one subject is missing coverage due to signal loss, this means that the group map will not have this area either (only voxels that ALL subjects have are included in the group analysis).  This presents us with the problem of seeing a bad group mask, and not having any idea which individual subject is responsible for the loss in coverage.  Since there is no methodical way to look through individual subject masks (the mask.img for each subject in the first level output directory) I created this script to help find subjects with poor coverage, and create a list of good subjects to use for the group analysis.

#### Variables
This matlab script checks the coverage for a group of subjects that have completed single subject analysis, and are ready for a group analysis.  The script takes in:
  * binarized mask images (one per subject) from an analysis.  In SPM8 the mask.img file in the single subject directory represents the area that each single subject has coverage for.  If you select a non-binarized image for your masks, the script will not work.
  * A user specified coverage percentage
  * A directory to make the output folder
  * An ROI mask that the user wants to use for group analysis (can be created in SPM with pickatlas, or however you like)
  * A percent coverage minimum, which is the minimum coverage of the ROI that is acceptable to include a subject in the group analysis.  For example, if our mask has 5000 voxels and we specify a % coverage minimum of .95, then only subjects with .95 X 5000 voxels (minimally) will be included.


#### Order of Operations
  - The script first sets up output directories and paths.  An output folder will be made in the users directory of choice with the date and time as the name, and with the following subfolders:  "results," "logs," and "masks."  The "masks" folder will hold the raw copied masks from the single subject directory.  A subfolder called "ROI_applied" will hold these same images that have been masked by the user specified ROI.  The naming convention for the ROI_applied folder is "brainmsk#.*"
  - We calculate the number of voxels in the ROI, and multiply that by the % coverage specified to get the minimum number of acceptable voxels for each subject
  - The subject data (the mask.img and mask.hdr file) is copied from the Analysis directory of each subject into the output directory under "masks."  Each subject is assigned a mask number, so the new files are saved as "mask_#.img" and "mask_#.hdr."  This number will be important for identifying the subject in the output text files, and matching masks with subject IDs.
  - We use the ROI to mask the subject data, and each subject has a new mask saved under "ROI_applied" with the prefix "brainmsk" followed by the appropriate mask number.  We then calculate the number of voxels in this resulting image.  If we are below the threshold, the subject is flagged for review.  If we are above the threshold, the subject is added to the "INCLUDED" list.  If the mask cannot be found, the subject is added to the "MISSING" list.
  - For each subject that is flagged, the user is prompted if he/she wants to visually check the images, and if the graphical output should be printed to file.  The script then displays a 3D image and a slices image for each flagged subject, and the user is asked to select if the subject should be eliminated.  If the user selects to not visually check the flagged images, then all subjects flagged for elimination get placed in the eliminated list.
  - If the user selects to print graphical output, this output gets printed to the post script (.ps) file in the top level of the output directory.  Double clicking this file will convert it to PDF with Adobe Distiller.
  - If we eliminate the subject, they are added to the "ELIMINATED" list.  If we don't eliminate them, they are added to the "INCLUDED" list.
  - Finally, the lists of subjects that are missing, eliminated, and included are printed to text files under "logs."  Each log includes the Subject ID, Mask ID number, and Voxel count for each subject.  The included subjects are under (included.txt), the missing subjects are under (missing.txt), and the eliminated subjects are under (eliminated.txt).
  - The user is shown a final "group mask" whole brain and group_ROI image in both the 3D and slices view, and these images are saved under "Results" with a print out.

#### The Script
  * To run, make sure that it is saved in a scripts directory that is part of your MATLAB path.
  * To run, simply type 
<code matlab>
covcheck_free 
```
in the MATLAB window, and it will prompt you for all of your variables.  The newest version is:
  * [covcheck_free.m](scripts/coverage_free.m) that allows the user to select any set of mask.img files, as opposed to the old version:
  * [cov_check.m](scripts/cov_check.m) which was made specifically for the LoNG data hierarchy and requires the user o select a task and experiment.  This script also requires the user to select a number of subjects, and the design type.
**Future Plans**:  I'd like to make a coverage checking utility that works directly within SPM, and allows the user to select a group .mat design file, and then click subjects "on" and "off" in a live GUI to get a sense of what the group map would look like.  A good project for my next Christmas break! :O)


#### OLD Method with FSL Utils

FSL had  nice utility that created a "uniquemask" image, which displayed all of the voxels for each subject that were missing JUST for that subject - and the intensity value for each of these clusters represented the subject ID.  So you could run this for a group of subjects, overlay a mask, and then click on clusters to see subjects that were missing coverage, meaning the area wouldn't be included in the group analysis, and you could eliminate the subject.  I stopped pursuing this method because I wasn't comfortable with using the utility without completely understanding how the thresholding was done.
  * [[SPM_REG_Check]] To be run on head node, Hugin.
  * To run, save the script onto your head node, input variables, and type 
```
chmod u+x SPM_REG_Check.sh
```
to make it executable, and then 
```
qsub -v EXPERIMENT=DNS.01 SPM_REG_Check.sh
```
  * The script takes the subject IDs in an array in the format ( SUBJECT1 SUBJECT2 SUBJECT3 )
  * The user must specify "yes" or "no" to three variables "FACESCHECK" "CARDSCHECK" and "RESTCHECK" to dictate whether or not they want to check each task.
  * The script creates an output directory with the date and JOB ID (in the case you run it multiple times in one day) under Analysis/Second_Level/(TASK)/Coverage_Check/
  * The script outputs the following files:
   * uniquemask.nii: shows the voxels eliminated from the group mask for each subject AFTER thresholding by the mean over time (see script for the exact code - this is exactly what is done in FSL) and I believe it is representative of what is done for a group analysis.  The intensity values represent the subject numbers.  You can open this image with your viewer of choice and compare against an ROI to find the regions that are being discluded due to one subject.  You can then try running the script again without that subject to see if it fixes the coverage issue.  When you are happy with your subject list, you can re-do your analysis with that list.
   * uniquemask_fini.nii: shows the voxels eliminated from the group mask for each subject SANS thresholding.  This is easier to clunk a mask on and figure out where we are losing coverage.
   * mask.nii: is simply a 4D file, for which each timepoint is a subject
   * masksum.nii: is simply the entire group mask
   * masksum.png: is an image that shows the group mask sliced
   * (Task)_(JOBID).txt lists each subject ID with the actual subject folder identifier, so when you find a subject number in the uniquemask.nii that you want to nix, you can find the actual subject ID in this text file.
