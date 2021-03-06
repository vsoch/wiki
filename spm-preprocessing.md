# SPM Preprocessing

## 1. Convert from Dicom to Analyze

Raw MRI images from scanners often come in DICOM format (*.dcm).  SPM cannot handle DICOM images, so the first step is to convert from DICOM to ANALYZE or NIFTI images.  This tutorial will go through conversion to ANALYZE, but you could just as easily convert to 3D nifti. When converting to ANALYZE, two new files are created for every DICOM file, an image (*.img) and a header (*.hdr) file.   SPM8 can also handle NIFTI (*.nii) images.)

  - Select DICOM IMPORT 
  - Select all *.dcm files you want to convert
  - Select the directory you want the converted (*.img and *.hdr) images to be placed.  **NOTE:**  It is very important create a folder for each functional run (i.e., Task and Anatomical) and a folder for the structural image.  When you are converting the images, you have to convert each run separately in order to place the new, converted images in the appropriate folder.
  - Repeat this step for each functional run you have, and the structural image.  **NOTE:** When converting from DICOM to NIFTI the structural images will be in a s* format, while the functional images will convert to a f* format.

You have now converted all your raw DICOM images to Analyze format.

**NOTE:** This step can be batch processed in SPM8 using the batch process editor and selecting multiple “Dicom Import” modules.  This step is necessary to convert the format the MRI scanner uses into a format SPM can work with.

## 2. Segmenting the Structural Scan
This step helps improve the coregistration and normalization steps for a better “fit” of the functional data to the structural.

  - Select SEGMENT
  - Select DATA and choose the directory where the T2 image is (after the dicom import step— s*.img).  The segmented images will be created within this directory also.  
  - Leave the defaults set (native space for grey and white matter and none for CSF)
  - (If you are using high-resolution structural images in your preprocessing (instead of a T2) and will be doing VBM later, you can set SPM to create files you will need later; however, this makes this step very time-consuming.)
  - Visually inspect the segmented images.  If they are strange-looking—black, ghostly, warped—then you need to set the origin for this dataset before continuing.  See the next section.
  - Once the data looks good, copy the c1 image into each functional folder because it will be modified for each functional scan. This step segments the brain data into different types of matter based on its make-up. By telling SPM whether it is white, grey or CSF, SPM is better able to do the next steps because it is clearer what is and is not brain.

**ONLY DO THIS IF THE SEGMENTED IMAGE LOOKS BAD: REORIENT STRUCTURAL AND FUNCTIONAL IMAGES** \\
In this step, you reorient the images to the AC-PC line (anterior commissure-posterior commissure) to help facilitate all other preprocessing steps.  To do this, the blue cross hair should be placed on the AC, and the head should be positioned so the X-axis line passes through the PC.  There is no secret to aligning to the AC-PC.  Each structural image is different and some are easier to see than others.  It doesn’t have to be perfect.  There are several online sources to help you find the AC-PC.  See the following link for one of the most helpful: http://imaging.mrc-cbu.cam.ac.uk/imaging/FindingCommissures

  - Select DISPLAY and display your structural image (s*.img)
  - Click the CROSSHAIR POSITION button to set the crosshair position to (0, 0, 0)
  - Reorient to the AC by entering in values for right, forward, up, pitch, roll, yaw. 

**NOTE**  Unfortunately SPM doesn’t allow you to click around in the brain to reposition the cross hair.  If you do this, and then try to reorient your images, it probably won’t take.  Therefore it is important to reposition the cross hair by entering these values.
  - Once positioned, click REORIENT IMAGES and select your structural (s*.img) and all the functional images (f*.img) for that subject.
  - Display a random functional image to assure it was reoriented.

