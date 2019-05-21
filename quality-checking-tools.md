# Quality Checking Tools

## General

 - [Quality Analysis](quality-analysis.md):  Use the QA tool to check raw functional or anatomical data for excessive motion, SNR, etc before any processing 
 - [Coverage Checking](coverage-checking.md): Check coverage of individual subject data before setting up a group analysis 

## FSL Specific

 - [Melodic QA](melodic-dual-regression.md) See melodic_qa for checking motion and rotation from MELODIC based on benchmarks 
 - [First Level FEAT Quality Check](first-level-feat-quality-check.md) 
 - [Group FEAT Quality Checking ](group-level-feat-quality-check.md) 
 - [Checking BET](checking-bet.md) 
 - [Dicom to Nifti Checks](dicom-to-nifti-checks.md) 

## SPM Specific
 - [SPM Quality Checks](spm-quality-checks.md) Before any fMRI data can be used beyond single subject processing, Quality Analysis needs to be conducted, which includes Checking BIAC QA and visually inspecting the data. 
 - [Fixing Timing Errors](fixing-timing-errors.md) Instructions for manually re-doing the single subject analysis for a run that has errored timing AFTER the entire processing
pipeline has been completed.  In this case, we are fixing Cards. 
