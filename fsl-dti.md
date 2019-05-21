# FSL DTI

## Processing Data with FSL's FDT Diffusion

First we need to identify the directory with the DTI dicom images, and convert those images to nifti using MRICron, or your method of choice, just as with the FEAT analysis.  First we have to do eddy current correction, which I believe is a sort of motion correction, to correct for eddy currents produced by the scanner when gradients are turned on to the max value (and we get distortion).

**EDDY CORRECTION** 
  - In the FSL GUI, click on "FDT DIffusion" and select "Eddy Current Correction" in the top window.
  - The data file is the nifti that we just created.
  - for output, change this to "data_corrected"
  - Reference volume should be 0 (back to b-value of 0).
  - Press "Go" and wait for it to finish.

**BET Binary Mask** 
  - Run BET in FSL.
  - Under "input" select the data_corrected file that we just made
  - Under "Advanced Options" check "Generate Binary Mask" and uncheck "Generate image with non-brain matter removed"
  - The Fractional Intensity Threshold should be .3
  - Select OK
  - The resulting file will be data_corrected_mask, and we need this for the next step!

**DTIFIT** 
  - Now, select "DTIFIT RECONSTRUCT DIFFUSION TENSOR" at the top, and click on "Specify Input Files Manually"
  - Diffusion weighted data is the corrected file, data_corrected.nii (or do we use the original nifti I believe... need to check)
  - BET Binary map is the data_corrected_mask that we just made
  - The gradient directions file is the .bvec file in the same directory
  - The B-values file is .bvals
  - Click "run" to run the DTI fit and wait for it to finish!
  - I think you will get an error message, likely, ignore it!

Now we can view our DTI data with FSLView

**Vieiwing DTI data withe FSLview** 

FSL has written the results as analyze format files, and you can open then in FSL View. Your files should be saved in your data folder. It will save one file with the title 'FA', which refers to the Fractional Anistropy map. It also saves the three orthogonal vectors (V1, V2, V3).
  - Start FSL and open FSLView
  - Open the FA map, and then do File --> Add and add the V1 file as an overlay (these are the principle vectors)
  - Click on the eyeball at the bottom for the V1 file and select that it is a DTI display image type, and then for overlay information choose "RGB" and DTI-Display "Modulate."

## Tractography
This is the viewing of DTI data that shows all the specific lines/tracts, direction, etc.  For tractography we want to use the option under FDT called "Bedpost" and we need to put all of the setup files in an "input directory"

 - [BEDPOSTX](http://www.fmrib.ox.ac.uk/fsl/fdt/fdt_bedpostx.html)

Here is the link for the [MedINRIA](http://www-sop.inria.fr/asclepios/software/MedINRIA/) which is a separate software package that also does tractography for DTI.

## Script Processing DTI Data

 1. [[DTI Preprocessing](dti-preprocessing.md) includes Eddy Correction, creation of a no difference mask, and DTIFit.  Output is put in the subjects DTI folder under DTI

If you are interested in FA values...
  * 2. [FA-move](fa-move.md)
  * 3. [TBSS](tbss.md)

OR

If you are interested in Tractography...
  * 2. [BedpostX](bedpostx.md)
  * 3. fnirt and
  * 4. ProbtrackX

would be the next steps, however I did not make scripts for them!
