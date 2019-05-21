# DTI Manual Processing

## Install Diffusion Toolbox

The first step is to install the Diffusion toolbox, which is an SPM8 add-on.  You simply need to download the zip file, and extract the Diffusion folder under the "toolbox" folder in your SPM8 directory.  Make sure that it is added as a path. http://sourceforge.net/projects/spmtools/files/

### Creating normalized FA-images from DW-images using SPM8

  - Set Information (Diffusion Toolbox): enter the 16 DW images
  - Realign (Diffusion Toolbox): enter the 16 DW images
  - Reslice (SPM8): enter the realigned 16 DW images
  - Change information (Diffusion Toolbox): 1st enter the 16 DW, then the 16 resliced rDW
  - Tensor Regression (Diffusion Toolbox): enter the 16 resliced rDW + output directory
  - Tensor Decomposition (Diffusion Toolbox): enter 6 tensor images starting with D…
  - ComputeFA (Imcalc SPM8): Enter 3 eval images + output directory, image will be named FA.img
  - Segment FAimage (NewSegment, SPM8): Enter FA.img
  - Create Brain mask (Imcalc SPM8): Enter c1, c2 and c3 + output directory, image out=FAmask.img
  - Crop brain (Imcalc SPM8): Enter FA.img and FAmask.img + directory, image out=FAmasked.img
  - Normalize to FA template (Affine, SPM8): enter [=FAmasked=] as source and image to write
  - Smooth 4mm (range is between 2 to 6, we chose 4mm because the voxel dimensions are 1X1X2 and like fMRI, we should smooth 2-3 X the voxel size.

B-values and directions have to be set. Then, realign and reslice DW-images (the realign-function from Diffusion toolbox does not reslice). Header information has to be changed, then the tensors (order 2) can be computed. The tensors are decomposed into three eigenvectors with corresponding eigenvalues. The eigenvalues are used to compute fractional anisotropy using spm_imcalc. For normalization, it is important to create an accurate brain-mask which can be done by adding GM, WM and CSF (c1, c2 and c3) computed by newSegment. The FA-image is masked using spm_imcalc and the masked FA-image is normalized to the FMRIB58 template using affine transformation.

If you would like an example .mat to start from, you can download:
  * [DTI One Run](scripts/DW2normalizedFA.mat)
  * [DTI Two Runs](scripts/DW2normalizedFA_2runs.mat)

You will, of course, need to edit paths and variables / values, but the basic setup should be clear!
