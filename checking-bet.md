# Checking BET

The main purpose of the brain extraction is to remove all non-brain matter (skull, CSF, eyeballs, etc) from the anatomical nifti.  We usually do this by running a script, which outputs "brain_anat.nii" in each subject's anatomical folder. (The brain extraction on the functional data is done as a step in the first level FEAT analysis.)

**After performing brain extractions, it's important to check that** 
  - **The extraction happened, at all!**  
  - **We didn't remove too much or too little brain** (meaning our choice of fractional intensity threshold, usually .225, was right on.) 
  - **We removed the eyeballs** If the eyeballs are still in the anat_brain.nii, you will need to redo the brain extraction and select an option for eyeball cleanup (which you will need to do by adding a flag of -S into your BET script). Once you rerun with the eyeball cleanup option, you'll need to check each BET output again.  If this still didn't work properly, or removed too much additional brain beyond the eyeballs, you might want to change the threshold gradient of the fractional intensity threshold (which you will need to do by adding a flag of -g followed by a value between -1 and 1 into your BET script - a good value to try is -.2).

**To check these things:** 
  - For each subject, open the original anatomical nifti in the subject's anatomical folder in FSL view
  - Go to file --> Add, navigate into the "BET" folder and select "anat_brain.nii"
  - The brain extraction is now overlayed on the original anatomical image.  
  - Select the anat_brain.nii layer, click on the little "i" button at the bottom, and apply any color to it, so you can see the overlay
  - Click through the slices to best look at the top of the brain, the frontal lobes, and look for any extra or insufficient brain clipping. Generally, the extraction should be a good fit.  We are more worried about excessive trimming than a little extra.  Use your best judgment to decide if it's a good fit.
  - If the extraction either doesn't exist or isn't good, flag the subject in the EXPERIMENT.xls file (or your QA log equivalent) and add a comment about why it doesn't pass.  This brain extraction will have to be re-done with a lower or higher threshold.
  - If everything looks good, record "yes" next to the subject number in the EXPERIMENT.xls file in the Notes folder after you're done.
