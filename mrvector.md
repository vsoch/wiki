# MRVector

Extract feature vectors for a series of n images that have been masked with columns of zeros (empty features) removed \\
-Note that data structures currently invoke memory problem - to be fixed with next release.

### OVERVIEW

MRVector takes as input a file with a single column list of images to be converted to masks (mask.txt) to be applied to a list of images (img.txt), also a single column file, and outputs extracted feature vectors (voxels) in a .mat file.  It does the following:

### PREPARING DATA

  - Images and masks MUST be of same dimensions, in the same space
  - If you specify one mask (one line in mask.txt), this mask will be used for all images. If you specify > 1 mask, you MUST specify a number of masks equal to the number of images.  Note that the first option (one mask) has not yet been debugged!
  - For each image in row n of img.txt, apply mask in row n from mask.txt
  - Extract x y z voxel labels from the first image. Since all images are in the same space, these labels should be equivalent across images
  - Extract entire timeseries from masked image and save to feature vector
  - Create an n X m matrix of n images, and m features (voxels)
  - Save the feature vectors, a list of image names (corresponding to rows of feature vector matrix), and a list of labels (xyz values of voxels) corresponding to columns

### USAGE
```
python MRVector.py --img=img.txt --mask=/path/to/mask.txt --out=data.mat
```

**Note that all three arguments above must be specified!**

### OUTPUT

Output is a .mat file for manipulation in matlab with the following variables:
  * data: a n X m matrix, n rows of images, m columns of features (voxels)
  * label: a n X 1 matrix with names of images
  * xyz: a 1 X m matrix with xyz coordinates of each voxel

### SCRIPT
[MRVector](https://github.com/vsoch/MRtools/blob/master/MRVector.py)
