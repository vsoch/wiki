# preparing for FSL

You will need a number of things to run a FEAT analysis, and this section describes how to create these things.  This documentation was modified from the Huettel Lab wiki, thank you!  \\

## What You Need
  - A tab delimited 3 column format text files of your behavioral data. First column is event onset, second event duration, 3rd is typically 1 unless you have reasons to differentially weight some events. For each condition of each run of each subject, you will need a separate 3 column format .txt document. So if you have 8 conditions, you will have 8 separate behavioral .txt files for each run of each subject!!! NOTE If you have a block design you do not need these :)
  - Anifti formatted anat and func files.
  - An anat_brain.nii, which you get by running BET on your nifti anats
  - A template.fsf, which is a really long Unix script that describes your full analysis model
  - A batchFSL script, again a Unix script, but this one defines input and output directories, etc., so that you can analyze all the runs of one subject with one script.

## Instructions

  - Change to the functional directory
  - Convert the functional data to NIFTI format, using [BIAC XCEDE TOOLS](http://www-calit2.nbirn.net/tools/bxh_tools/index.shtm):

```bash
bxh2analyze --niftihdr -s -v run004_01.bxh run01 
```

This will create one very large file (e.g., run01.img) that contains all of your data in 4D format, a NIFTI-format header (run01.hdr), a BXH header pointing to the 4D data (run01.bxh), and a .mat file for your data (run01.mat).

  - Change to the anatomical directory
  - Convert the anatomical data to NIFTI format:

```bash
bxh2analyze --niftihdr -s -v series002.bxh anat01
```

This will create the same sorts of files as for the functionals above. \\
  * Also see [Convert data from DICOM --> NIFTII](convert-dicom-to-niftii.md) outside of BIAC

**Run BET on your anatomicals.** On the main FSL GUI, click BET Brain Extraction. Then, select the anatomical you just created as your input image. For the output image, copy and paste the text in the Input image text box into the Output image text box, and append a b at the end. Generate image with non-brain matter removed should be checked. Generate image... overlaid on original should be unchecked. For this, you do not need any of the advanced options. Click OK. It will quickly (within a minute) generate a file like “anatb.nii”.
  * Type fsl & (case-sensitive) at the prompt. A little GUI will pop up. The ampersand runs fsl in the background, allowing you to do useful things like check the status of your processes.
  * Click on FEAT FMRI Analysis. A different GUI will pop up after a few seconds. You can close any excess GUIs that arise.

### Batching File Conversion
If you have several subjects to do, you can use bash and python scripts to do multiple subjects.  See [FSL First Level](fsl-first-level.md) for details!

### Adding Melodic

```bash
cd feat_output_directory.feat
melodic -i filtered_func_data --mix=../run1.ica/melodic_mix --filter="1,2,3,4,5,6,7,8,9,11,13,14"
```

where you should replace the comma-separated list of component numbers with the list that you previously recorded when viewing the MELODIC report. This only takes 1-2 minutes.
  * Now reopen the FEAT GUI and set the top-right menu to Stats + Post-stats.
  * Set the input data to be feat_output_directory.feat/filtered_func_data+.ica/melodic_ICAfiltered (The “+” is needed when you run ica as part of the first analyses, as suggested). By default the final FEAT output directory will be inside that second ICA output directory.
