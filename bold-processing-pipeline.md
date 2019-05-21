# Bold Processing Pipeline

 - [SPM Cluster Processing](spm-cluster-processing.md)

## Manual Processing

 - [SPM Preprocessing](spm-processing.md)
 - [SPM Batching](spm-batching.md) 
 - [SPM First Level Analysis](spm-first-level-analysis.md) 
 - [Coverage Checking](coverage-checking.md) For any group analysis, the voxels included in the group analysis are the ones that we have signal at for EVERY SUBJECT.  So, if we have one subject with signal loss, this means we will lose that voxel in the group analysis.  We need to be able to identify these subjects that are decreasing the size of the group mask!  Originally, individual registrations had to be checked against an ROI mask in [xjView](xjview.md), but now we can run a simple script to check coverage for all subjects.

 - [SPM Quality Checks](spm-quality-checks.md)
Before any fMRI data can be used beyond single subject processing, Quality Analysis needs to be conducted, which includes Checking BIAC QA and visually inspecting the data.

 - [Fixing Timing Errors](fixing-timing-errors.md)
Instructions for manually re-doing the single subject analysis for a run that has errored timing AFTER the entire processing
pipeline has been completed.  In this case, we are fixing Cards.
