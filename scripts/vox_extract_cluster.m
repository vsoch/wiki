% This script was written by Patrick Fisher, University of Pittsburgh,
% modified for use on the BIAC cluster by Vanessa Sochat, Duke University.
% April 12, 2010

%So you want to extract a time series of values from a set of voxels across
%a whole rack of people?  Below is an example of how to achieve this in a
%manner that is hopefully repeatable when different sets of voxels want to 
%be considered.  First we need to answer two questions:

%1) From which voxels do I want to extract data?
%2) From which images do I want to extract data?

%Answering the first question is necessary so we can set the value of all
%non-interesting voxels to zero.  For this example, we are going to say, "I
%want to extract data from 'gray-matter voxels' only."  That's great, but
%then next we have to define what is a gray-matter voxel.  Within the
%../spm8/apriori folder there is a file grey.nii (silly British and their 
%use of an 'e').  This image is a probability map where the value at any 
%voxel reflects the probability that voxel is gray-matter.  For our 
%purposes we can choose a minimum probability threshold (0.12, for example)
%then designate every voxel with a gray-matter probability greater than
%0.12 as 'gray-matter'.  Perfect!  A problem arises when considering the 
%image and voxel dimensions.  We need those of our mask image (grey.nii) to 
%match those of our images from which we want to extract activity values 
%(smoothed image files).

%Though the voxel dimensions of the grey.nii image match those of our
%smoothed image files (2x2x2 mm), the image dimensions are different
%(smoothed image files: 79x95x68; grey.nii file: 91x109x91).  We can use a
%feature of SPM and WFU PickAtlas to get our mask image (grey.nii) into the
%same space as our smoothed image files.  If you have the Pickatlas
%installed, when you examine results of any design matrix you can choose to
%mask your analyses with a 'Saved File'.  A resampled image of whatever 
%mask file you choose (e.g., mask.img) is generated and preceded by an 
%'r' (e.g., rmask.img).  This rmask.img file has the same image and voxel
%dimensions as those of the images that are within the design matrix.  This
%rmask.img will be overwritten any time mask.img is used as a mask when
%examining results from a design matrix containing images with a different
%dimension.  This is not a problem for our functional analyses since all
%our functional imaging data are the same size and dimensions.  You can
%imagine how under different circumstances this can create problems, so be
%aware!

%In the case of our example we can use this approach to generate an
%rgrey.nii image file that we can use to identify the particular voxels
%(those where rgrey.nii > 0.12) as 'gray-matter' and save out their time
%series, setting the values for all of other voxels to zero.  Below is a
%set of commands that carries out all the steps following the creation of
%this rgrey.nii file or any other mask image to be used.  

%A variabile called voxvalues.mat is saved into each single subject folder 
%that contains that subjects smoothed image files.  This voxvalues.mat file
%includes the voxel values for each smoothed image file for that subject as
%well as additional information including the mask image used and names of
%smoothed image files from which time series are drawn.

% Add necessary paths
BIACroot = 'SUB_BIACROOT_SUB';

startm=fullfile(BIACroot,'startup.m');
if exist(startm,'file')
  run(startm);
else
  warning(sprintf(['Unable to locate central BIAC startup.m file\n  (%s).\n' ...
      '  Connect to network or set BIACMATLABROOT environment variable.\n'],startm));
end
clear startm BIACroot
addpath(genpath('SUB_SCRIPTDIR_SUB'));
addpath(genpath('/usr/local/packages/MATLAB/spm8'));
addpath(genpath('/usr/local/packages/MATLAB/NIFTI'));
addpath(genpath('/usr/local/packages/MATLAB/fslroi'));

%Go to the folder with all the subject's images
cd SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/SUB_TASK_SUB/

%Select all smoothed images from which we want to draw time series
    
    for j = 1:SUB_NUMIMAGES_SUB
        if j < 10
            imgs(j,:) = horzcat('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/SUB_TASK_SUB/swuV000',num2str(j),'.img');
        end
        if j >=10
            if j < 100
                imgs(j,:) = horzcat('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/SUB_TASK_SUB/swuV00',num2str(j),'.img');
            end
        end
        if j >=100
            imgs(j,:) = horzcat('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/SUB_TASK_SUB/swuV0',num2str(j),'.img');
        end
    end


%Select mask image to be used to determine what subset of voxels from which
%you will draw time series data.
mask = 'SUB_MOUNT_SUB/Analysis/SPM/ROI/SUB_MASKTYPE_SUB/SUB_MASKNAME_SUB';