## 3. Spatial Preprocessing
### REALIGN & UNWARP
Subjects will move (hopefully not much!) during the scan.  Extreme head motion is a problem in analyzing fMRI data.  The purpose of realign is primarily to remove subject movement artifact in their data and adjust their data so that the brain is in the same space in each image.  During realign, the header files (*.hdr) are modified for each of the functional images so they reflect the relative orientation of the data.  After the images are realigned, they are resliced so they match the selected reference image, voxel for voxel.  Unwarping the data will help remove unwanted variance due to movement. If, in addition, movements are task related it will do so without removing all your "true" activations.  The method attempts to minimize total (across the image volume) variance in the data set.  It should be noted that while (for small movements) a rather limited portion of the total variance is removed, the susceptibility-by-movement interaction effects are quite localized to "problem" areas.  In SPM8, these realigned images and unwarped images are named the same as the original images, except they are now prefixed by “u”.  

  - Select REALIGN & UNWARP 
  - Double click –DATA to create a new Session.
  - Under SESSION, choose IMAGES
  - Select all the raw (or reoriented if you needed to) functional images (f*.img) that you want to realign  **NOTE:**  It is important to do each functional run (i.e., task) separately so that you will be able to see and save the movement parameters for each task.
  - Leave the defaults selected
  - Make sure you are in a directory that a .ps file can be saved (the motion parameters)
  - Click THE GREEN ARROW (Run Batch) to run the realign procedure

The movement parameters (translation and rotation) are now displayed.  (In general, for adults, you want to see no more that ± 2 mm or 2 degrees in any direction.  These movement parameters will be further examined when running the ART program).  The display of the movement parameters is saved as an spm.ps file in the same directory from where you began running the batch processes.

### CO-REGISTER
Structural images and functional images look very different.  Structural images are higher resolution, providing greater detail of the brain. \\ Co-registration maps the functional and structural images to each other.   

  - Select CO-REGISTER: ESTIMATE 
  - Click REFERENCE IMAGE 
  - Select the mean image (meanuf*.img) for the reference image.  This image remains stationary so the source image can be jiggled about to match it, voxel for voxel. 
  - Click SOURCE IMAGE 
  - Select the segmented grey matter image (c1s*.img) for the source image (Remember to make a copy of the c1 and place it into each functional task folder).  This is the image that is jiggled about to match the reference image. 
  - Click THE GREEN ARROW (Run Batch) to run the co-registration procedure.

### NORMALISE
The purpose of normalise is the spatially normalize the fMRI images into some standard space defined by a template image.  We use the template image supplied by SPM.    Normalising the data allows us to average subjects together in second level analyses.  The normalized images have the same name as the originals, but are now preflixed with “wus.”  The “u” specifies that they were realigned and unwarped, and the “w” specifies that they were write normalized.

### Select NORMALISE: ESTIMATE & WRITE
  - Double click on DATA to create NEW “SUBJECT” 
  - Double click SOURCE IMAGE and select your file 
  - Select the segmented grey matter image (c1s*.img) for the source image.  The source image is the one that is warped to match the template image.
  - Double click IMAGES TO WRITE to select your files 
  - Choose all the realigned, coregistered images (uf*.img).  These are all the images you want to normalize 
  - Under ESTIMATION OPTIONS Click on TEMPLATE IMAGE to select your file 
  - Select the grey.nii SPM template image, located in the /spm8/apriori/ directory. 
  - Click THE GREEN ARROW (Run Batch) to run the normalization procedure. 

#### SMOOTH
Smoothing is also an essential step prior to averaging subjects together in second level analyses.   This step helps to minimize the inter-subject differences in brain anatomy.

  - Select SMOOTH 
  - Click IMAGES TO SMOOTH to select your files 
  - Select all the realigned, coregistered, and normalized files, i.e., the wuf*.img files
  - Double click FWHM to edit textSpecify the smoothing kernel.  We typically use a FWHM of 6 6 6. 
  - Click THE GREEN ARROW (Run Batch) to run the smooth procedure 

Next, you might be interested in [SPM Batching](spm-batching.md)
