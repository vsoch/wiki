# MRTOOLS - python module for image reading, filtering, matching=====

**still in development! More sample usage coming soon!**

MRtools is a module for basic image manipulation and processing intended to be used to create scripts with mode complex functionality. MRtools started as part of the ica+ package and now is grouped under "MRutils package" for more generalized use.

Given that I forsee needing to achieve this functionality for many different applications across my graduate career, I decided that I wanted to create a module that would do matching, filtering, and reading / looking up coordinates and values that might be applied to many different things. I separated the functionality to read in an image and look up coordinates from pyCorr (which did the template matching) and created a python module called [MRtools.py](https://github.com/vsoch/MRtools/blob/master/MRtools.py), which has the following classes and functions: 

  * MRtools.Data: Translate between images of different dimensions and formats (.nii,.nii.gz,.img)
  * MRtools.Filter: Determine goodness of an input image and a frequency timeseries 
  * MRtools.Match: Return match score for two MRtools Data objects
  * MRtools.Mask: Create masks to apply and save

## CHANGE LOG

```
# CHANGELOG  ##################################################
3/17/2012: Added ability to read in 3D OR 4D image
           Added start of Mask module
           Added print functionality to Data and Mask object
3/29/2010: Added "ROI" Class to MRtools
           Added searchlightROI.py w/ square ROI functionality
```

## TO DO
```
# TODO ########################################################
- visualization of images
- add other ROI shapes to searchlightROI
- saving data to mat file
- output of data for ML
- fix up match methods
- update MRlog and add to package
- update atlasimage.py and add to package
- update voxLabel.py and add to package
```

## DOCUMENTATION AND INSTRUCTIONS
### DATA

```python
>> import MRtools

# First will check for 4D, then 3D image
>> Image = Mrtools.Data('myimage.nii.gz')    

# Will read in 3D image, or first timepoint of 4D
>> Image = Mrtools.Data('myimage.nii.gz','3d') 

# Will read in 4D image.  If 3D given, will read as 3D
>> Image = Mrtools.Data('myimage.nii.gz','4d')

# Coordinate conversion
>> Image.mritoRCP([x,y,z])
>> Image.getValMNI([x,y,z])
```

### FILTER

```python
>> import MRtools
>> Image = MRtools.Data('myimage.nii.gz')
>> Filter = MRtools.Filter()
>> Filter.isGood(Image,'timeseries.txt','frequency.txt')
```

## MATCH

```python
>> import MRtools
>> Template = Mrtools.Data('myimage.nii.gz')
>> Match = MRtools.Match(Template)
>> Match.setIndexCrit(">",0)
>> Match.genIndexMNI()
>> Contender = MRtools.Data('contender.nii.gz')
>> Match.addComp(Contender)
>> Match.doTemplateMatch()
```

## MASK

```python
import MRtools
import numpy as nu

# Create binary mask from input image
mask = MRtools.Mask('MR/test1.nii.gz')

# Save mask to file
mask.saveMask('outname')         # will be .nii
mask.saveMask('outname.nii.gz')   
mask.saveMask('outname.img')     

# Read in image to mask
image = MRtools.Data('MR/test2.nii.gz')

# Mask image and save output
masked = mask.applyMask(image)
output.save('Outfolder/output.nii.gz')
```

## ROI
```python
>> import MRtools
>> Image = MRtools.Data('myimage.nii.gz')

# Create ROI object to extract ROIs that surpass thresh
# size is units from centroid that passes thresh
>> ROI = MRtools.ROI(thresh,size,output)

# Return list of lists, each has coordinates for ROI
# The centroid is the first coordinate
>> ROIlists = ROI.applySquareROI(img)
```

See [fall_2011](fall-2011.md) as example scripts that utilize the modules functionality to perform template matching, filtering, and image manipulation.

### Utilized by...
The following scripts use MRtools for their functionality:
  * [MRlog](mrlog.md)
  * [pyMatch](https://github.com/vsoch/MRtools/blob/master/pyMatch.py)
  * [melodic_hp](https://github.com/vsoch/ica-/blob/master/melodic_hp.py)
  * [AIMTemp](https://github.com/vsoch/MRtools/blob/master/AIMTemp.py)
  * [searchlightROI](https://github.com/vsoch/MRtools/blob/master/searchlightROI.py)
  * [MRVector](mrvector.md)

See [fall_2011](fall-2011.md) for documentation of running these scripts here.
