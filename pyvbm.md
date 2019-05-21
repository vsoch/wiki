# pyVBM - Voxel Based Morphometry with FSL and Python

Voxel Based Morphometry is a dangerous analysis in that it is very sensitive to processing parameters and method.  I have created a [python script called pyVBM](https://github.com/vsoch/vbmis.com/blob/master/projects/pyVBM/pyVBM.py) (that can be modified with custom parameters) with the mindset that I will likely want to derive my own VBM results at some point, and want a transparent, customize-able way to do so, as opposed to the black box of [FSLs method](http://www.fmrib.ox.ac.uk/fsl/fslvbm/index.html).  Usage is as follows:

```
pyVBM: Python Script for Voxel Based Morphometry
 
 This python script performs voxel based morphometry on raw anatomatical data with fsl.  It checks for all 
 inputs, creates a template script and submits it for each subject in a cluster environment, and creates
 and submits a second level processing script that waits for all single subject processing to complete.
 Since work is required to create a group template image and then register individual maps to this image,
 this second level processing script in turn creates and submits its own batch of scripts to the cluster.

Usage: python pyVBM.py -o /future/output/folder --input=input.txt --mat=/path/design.mat --con=/path/design.con
 
Options:
  -h, --help             show this help  
  -o, --output           vbm output folder, not yet created
  --input                two column file with subject ID,raw anatomical file path
  --con                  design.con for randomise
  --mat                  design.mat file for randomise (make with FSL GLM)

```

The cool thing about this particular script is that it writes it's own custom templates and sets up its own output directory hierarchy.

  - **Setup:** In user specified output directory, it creates the following subdirectories:
    * /bet   --- temp folder for copying anatomical raw data & performing brain extractions, will be deleted
    * /struc --- for single subject preprocessed structural data 
    * /log   --- log folder for output and error files
    * /tmp   --- temp folder for script templates
    * /stats --- for statistical output, the "results" folder
  - **Read Input**: It then reads the input file, and checks for the existence of all data.  The input file (myanats.txt) should have two columns, separated by a comma, with a subject ID and path to the raw anatomical data, such as:

```
11111,/path/to/anat.nii.gz
22222,/path/to/anat.nii.gz
33333,/path/to/anat.nii.gz
```

  - **Single Subject Preprocess**: The script now prints a custom template to do preprocessing under tmp/vbmpre.sh and submits one job per subject.  The script uses the bsub command, which is specific to the cluster at Stanford, so edit this command to fit the needs of your environment.  See [[pyvbm#PROCESSING STEPS|PROCESSING STEPS]] below for further details about preprocessing]]
  - **Group Processing:** Concurrently, a group processing template is produced, which will wait patiently to start until it sees all completed single subject structural data in the struct folder.  The main submission script again produces a template script, /tmp/vbmpro.sh, to produce a group gray matter template... see [[pyvbm#GROUP STEPS|GROUP STEPS]] for details]].  This template bash script (vbmpro.sh), embedded within it, has code to create another script template /tmp/vbmpross.sh, which it then submits for each subject to complete registration of the individual subject gray matter image to the newly created template.  It lastly performs the three statistical analysis using randomise [[http://www.fmrib.ox.ac.uk/fsl/fslvbm/index.html|suggested by fsl]], see [[pyvbm#STATISTICS|STATISTICS]] for details]].

### PROCESSING STEPS

  - Give script an output folder, contrast and design matrix, and an input file with subject IDs and paths to anatomical data
  - Checks for files and paths
  - Submits each single subject for preprocessing:
    * bet brain extraction .225 with skull cleanup

```bash
bet $OUTPUT/bet/${SUBID}_mprage $OUTPUT/bet/${SUBID}_mprage_bet -S -f 0.225
```
    * Mask the new BET image (but do not reduce FOV) on the basis of the standard space image that is transformed into the BET space
```bash
standard_space_roi $OUTPUT/bet/${SUBID}_mprage_bet $OUTPUT/bet/${SUBID}_cut -roiNONE -ssref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -altinput $OUTPUT/bet/${SUBID}_mprage_bet
```

    * Perform bet again on the standard registered cut image to get the final output
```bash
bet $OUTPUT/bet/${SUBID}_cut $OUTPUT/bet/${SUBID}_brain -f 0.225
```

    * Segmentation with FAST (segments a 3D image of the brain into different tissue types (Grey Matter, White Matter, CSF, etc.), whilst also correcting for spatial intensity variations (also known as bias field or RF inhomogeneities))

```bash
fast -R 0.3 -H 0.1 $OUTPUT/bet/${SUBID}_brain
R is spatial smoothing for mixel tyoe
H is spatial smoothing for segmentation
```

    * Register parameter estimation of GM to grey matter standard template (avg152T1_gray) 

```bash
fsl_reg $OUTPUT/bet/${SUBID}_GM $GPRIORS $OUTPUT/bet/${SUBID}_GM_to_T -a
```

### GROUP STEPS
    * Wait until all single sub registrations complete! Then combine single subject templates into group gray matter template with affine registration

```bash
fslmerge -t template_4D_GM `ls *_GM_to_T.nii.gz`
fslmaths template_4D_GM -Tmean template_GM
fslswapdim template_GM -x y z template_GM_flipped
fslmaths template_GM -add template_GM_flipped -div 2 template_GM_init
```

    * Use fsl_reg with fnirt to register each single subject GM template to group GM template and standard space

```bash
for (( i = 0; i < ${#subids[*]}; i++ )); do
fsl_reg ${subids[i]}_GM template_GM_init ${subids[i]}_GM_to_T_init -a -fnirt "--config=GM_2_MNI152GM_2mm.cnf"
done
```

    * Take these single subject templates, now registered to standard space, and create a "second pass" group GM template

```bash
fslmerge -t template_4D_GM `ls *_GM_to_T_init.nii.gz`
fslmaths template_4D_GM -Tmean template_GM
fslswapdim template_GM -x y z template_GM_flipped
fslmaths template_GM -add template_GM_flipped -div 2 template_GM_final
```

    * Then when we have final template, submit each individual subject for second level processing.  Register individual GM to group GM template final, jout is file for "Jacobian of field" for VBM

```bash
fsl_reg $OUTPUT/struc/${SUBID}_GM $OUTPUT/struc/template_GM_final $OUTPUT/struc/${SUBID}_GM_to_template_GM -fnirt "--config=GM_2_MNI152GM_2mm.cnf --jout=$OUTPUT/struc/${SUBID}_JAC_nl"
```

    * Take registered individual GM image and multiply by jacobian of field image (?)...

```bash
fslmaths $OUTPUT/struc/${SUBID}_GM_to_template_GM -mul $OUTPUT/struc/${SUBID}_JAC_nl $OUTPUT/struc/${SUBID}_GM_to_template_GM_mod -odt float
```

    * Wait for all single subject "round 2" to finish, and then merge both sets together...

```bash
fslmerge -t GM_merg `imglob ../struc/*_GM_to_template_GM.nii.gz`
fslmerge -t GM_mod_merg `imglob ../struc/*_GM_to_template_GM_mod.nii.gz`
```

    * Threshold the image at 0.01 and use GM_mask as a binary mask

```bash
fslmaths GM_merg -Tmean -thr 0.01 -bin GM_mask -odt char
```

### STATISTICS

    * Use fslmaths to integrate design matrix, contrast files, and then run randomise.

```bash
fslmaths $i -s $j ${i}_s${j}
randomise -i ${i}_s${j} -o ${i}_s${j} -m GM_mask -d $OUTPUT/tmp/design.mat -t $OUTPUT/tmp/design.con -V
for i in GM_mod_merg ; do
for j in 2 3 4 ; do
randomise -i ${i}_s${j} -o zstat_${i}_s${j} -m GM_mask -d $OUTPUT/tmp/design.mat -t $OUTPUT/tmp/design.con -n 5000 -T -V
done
done
```

Example of additional command you can do to threshold the corrp images (corrected p value maps) at 0.95 to keep significant clusters and use it to mask corresponding tstats map:

```bash
fslmaths zstat_GM_mod_merg_s3_tfce_corrp_tstat1.nii.gz -thr 0.95 -bin mask_pcorrected3
fsl4.1-fslmaths zstat_GM_mod_merg_s3_tstat1.nii.gz -mas mask_pcorrected3.nii.gz fslvbms3_tstat1_corrected
fslview /usr/share/fsl/4.1/data/standard/MNI152_T1_2mm fslvbms3_tstat1_corrected.nii.gz -l Red-Yellow -b 2.3,4
```

Also can do:
```bash
fsl4.1-randomise -i GM_mod_merg_s3.nii -m GM_mask -o fslvbm -d design.mat -t design.con -c 2.3 -n 5000 -V
```
