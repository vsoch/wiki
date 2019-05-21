# Results Reports

Although this functionality is now integrated into the main pipeline, these scripts were created in order to process results reports for faces, cards, and an image of the T1 highres for subjects who were processed before this step was added to the pipeline.

## Scripts
 - [spm_results_python](spm-results-python.md): The standard python template that takes in subject IDs and run decisions as variables, and creates an iteration / subject of...
 - [spm_results_bash](spm-results-bash.md): Sets up correct paths, and template script for each subject, and submits the job.  Lastly, it goes to the Data_Check output folder and converts the .ps file to .pdf and deletes the template script in the individual subject folder and the original .ps file.

 - [results_report.m](scripts/results_report.m) Is the template script in matlab.  You should look at this script for a detailed account of what is going on!

### Report Parameters
Here are some suggested parameters.  Since you want to get some activation to see that it looks ok, you should be lenient about the correction / threshold! 
  * uncorrected, p = .001
  * 10 voxel extent threshold
 
### Output

* subject_ID_YYYYmmmdd.pdf goes into the folder N:/NAME.01/Graphics/Data_Check/
* Faces/block
* cards
* or T1
