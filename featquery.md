# Running Featquery

To run featquery, you can do it manually with a single subject by using the script 

 - [fq.sh](fq.sh.md)

OR input your variables into the python script 

 - [fq Python](fq-python.md), which uses 
 - [fq template](fq-template.md).sh as a template. 

The script asks for your Group feat, feat directory, as well as copes and masks. 

## Compiling Reports

Each featquery run is placed under Analysis/ROI/cope#/Cluster_#/SubjectID/fq_20/report.txt.  This text file has the values of the mean intensities, etc, that we are interested in.  The next step is to compile all of these files with the script 

 - [fq_read](fq-read.md).sh 