if strcmp('SUB_MASKTWO_SUB','yes')
    mask2 = 'SUB_MOUNT_SUB/Analysis/SPM/ROI/SUB_MASKTWOTYPE_SUB/SUB_MASKTWONAME_SUB';
end
    
%If there is a second mask, set the minimum threshold
if strcmp('SUB_MASKTWO_SUB','yes')
    if isempty(mask2)==0
        min_thresh2 = SUB_MINTHRESHTWO_SUB;
    end
end


%min_thresh will be used to exclude certain voxels from which to draw time
%series.  If a binary mask image is used, this parameter should be set to
%1.
min_thresh = SUB_MINTHRESH_SUB;

%Input the number of image files per subject that are included.
subj_imgs = SUB_NUMIMAGES_SUB;

%Loads voxel values for the mask image into the workspace.
mask_hdr = spm_vol(mask);
mask_V = spm_read_vols(mask_hdr);

%Load second mask only if there is one.
if strcmp('SUB_MASKTWO_SUB','yes')
    if isempty(mask2)==0
        mask2_hdr = spm_vol(mask2);
        mask2_V = spm_read_vols(mask2_hdr);
    end
end

num_imgs = size(imgs,1);
%Determines how many subjects' smoothed image files were selected.
% NOTE: Since this is being used on the cluster, this will always be 195.

%Selecting an inconsitent number of smoothed image files for each subject
%will have adverse consequences for this script.  If I knew an easy way to 
%tell Matlab to quit should num_subj not be whole, I would do that.  Be
%certain you've entered the same number of smoothed image files for each
%single subject. (Note from Patrick)
num_subj = 1;
%This was changed to be one since we will always be processing one at a
%time on the cluster.  When running on the local machine, it ran out of
%memory with greater than one subject. (Vanessa)


%Determine which for loop to run based on if we have one or two masks
if strcmp('SUB_MASKTWO_SUB','no')
    if exist('mask2','var')==0
        for i = 1:num_subj
            cd 'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/SUB_TASK_SUB/'
            clear imgs_hdr imgs_vox
            %Loads header information for all image files for a single subject.
            imgs_hdr = spm_vol(imgs((subj_imgs*(i-1))+1:subj_imgs*i,:));
            %Loads voxel values for all image files for a single subject.
            imgs_vox = spm_read_vols(imgs_hdr);
    
            %Identifies voxels whose time series is to be excluded
            for j = 1:size(imgs_vox,1)
             for k = 1:size(imgs_vox,2)
                    for m = 1:size(imgs_vox,3)
                        if mask_V(j,k,m) < min_thresh
                            imgs_vox(j,k,m,:) = 0;
                        end
                    end
                end
            end
            voxvalues = {};
            voxvalues.imgs = {};
            voxvalues.mask = {};
            voxvalues.imgs.vox = imgs_vox;
            for n = 1:subj_imgs
                voxvalues.imgs.name(n,:) = imgs_hdr(n,:).fname;
            end
            voxvalues.mask.name = mask;
            voxvalues.mask.dim = size(mask_V);
            voxvalues.mask.minthresh = min_thresh;
            save voxvalues voxvalues
        end
    end
end

if strcmp('SUB_MASKTWO_SUB','yes')
    if isempty(mask2)==0
 
        for i = 1:num_subj
        cd 'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/SUB_TASK_SUB/'
        clear imgs_hdr imgs_vox
        %Loads header information for all image files for a single subject.
        imgs_hdr = spm_vol(imgs((subj_imgs*(i-1))+1:subj_imgs*i,:));
        %Loads voxel values for all image files for a single subject.
        imgs_vox = spm_read_vols(imgs_hdr);

        %Identifies voxels whose time series is to be excluded
        for j = 1:size(imgs_vox,1)
            for k = 1:size(imgs_vox,2)
                for m = 1:size(imgs_vox,3)
                    if or(mask_V(j,k,m) < min_thresh,mask2_V(j,k,m) < min_thresh2)
                        imgs_vox(j,k,m,:) = 0;
                    end
                end
            end
        end
        voxvalues = {};
        voxvalues.imgs = {};
        voxvalues.mask = {};
        voxvalues.imgs.vox = imgs_vox;
        voxvalues.imgs.nonzero=zeros(subj_imgs,1);
        for n = 1:subj_imgs
            voxvalues.imgs.name(n,:) = imgs_hdr(n,:).fname;
            voxvalues.imgs.nonzero(n,1)=sum(sum(sum(voxvalues.imgs.vox(:,:,:,n)>0)));
        end
        voxvalues.mask.name = mask;
        voxvalues.mask.dim = size(mask_V);
        voxvalues.mask.minthresh = min_thresh;
        save voxvalues voxvalues
        end
    end
end