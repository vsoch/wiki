# FSL Common Errors

## Registration Problems
* The image comes out twisted and flipped, and everything about the analysis seems correct, other subjects don't have this problem
Did you do registration with the standard space AND a high resolution, subject specific image?  Sometimes, for a reason that I don't understand, this happens, and by removing the middle registration image (the T2 high res) the problem is resolved.

## Third Level FEAT
  - In Higher-level-stats log of a level 3 analysis “ERROR (nifti_image_read): failed to find header file for ‘filtered_func_data’ ERROR: nifti_image_open(filtered_func_data): bad header info Error: failed to open file filtered_func_data Error:: FslGetDim: Null pointer passed for FSLIO” 
  - This error indicates that it had trouble locating a participant's COPE, which either means that level 2 analysis didn't work for a subject or two, there is a path error to a .feat directory, or some other reason a contrast for a particular subject cannot be found.

  - If you ever see an error in the main log or a particular cope's log about "dof cannot be negative or 0" this means that you have zstats that are "NAN" (not a number) which means that you have errors in one or more of your first level FEATs.  To find them, open up the filtered_func_data as an overlay in showsrs2 and look for huge spikes - the number that the spike occurs at is the subject that has the error.  You can see an example at [here](img/spike.JPG) Look in that subject's first level FEAT in the log for errors that say something to the effect of:

```bash
/usr/local/fsl/bin/fslmaths filtered_func_data -Tmean mean_func 
++ WARNING: nifti_read_buffer(filtered_func_data.nii.gz): 
   data bytes needed = 557056 
   data bytes input  = 468775 
   number missing    = 88281 (set to 0) 
```

and

```bash
/usr/local/fsl/bin/fslmaths stats/zstat1 -mas mask thresh_zstat1 

echo 54628 > thresh_zstat1.vol 
zstat1: DLH=nan VOLUME=54628 RESELS=nan
```

and you will see an odd drop in the timeseries plots of the zstats.  To fix this, try re-running and troubleshooting that particular subject's group FEAT.  Worst case scenario you can drop that person from the group analysis.
