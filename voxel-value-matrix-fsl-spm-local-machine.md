# Voxel Value Prep

**PLEASE REMEMBER THAT THIS IS THE OLDER VERSION THAT USES FSL AND OLD SPM DATA**
**NOTE: Scripts can be used to perform the following steps:**
These scripts are intended to run on Einstein, and can be modified for Hugin
  * Steps 2-4 use [Voxel_Matrix_Prep](voxel-matrix-prep.md)
  * For masks, use [Voxel_Matrix_Prep_Masks](voxel-matrix-prep-masks.md)
  * Step 5 Matlab script not yet written

## Data Preparation

  - Preprocess the raw data in SPM5 (this was the data that I used, but you can use SPM8 as well!)
  - Make the .swrf (3D files) into a 4D image
  - The first thing that we need to do is take all of the individual swrf or swu .img files, which are 3D images, and merge them into one 4D image.  To do this, log into qinteract (or your cluster where fsl is installed) and navigate to the subject directory with the .img files.  

```bash
# fslmerge is the command, you can type it alone on the command line to see the various options
fslmerge -t faces_4D_swrf swrf*.img
# -t means that we are concatenating images over time
# faces_4D_swrf is the name of the output
# swrf*.img says to concatenate everything that starts with swrf and ends in .img
# This will produce a 4D image, faces_4D_swrf.nii.gz, which is made up of the 195 images, in the same directory.
```

## MASKING

  - **Using the mask** If you look at this image, it will look like a cloud, because there are intensity values greater than zero outside of the brain.  What we need to do is clean it up by using a mask, because we want anything outside of the brain space to have a value of zero.
  - If you look in the same folder, there is a mask.img and mask.hdr image file.  This is the mask that we will be using to clean up our 4D image.  Each subject has their own mask that is in a template space but is slightly different for each subject.  Although the type is .img, if you do fslhd or fslinfo <filename>, you will see that it is classified as a nifti and does not have a specified origin, so it actually matches our 4D file.  This is good!
  - **Apply the mask to the 4D image**

```bash
# Using the multiplication option:  
fslmaths faces_swrf4D.nii.gz -mul mask.img faces_swrf4D_masked_multiply

# Using the masking option:   
fslmaths faces_swrf4D.nii.gz -mas mask.img faces_swrf4D_masked
```

I tried both of these options, and the output looks identical.  I did fslmaths faces_swrf4D_masked.nii.gz -sub faces_swrf4D_masked_multiply.nii.gz faces_swrf4D_masks_difference to see the difference between the two - there was nada!  The script uses the -mas option.

### Get Rid of Eyeballs
Unfortunately, we have eyeballs in our mask and data.  We have to run a standard brain extraction on the new masked, 4D image to clean out the eyeballs.  You can use the GUI with the standard brain extraction settings and a threshold of .225, or if you type in the command line, it is as follows:

```bash
bet faces_4D_swrf_masked.nii faces_4D_swrf_masked_noeyes -f .225
# faces_4D_swrf_masked.nii is the masked 4D images we just made
# faces_4D_swrf_masked_noeyes will be the resulting image, a compressed nifti of type .nii.gz
```

### Change the filetype for MATLAB/SPM
I discovered that SPM doesn't like the compressed nifti (.nii.gz) but works ok with the .nii extension.  To change the filetype, simply use the command:

```bash
fslchfiletype NIFTI faces_4D_swrf_masked_noeyes.nii.gz
# NIFTI is the selected output
# faces_4D_swrf_masked_noeyes.nii.gz is the input file
```

This will result in faces_4D_swrf_masked_noeyes.nii, which is the file you take on to the next step.  

### Create the matrix in MATLAB

from Patrick in Pittsburgh
  - Start up MATLAB, you will probably have to navigate to your SPM directory for the scripts to work.
  - Type the following in the Matlab command window:

```matlab
img=spm_vol(spm_select); 
```

which stores header info about the image that you select in a variable called "img." It's important to include the semicolon, otherwise SPM will print the output in the window, which is wicked long, and will make you go AHHH!
  - If the command works and you've correctly installed SPM, an SPM GUI will pop up that let's you choose as many images as you want.  Since we've converted the swrf images into one 4D image, we can simply navigate to the subject folder and select that file.  Note that in this GUI, you don't need to double click anything.  Clicking on a file or directory once will open / select it, and in the box at the bottom, clicking a file once will remove it as well.
  - Next, we need to save the values for each voxel within the image that we loaded into the "img" variable.  We will save these values in a new variable called "vox," which is a 4D matrix.  Patrick provided this lovely metaphor:

"The way I think about it is its like cubes on a string.  Each cube contains all the voxel values for one volume.  The string is time, the chronological order of the volumes"

To create the matrix, type the following in the command window:

```matlab
vox=spm_read_vols(img);
```

We won't be doing anything with this matrix other than saving it, but if you wanted to find out the value at voxel (35, 27, 12) for the 45th volume in the time series you would type the following into the Matlab window:

```matlab
vox(35,27,12,45)  <--omit the semicolon here otherwise Matlab will not print the value.
```
Now we need to save the 4D matrix into a .mat file by using the following command:
```matlab
save subject_ID_matrix vox  <--semicolon doesn't matter here, there is nothing for Matlab to output
```
This is the 4D matrix (of size 115 MB or 0.1 GB) of voxel values for all 195 volumes from the old faces task.  The standard that we are using for naming is the subject ID followed by _matrix, which should replace "subject_ID_matrix" in the command above.  The .mat file will be saved in whatever directory is open in matlab.  You will need to copy the file into SPMFaces/Matrices.

**A last tidbit from Patrick that we didn't use, but may be of use in the future:** \\
When you choose the images to load (step 1) you don't have to choose every image from one subject or images from only one subject.  Another command that may be helpful:
```matlab
img(112).fname
```

This will show you the image file name that is 112th in the list of image files.
