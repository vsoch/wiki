# Bet

BET takes the .nii file in the subject's anat(3) folder, and crunches out anat_brain.nii for use with FEAT first level analysis.

## How do I run this script?

From the head node, run "nedit" and copy paste the code into a file to save as BET.sh. Make sure that you change the email in the file, and check the script to make sure everything will come out correctly.  Then, back in the terminal window, type 
```
chmod u+x BET.sh
```
to make the code executable.  To run the script, you need to submit it to your cluster.  An example of a submission command is shown below:

```
qsub -v EXPERIMENT=Dummy.01 BET.sh Data/RawData/   *.nii          anat_brain          3          1111111111 
#                               (datadirectory)    (input nifti)  (output file)     (anat folder) (SUBJECT ID)
```

To perform a brain extraction with a script, you can either run a single script with BET.sh, or run multiple subjects using a python script (BET_TEMPLATE.sh and BET.py)
  * [BET Manual](bet-manual.md) for a single script run, or manual
  * [[BET Python](bet-python.md) for multiple runs
