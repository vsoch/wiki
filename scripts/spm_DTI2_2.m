%-----------------------------------------------------------------------
% SPM DTI - includes spm_DTI_1.m, and spm_DTI_2.m
%
% These template scripts are filled in and run by a bash script,
% spm_DTI_TEMPLATE.sh from the head node of BIAC
%
%    The Laboratory of Neurogenetics, 2010
%       By Vanessa Sochat, Duke University
%       Original batch file by Fredrik Ahs, Duke University
%
% B-values and directions have to be set. Then, realign and reslice 
% DW-images (the realign-function from Diffusion toolbox does not reslice). 
% Header information has to be changed, then the tensors (order 2) can 
% be computed. The tensors are decomposed into three eigenvectors 
% with corresponding eigenvalues. The eigenvalues are used to compute 
% fractional anisotropy using spm_imcalc. For normalization, it is 
% important to create an accurate brain-mask which can be done by 
% adding GM, WM and CSF (c1, c2 and c3) computed by newSegment. The 
% FA-image is masked using spm_imcalc  and the masked FA-image is 
% normalized to the FMRIB58 template using affine transformation.
%-----------------------------------------------------------------------

% Add necessary paths
BIACroot = 'SUB_BIACROOT_SUB';

startm=fullfile(BIACroot,'startup.m');
if exist(startm,'file')
  run(startm);
else
  warning(sprintf(['Unable to locate central BIAC startup.m file/n  (%s)./n' ...
      '  Connect to network or set BIACMATLABROOT environment variable./n'],startm));
end
clear startm BIACroot
addpath(genpath('SUB_SCRIPTDIR_SUB'));
addpath(genpath('/usr/local/packages/MATLAB/spm8'));
addpath(genpath('/usr/local/packages/MATLAB/NIFTI'));
addpath(genpath('/usr/local/packages/MATLAB/fslroi'));
addpath(genpath('SUB_MOUNT_SUB/Data/Anat/SUB_SUBJECT_SUB'));
addpath(genpath('SUB_MOUNT_SUB/Data/Func/SUB_SUBJECT_SUB'));
addpath(genpath('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB'));

%Here we set some directory variables to make navigation easier
homedir='SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/';

% We inititlize the SPM jobman
spm('defaults','fmri')
spm_jobman('initcfg');

%-----------------------------------------------------------------------
% Preprocessing DTI Data
%-----------------------------------------------------------------------

if strcmp('SUB_TWORUNS_SUB','yes')
cd SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/;

% if we have two runs, we need to import double the images

%-----------------------------------------------------------------------
% Step 1: Set information: Diffusion Toolbox (enter bvalues, raw images, and
% gradient directions)
%-----------------------------------------------------------------------
%%
matlabbatch{1}.spm.tools.vgtbx_Diffusion.dti_init_dtidata.srcimgs = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000069-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000137-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000205-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000273-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000341-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000409-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000477-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000545-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000613-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000681-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000749-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000817-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000885-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000953-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-001021-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000001-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000069-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000137-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000205-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000273-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000341-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000409-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000477-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000545-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000613-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000681-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000749-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000817-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000885-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000953-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-001021-01.img,1'};
%%
%%
matlabbatch{1}.spm.tools.vgtbx_Diffusion.dti_init_dtidata.initopts.resetall.b = [0
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 0
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000];
%%
%%
matlabbatch{1}.spm.tools.vgtbx_Diffusion.dti_init_dtidata.initopts.resetall.g = [0 0 0
                                                                                 1 0 0
                                                                                 0.643 0.766 0
                                                                                 0.258 0.307 0.916
                                                                                 0.745 -0.594 0.303
                                                                                 0.164 -0.507 0.846
                                                                                 -0.796 -0.321 0.513
                                                                                 0.761 0.427 0.489
                                                                                 -0.506 0.833 0.224
                                                                                 0.667 -0.158 0.728
                                                                                 0.128 -0.959 0.254
                                                                                 -0.178 -0.898 -0.403
                                                                                 0.255 -0.59 -0.767
                                                                                 -0.34 -0.736 0.585
                                                                                 -0.801 0.329 0.501
                                                                                 0.336 0.043 -0.941
                                                                                 0 0 0
                                                                                 1 0 0
                                                                                 0.643 0.766 0
                                                                                 0.258 0.307 0.916
                                                                                 0.745 -0.594 0.303
                                                                                 0.164 -0.507 0.846
                                                                                 -0.796 -0.321 0.513
                                                                                 0.761 0.427 0.489
                                                                                 -0.506 0.833 0.224
                                                                                 0.667 -0.158 0.728
                                                                                 0.128 -0.959 0.254
                                                                                 -0.178 -0.898 -0.403
                                                                                 0.255 -0.59 -0.767
                                                                                 -0.34 -0.736 0.585
                                                                                 -0.801 0.329 0.501
                                                                                 0.336 0.043 -0.941];
%%                                                                             
matlabbatch{1}.spm.tools.vgtbx_Diffusion.dti_init_dtidata.initopts.resetall.M = 1;
%%
%-----------------------------------------------------------------------
% Step 2: Diffusion Toolbox: Realign.  
% Enter the DW images
%-----------------------------------------------------------------------
%%
matlabbatch{2}.spm.tools.vgtbx_Diffusion.dti_realign.srcimgs = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000069-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000137-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000205-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000273-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000341-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000409-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000477-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000545-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000613-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000681-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000749-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000817-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000885-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000953-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-001021-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000001-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000069-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000137-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000205-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000273-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000341-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000409-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000477-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000545-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000613-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000681-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000749-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000817-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000885-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000953-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-001021-01.img,1'};
%%
matlabbatch{2}.spm.tools.vgtbx_Diffusion.dti_realign.b0corr = 1;
matlabbatch{2}.spm.tools.vgtbx_Diffusion.dti_realign.b1corr = 3;
%%
%-----------------------------------------------------------------------
% Step 3: Reslice (spm8): Enter the DW images
%-----------------------------------------------------------------------
%%
matlabbatch{3}.spm.spatial.realign.write.data = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/meansdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000069-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000137-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000205-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000273-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000341-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000409-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000477-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000545-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000613-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000681-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000749-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000817-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000885-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000953-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-001021-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000001-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000069-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000137-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000205-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000273-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000341-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000409-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000477-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000545-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000613-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000681-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000749-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000817-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000885-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000953-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-001021-01.img,1'};
%%
%%
matlabbatch{3}.spm.spatial.realign.write.roptions.which = [2 1];
matlabbatch{3}.spm.spatial.realign.write.roptions.interp = 4;
matlabbatch{3}.spm.spatial.realign.write.roptions.wrap = [0 0 0];
matlabbatch{3}.spm.spatial.realign.write.roptions.mask = 1;
matlabbatch{3}.spm.spatial.realign.write.roptions.prefix = 'r';
%%
%-----------------------------------------------------------------------
% Step 4: Change information (Diffusion Toolbox): First enter the 16
% DW, then the resliced rDW
%-----------------------------------------------------------------------
%%
matlabbatch{4}.spm.tools.vgtbx_Diffusion.dti_reorient_gradient.srcimgs = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000069-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000137-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000205-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000273-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000341-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000409-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000477-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000545-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000613-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000681-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000749-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000817-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000885-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000953-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-001021-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000001-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000069-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000137-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000205-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000273-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000341-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000409-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000477-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000545-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000613-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000681-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000749-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000817-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000885-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-000953-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER2PRE_SUB-00001-001021-01.img,1'};
%%
%%
matlabbatch{4}.spm.tools.vgtbx_Diffusion.dti_reorient_gradient.tgtimgs = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000069-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000137-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000205-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000273-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000341-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000409-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000477-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000545-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000613-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000681-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000749-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000817-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000885-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000953-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-001021-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000001-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000069-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000137-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000205-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000273-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000341-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000409-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000477-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000545-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000613-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000681-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000749-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000817-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000885-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000953-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-001021-01.img,1'};
%%
%%
matlabbatch{4}.spm.tools.vgtbx_Diffusion.dti_reorient_gradient.snparams = '';
matlabbatch{4}.spm.tools.vgtbx_Diffusion.dti_reorient_gradient.useaff.rot = 1;
matlabbatch{4}.spm.tools.vgtbx_Diffusion.dti_reorient_gradient.useaff.zoom = 0;
matlabbatch{4}.spm.tools.vgtbx_Diffusion.dti_reorient_gradient.useaff.shear = 0;
%%
%-----------------------------------------------------------------------
% Step 5: Tensor Regression (Diffusion Toolbox): enter the 16
% resliced rDW and the output directory
%-----------------------------------------------------------------------
%%
matlabbatch{5}.spm.tools.vgtbx_Diffusion.dti_dt_regress.srcimgs = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000069-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000137-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000205-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000273-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000341-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000409-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000477-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000545-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000613-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000681-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000749-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000817-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000885-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000953-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-001021-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000001-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000069-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000137-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000205-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000273-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000341-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000409-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000477-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000545-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000613-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000681-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000749-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000817-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000885-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-000953-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER2PRE_SUB-00001-001021-01.img,1'};
%%
%%
matlabbatch{5}.spm.tools.vgtbx_Diffusion.dti_dt_regress.errorvar.erriid = 1;
matlabbatch{5}.spm.tools.vgtbx_Diffusion.dti_dt_regress.dtorder = 2;
matlabbatch{5}.spm.tools.vgtbx_Diffusion.dti_dt_regress.maskimg = {''};
matlabbatch{5}.spm.tools.vgtbx_Diffusion.dti_dt_regress.swd = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/'};
matlabbatch{5}.spm.tools.vgtbx_Diffusion.dti_dt_regress.spatsm = 0;

%-----------------------------------------------------------------------
% Step 6: Tensor Decomposition (Diffusion Toolbox): enter the 6 tensor
% images starting with DX
%-----------------------------------------------------------------------

matlabbatch{6}.spm.tools.vgtbx_Diffusion.dti_eig.dtimg = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/Dxx_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                          'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/Dxy_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                          'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/Dxz_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                          'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/Dyy_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                          'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/Dyz_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                          'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/Dzz_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'};
matlabbatch{6}.spm.tools.vgtbx_Diffusion.dti_eig.dteigopts = 'vl';

%-----------------------------------------------------------------------
% Step 7: ComputeFA (Imcalc SPM8)- Enter 3 eval images and the output 
% directory.  The output image will be named FA.img
%-----------------------------------------------------------------------

matlabbatch{7}.spm.util.imcalc.input = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/eval1_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                        'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/eval2_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                        'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/eval3_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'};
matlabbatch{7}.spm.util.imcalc.output = 'FA.img';
matlabbatch{7}.spm.util.imcalc.outdir = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/'};
matlabbatch{7}.spm.util.imcalc.expression = 'sqrt(0.5)*sqrt((i1-i2).^2+(i1-i3).^2+(i2-i3).^2)./sqrt(i1.^2+i2.^2+i3.^2)';
matlabbatch{7}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{7}.spm.util.imcalc.options.mask = 0;
matlabbatch{7}.spm.util.imcalc.options.interp = 1;
matlabbatch{7}.spm.util.imcalc.options.dtype = 4;

%-----------------------------------------------------------------------
% Step 8: Segment FAimage (NewSegment, SPM8): Enter FA.img
%-----------------------------------------------------------------------

matlabbatch{8}.spm.tools.preproc8.channel.vols = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/FA.img,1'};
matlabbatch{8}.spm.tools.preproc8.channel.biasreg = 0.0001;
matlabbatch{8}.spm.tools.preproc8.channel.biasfwhm = 60;
matlabbatch{8}.spm.tools.preproc8.channel.write = [0 0];
matlabbatch{8}.spm.tools.preproc8.tissue(1).tpm = {'/usr/local/packages/MATLAB/spm8/toolbox/Seg/TPM.nii,1'};
matlabbatch{8}.spm.tools.preproc8.tissue(1).ngaus = 2;
matlabbatch{8}.spm.tools.preproc8.tissue(1).native = [1 0];
matlabbatch{8}.spm.tools.preproc8.tissue(1).warped = [0 0];
matlabbatch{8}.spm.tools.preproc8.tissue(2).tpm = {'/usr/local/packages/MATLAB/spm8/toolbox/Seg/TPM.nii,2'};
matlabbatch{8}.spm.tools.preproc8.tissue(2).ngaus = 2;
matlabbatch{8}.spm.tools.preproc8.tissue(2).native = [1 0];
matlabbatch{8}.spm.tools.preproc8.tissue(2).warped = [0 0];
matlabbatch{8}.spm.tools.preproc8.tissue(3).tpm = {'/usr/local/packages/MATLAB/spm8/toolbox/Seg/TPM.nii,3'};
matlabbatch{8}.spm.tools.preproc8.tissue(3).ngaus = 2;
matlabbatch{8}.spm.tools.preproc8.tissue(3).native = [1 0];
matlabbatch{8}.spm.tools.preproc8.tissue(3).warped = [0 0];
matlabbatch{8}.spm.tools.preproc8.tissue(4).tpm = {'/usr/local/packages/MATLAB/spm8/toolbox/Seg/TPM.nii,4'};
matlabbatch{8}.spm.tools.preproc8.tissue(4).ngaus = 3;
matlabbatch{8}.spm.tools.preproc8.tissue(4).native = [1 0];
matlabbatch{8}.spm.tools.preproc8.tissue(4).warped = [0 0];
matlabbatch{8}.spm.tools.preproc8.tissue(5).tpm = {'/usr/local/packages/MATLAB/spm8/toolbox/Seg/TPM.nii,5'};
matlabbatch{8}.spm.tools.preproc8.tissue(5).ngaus = 4;
matlabbatch{8}.spm.tools.preproc8.tissue(5).native = [1 0];
matlabbatch{8}.spm.tools.preproc8.tissue(5).warped = [0 0];
matlabbatch{8}.spm.tools.preproc8.tissue(6).tpm = {'/usr/local/packages/MATLAB/spm8/toolbox/Seg/TPM.nii,6'};
matlabbatch{8}.spm.tools.preproc8.tissue(6).ngaus = 2;
matlabbatch{8}.spm.tools.preproc8.tissue(6).native = [0 0];
matlabbatch{8}.spm.tools.preproc8.tissue(6).warped = [0 0];
matlabbatch{8}.spm.tools.preproc8.warp.reg = 4;
matlabbatch{8}.spm.tools.preproc8.warp.affreg = 'mni';
matlabbatch{8}.spm.tools.preproc8.warp.samp = 3;
matlabbatch{8}.spm.tools.preproc8.warp.write = [0 0];

%-----------------------------------------------------------------------
% Step 9: Create Brain mask (Imcalc SPM8): Enter c1, c2 and c3 +
% output directory, image out=FAmask.img.  c4 and c5 are non-brain
% matter, so we don't use them.
%-----------------------------------------------------------------------

matlabbatch{9}.spm.util.imcalc.input = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/c1FA.nii,1'
                                        'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/c2FA.nii,1'
                                        'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/c3FA.nii,1'};
matlabbatch{9}.spm.util.imcalc.output = 'FAmask.img';
matlabbatch{9}.spm.util.imcalc.outdir = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/'};
matlabbatch{9}.spm.util.imcalc.expression = '(i1+i2+i3)>0.5';
matlabbatch{9}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{9}.spm.util.imcalc.options.mask = 0;
matlabbatch{9}.spm.util.imcalc.options.interp = 1;
matlabbatch{9}.spm.util.imcalc.options.dtype = 4;

%-----------------------------------------------------------------------
% Step 10: Crop brain (Imcalc SPM8): Enter FA.img and FAmask.img and
% the output directory, image out=FAmasked.img
%-----------------------------------------------------------------------

matlabbatch{10}.spm.util.imcalc.input = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/FA.img,1'
                                         'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/FAmask.img,1'};
matlabbatch{10}.spm.util.imcalc.output = 'FAmasked.img';
matlabbatch{10}.spm.util.imcalc.outdir = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/'};
matlabbatch{10}.spm.util.imcalc.expression = 'i1.*i2';
matlabbatch{10}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{10}.spm.util.imcalc.options.mask = 0;
matlabbatch{10}.spm.util.imcalc.options.interp = 1;
matlabbatch{10}.spm.util.imcalc.options.dtype = 4;

%-----------------------------------------------------------------------
% Step 11: Perform saved Deformations
%-----------------------------------------------------------------------

%matlabbatch{11}.spm.util.defs.comp{1}.def = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/y_FA.nii'};
%matlabbatch{11}.spm.util.defs.ofname = 'FA_deformed';
%matlabbatch{11}.spm.util.defs.fnames(1) = cfg_dep;
%matlabbatch{11}.spm.util.defs.fnames(1).tname = 'Apply to';
%matlabbatch{11}.spm.util.defs.fnames(1).tgt_spec{1}(1).name = 'filter';
%matlabbatch{11}.spm.util.defs.fnames(1).tgt_spec{1}(1).value = 'image';
%matlabbatch{11}.spm.util.defs.fnames(1).tgt_spec{1}(2).name = 'strtype';
%matlabbatch{11}.spm.util.defs.fnames(1).tgt_spec{1}(2).value = 'e';
%matlabbatch{11}.spm.util.defs.fnames(1).sname = 'Image Calculator: Imcalc Computed Image: FAmasked.img';
%matlabbatch{11}.spm.util.defs.fnames(1).src_exbranch = substruct('.','val', '{}',{10}, '.','val', '{}',{1}, '.','val', '{}',{1});
%matlabbatch{11}.spm.util.defs.fnames(1).src_output = substruct('.','files');
%matlabbatch{11}.spm.util.defs.savedir.savesrc = 1;
%matlabbatch{11}.spm.util.defs.interp = 1;

matlabbatch{11}.spm.spatial.normalise.estwrite.subj.source = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/FAmasked.img,1'};
matlabbatch{11}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
matlabbatch{11}.spm.spatial.normalise.estwrite.subj.resample = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/FAmasked.img,1'};
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.template = {'SUB_MOUNT_SUB/Analysis/DTI/ROI/FMRIB58_FA_1mmnii.nii,1'};
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.weight = '';
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
matlabbatch{11}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
matlabbatch{11}.spm.spatial.normalise.estwrite.roptions.bb = [-78 -112 -50
                                                              78 76 85];
matlabbatch{11}.spm.spatial.normalise.estwrite.roptions.vox = [2 2 2];
matlabbatch{11}.spm.spatial.normalise.estwrite.roptions.interp = 1;
matlabbatch{11}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
matlabbatch{11}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';

matlabbatch{12}.spm.spatial.smooth.data = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/wFAmasked.img,1'};
matlabbatch{12}.spm.spatial.smooth.fwhm = [4 4 4];
matlabbatch{12}.spm.spatial.smooth.dtype = 0;
matlabbatch{12}.spm.spatial.smooth.im = 0;
matlabbatch{12}.spm.spatial.smooth.prefix = 's';

%Execute the job to process the dti data
spm_jobman('run_nogui',matlabbatch)

clear matlabbatch
end


% Here is the processing batch if we are only analyzing one dataset
if strcmp('SUB_TWORUNS_SUB','no')
cd SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/;

%-----------------------------------------------------------------------
% Step 1: Set information: Diffusion Toolbox (enter bvalues, raw images, and
% gradient directions)
%-----------------------------------------------------------------------

% if we have one run, we only import 16 images
%%
matlabbatch{1}.spm.tools.vgtbx_Diffusion.dti_init_dtidata.srcimgs = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000069-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000137-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000205-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000273-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000341-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000409-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000477-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000545-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000613-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000681-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000749-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000817-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000885-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000953-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-001021-01.img,1'};          
%%
%%
matlabbatch{1}.spm.tools.vgtbx_Diffusion.dti_init_dtidata.initopts.resetall.b = [0
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000
                                                                                 1000];
%%
%%
matlabbatch{1}.spm.tools.vgtbx_Diffusion.dti_init_dtidata.initopts.resetall.g = [0 0 0
                                                                                 1 0 0
                                                                                 0.643 0.766 0
                                                                                 0.258 0.307 0.916
                                                                                 0.745 -0.594 0.303
                                                                                 0.164 -0.507 0.846
                                                                                 -0.796 -0.321 0.513
                                                                                 0.761 0.427 0.489
                                                                                 -0.506 0.833 0.224
                                                                                 0.667 -0.158 0.728
                                                                                 0.128 -0.959 0.254
                                                                                 -0.178 -0.898 -0.403
                                                                                 0.255 -0.59 -0.767
                                                                                 -0.34 -0.736 0.585
                                                                                 -0.801 0.329 0.501
                                                                                 0.336 0.043 -0.941];
%% 
%%
matlabbatch{1}.spm.tools.vgtbx_Diffusion.dti_init_dtidata.initopts.resetall.M = 1;
%%

%-----------------------------------------------------------------------
% Step 2: Diffusion Toolbox: Realign.  
% Enter the DW images
%-----------------------------------------------------------------------
%%
matlabbatch{2}.spm.tools.vgtbx_Diffusion.dti_realign.srcimgs = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000069-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000137-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000205-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000273-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000341-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000409-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000477-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000545-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000613-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000681-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000749-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000817-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000885-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000953-01.img,1'
                                                                'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-001021-01.img,1'};
%%
%%
matlabbatch{2}.spm.tools.vgtbx_Diffusion.dti_realign.b0corr = 0;
matlabbatch{2}.spm.tools.vgtbx_Diffusion.dti_realign.b1corr = 3;
%%

%-----------------------------------------------------------------------
% Step 3: Reslice (spm8): Enter the DW images
%-----------------------------------------------------------------------
%%
matlabbatch{3}.spm.spatial.realign.write.data = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/meansdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'   
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000069-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000137-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000205-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000273-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000341-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000409-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000477-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000545-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000613-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000681-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000749-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000817-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000885-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000953-01.img,1'
                                                 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-001021-01.img,1'};
%%
%%
matlabbatch{3}.spm.spatial.realign.write.roptions.which = [2 1];
matlabbatch{3}.spm.spatial.realign.write.roptions.interp = 4;
matlabbatch{3}.spm.spatial.realign.write.roptions.wrap = [0 0 0];
matlabbatch{3}.spm.spatial.realign.write.roptions.mask = 1;
matlabbatch{3}.spm.spatial.realign.write.roptions.prefix = 'r';
%%

%-----------------------------------------------------------------------
% Step 4: Change information (Diffusion Toolbox): First enter the 16
% DW, then the resliced rDW
%-----------------------------------------------------------------------
%%
matlabbatch{4}.spm.tools.vgtbx_Diffusion.dti_reorient_gradient.srcimgs = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000069-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000137-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000205-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000273-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000341-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000409-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000477-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000545-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000613-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000681-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000749-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000817-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000885-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-000953-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/sdns01-0SUB_FOLDER1PRE_SUB-00001-001021-01.img,1'};
%%
%%
matlabbatch{4}.spm.tools.vgtbx_Diffusion.dti_reorient_gradient.tgtimgs = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000069-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000137-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000205-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000273-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000341-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000409-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000477-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000545-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000613-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000681-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000749-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000817-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000885-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000953-01.img,1'
                                                                           'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-001021-01.img,1'};
%%
%%
matlabbatch{4}.spm.tools.vgtbx_Diffusion.dti_reorient_gradient.snparams = '';
matlabbatch{4}.spm.tools.vgtbx_Diffusion.dti_reorient_gradient.useaff.rot = 1;
matlabbatch{4}.spm.tools.vgtbx_Diffusion.dti_reorient_gradient.useaff.zoom = 0;
matlabbatch{4}.spm.tools.vgtbx_Diffusion.dti_reorient_gradient.useaff.shear = 0;
%%
%-----------------------------------------------------------------------
% Step 5: Tensor Regression (Diffusion Toolbox): enter the 16
% resliced rDW and the output directory
%-----------------------------------------------------------------------
%%
matlabbatch{5}.spm.tools.vgtbx_Diffusion.dti_dt_regress.srcimgs = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                                   'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000069-01.img,1'
                                                                   'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000137-01.img,1'
                                                                   'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000205-01.img,1'
                                                                   'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000273-01.img,1'
                                                                   'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000341-01.img,1'
                                                                   'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000409-01.img,1'
                                                                   'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000477-01.img,1'
                                                                   'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000545-01.img,1'
                                                                   'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000613-01.img,1'
                                                                   'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000681-01.img,1'
                                                                   'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000749-01.img,1'
                                                                   'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000817-01.img,1'
                                                                   'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000885-01.img,1'
                                                                   'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-000953-01.img,1'
                                                                   'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/rsdns01-0SUB_FOLDER1PRE_SUB-00001-001021-01.img,1'};
%%

matlabbatch{5}.spm.tools.vgtbx_Diffusion.dti_dt_regress.errorvar.erriid = 1;
matlabbatch{5}.spm.tools.vgtbx_Diffusion.dti_dt_regress.dtorder = 2;
matlabbatch{5}.spm.tools.vgtbx_Diffusion.dti_dt_regress.maskimg = {''};
matlabbatch{5}.spm.tools.vgtbx_Diffusion.dti_dt_regress.swd = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/'};
matlabbatch{5}.spm.tools.vgtbx_Diffusion.dti_dt_regress.spatsm = 0;


%-----------------------------------------------------------------------
% Step 6: Tensor Decomposition (Diffusion Toolbox): enter the 6 tensor
% images starting with DX
%-----------------------------------------------------------------------

matlabbatch{6}.spm.tools.vgtbx_Diffusion.dti_eig.dtimg = {
                                                          'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/Dxx_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                          'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/Dxy_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                          'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/Dxz_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                          'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/Dyy_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                          'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/Dyz_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                                          'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/Dzz_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'};
matlabbatch{6}.spm.tools.vgtbx_Diffusion.dti_eig.dteigopts = 'vl';

%-----------------------------------------------------------------------
% Step 7: ComputeFA (Imcalc SPM8)- Enter 3 eval images and the output 
% directory.  The output image will be named FA.img
%-----------------------------------------------------------------------

matlabbatch{7}.spm.util.imcalc.input = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/eval1_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                        'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/eval2_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'
                                        'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/eval3_rsdns01-0SUB_FOLDER1PRE_SUB-00001-000001-01.img,1'};
matlabbatch{7}.spm.util.imcalc.output = 'FA.img';
matlabbatch{7}.spm.util.imcalc.outdir = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/'};
matlabbatch{7}.spm.util.imcalc.expression = 'sqrt(0.5)*sqrt((i1-i2).^2+(i1-i3).^2+(i2-i3).^2)./sqrt(i1.^2+i2.^2+i3.^2)';
matlabbatch{7}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{7}.spm.util.imcalc.options.mask = 0;
matlabbatch{7}.spm.util.imcalc.options.interp = 1;
matlabbatch{7}.spm.util.imcalc.options.dtype = 4;


%-----------------------------------------------------------------------
% Step 8: Segment FAimage (NewSegment, SPM8): Enter FA.img
%-----------------------------------------------------------------------

matlabbatch{8}.spm.tools.preproc8.channel.vols = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/FA.img,1'};
matlabbatch{8}.spm.tools.preproc8.channel.biasreg = 0.0001;
matlabbatch{8}.spm.tools.preproc8.channel.biasfwhm = 60;
matlabbatch{8}.spm.tools.preproc8.channel.write = [0 0];
matlabbatch{8}.spm.tools.preproc8.tissue(1).tpm = {'/usr/local/packages/MATLAB/spm8/toolbox/Seg/TPM.nii,1'};
matlabbatch{8}.spm.tools.preproc8.tissue(1).ngaus = 2;
matlabbatch{8}.spm.tools.preproc8.tissue(1).native = [1 0];
matlabbatch{8}.spm.tools.preproc8.tissue(1).warped = [0 0];
matlabbatch{8}.spm.tools.preproc8.tissue(2).tpm = {'/usr/local/packages/MATLAB/spm8/toolbox/Seg/TPM.nii,2'};
matlabbatch{8}.spm.tools.preproc8.tissue(2).ngaus = 2;
matlabbatch{8}.spm.tools.preproc8.tissue(2).native = [1 0];
matlabbatch{8}.spm.tools.preproc8.tissue(2).warped = [0 0];
matlabbatch{8}.spm.tools.preproc8.tissue(3).tpm = {'/usr/local/packages/MATLAB/spm8/toolbox/Seg/TPM.nii,3'};
matlabbatch{8}.spm.tools.preproc8.tissue(3).ngaus = 2;
matlabbatch{8}.spm.tools.preproc8.tissue(3).native = [1 0];
matlabbatch{8}.spm.tools.preproc8.tissue(3).warped = [0 0];
matlabbatch{8}.spm.tools.preproc8.tissue(4).tpm = {'/usr/local/packages/MATLAB/spm8/toolbox/Seg/TPM.nii,4'};
matlabbatch{8}.spm.tools.preproc8.tissue(4).ngaus = 3;
matlabbatch{8}.spm.tools.preproc8.tissue(4).native = [1 0];
matlabbatch{8}.spm.tools.preproc8.tissue(4).warped = [0 0];
matlabbatch{8}.spm.tools.preproc8.tissue(5).tpm = {'/usr/local/packages/MATLAB/spm8/toolbox/Seg/TPM.nii,5'};
matlabbatch{8}.spm.tools.preproc8.tissue(5).ngaus = 4;
matlabbatch{8}.spm.tools.preproc8.tissue(5).native = [1 0];
matlabbatch{8}.spm.tools.preproc8.tissue(5).warped = [0 0];
matlabbatch{8}.spm.tools.preproc8.tissue(6).tpm = {'/usr/local/packages/MATLAB/spm8/toolbox/Seg/TPM.nii,6'};
matlabbatch{8}.spm.tools.preproc8.tissue(6).ngaus = 2;
matlabbatch{8}.spm.tools.preproc8.tissue(6).native = [0 0];
matlabbatch{8}.spm.tools.preproc8.tissue(6).warped = [0 0];
matlabbatch{8}.spm.tools.preproc8.warp.reg = 4;
matlabbatch{8}.spm.tools.preproc8.warp.affreg = 'mni';
matlabbatch{8}.spm.tools.preproc8.warp.samp = 3;
matlabbatch{8}.spm.tools.preproc8.warp.write = [0 0];


%-----------------------------------------------------------------------
% Step 9: Create Brain mask (Imcalc SPM8): Enter c1, c2 and c3 +
% output directory, image out=FAmask.img.  c4 and c5 are non-brain
% matter, so we don't use them.
%-----------------------------------------------------------------------

matlabbatch{9}.spm.util.imcalc.input = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/c1FA.nii,1'
                                        'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/c2FA.nii,1'
                                        'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/c3FA.nii,1'};
matlabbatch{9}.spm.util.imcalc.output = 'FAmask.img';
matlabbatch{9}.spm.util.imcalc.outdir = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/'};
matlabbatch{9}.spm.util.imcalc.expression = '(i1+i2+i3)>0.5';
matlabbatch{9}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{9}.spm.util.imcalc.options.mask = 0;
matlabbatch{9}.spm.util.imcalc.options.interp = 1;
matlabbatch{9}.spm.util.imcalc.options.dtype = 4;

%-----------------------------------------------------------------------
% Step 10: Crop brain (Imcalc SPM8): Enter FA.img and FAmask.img and
% the output directory, image out=FAmasked.img
%-----------------------------------------------------------------------

matlabbatch{10}.spm.util.imcalc.input = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/FA.img,1'
                                         'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/FAmask.img,1'};
matlabbatch{10}.spm.util.imcalc.output = 'FAmasked.img';
matlabbatch{10}.spm.util.imcalc.outdir = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/'};
matlabbatch{10}.spm.util.imcalc.expression = 'i1.*i2';
matlabbatch{10}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{10}.spm.util.imcalc.options.mask = 0;
matlabbatch{10}.spm.util.imcalc.options.interp = 1;
matlabbatch{10}.spm.util.imcalc.options.dtype = 4;

%-----------------------------------------------------------------------
% Step 11: Perform saved Deformations
%-----------------------------------------------------------------------

%matlabbatch{11}.spm.util.defs.comp{1}.def = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/y_FA.nii'};
%matlabbatch{11}.spm.util.defs.ofname = 'FA_deformed';
%matlabbatch{11}.spm.util.defs.fnames(1) = cfg_dep;
%matlabbatch{11}.spm.util.defs.fnames(1).tname = 'Apply to';
%matlabbatch{11}.spm.util.defs.fnames(1).tgt_spec{1}(1).name = 'filter';
%matlabbatch{11}.spm.util.defs.fnames(1).tgt_spec{1}(1).value = 'image';
%matlabbatch{11}.spm.util.defs.fnames(1).tgt_spec{1}(2).name = 'strtype';
%matlabbatch{11}.spm.util.defs.fnames(1).tgt_spec{1}(2).value = 'e';
%matlabbatch{11}.spm.util.defs.fnames(1).sname = 'Image Calculator: Imcalc Computed Image: FAmasked.img';
%matlabbatch{11}.spm.util.defs.fnames(1).src_exbranch = substruct('.','val', '{}',{10}, '.','val', '{}',{1}, '.','val', '{}',{1});
%matlabbatch{11}.spm.util.defs.fnames(1).src_output = substruct('.','files');
%matlabbatch{11}.spm.util.defs.savedir.savesrc = 1;
%matlabbatch{11}.spm.util.defs.interp = 1;

matlabbatch{11}.spm.spatial.normalise.estwrite.subj.source = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/FAmasked.img,1'};
matlabbatch{11}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
matlabbatch{11}.spm.spatial.normalise.estwrite.subj.resample = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/FAmasked.img,1'};
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.template = {'SUB_MOUNT_SUB/Analysis/DTI/ROI/FMRIB58_FA_1mmnii.nii,1'};
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.weight = '';
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
matlabbatch{11}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
matlabbatch{11}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
matlabbatch{11}.spm.spatial.normalise.estwrite.roptions.bb = [-78 -112 -50
                                                              78 76 85];
matlabbatch{11}.spm.spatial.normalise.estwrite.roptions.vox = [2 2 2];
matlabbatch{11}.spm.spatial.normalise.estwrite.roptions.interp = 1;
matlabbatch{11}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
matlabbatch{11}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';

%-----------------------------------------------------------------------
% Step 11: Smooth the final Image
%-----------------------------------------------------------------------

matlabbatch{12}.spm.spatial.smooth.data = {'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA/wFAmasked.img,1'};
matlabbatch{12}.spm.spatial.smooth.fwhm = [4 4 4];
matlabbatch{12}.spm.spatial.smooth.dtype = 0;
matlabbatch{12}.spm.spatial.smooth.im = 0;
matlabbatch{12}.spm.spatial.smooth.prefix = 's';

%Execute the job to process the dti data

spm_jobman('run_nogui',matlabbatch)

clear matlabbatch

end

% Fixing paths for SPM.mat under 'FA' - NOTE - this script is not working
% for the SPM.xY.P paths because it isn't clear that we need this path
% changed at this time!
cd 'SUB_MOUNT_SUB/Analysis/DTI/SPM/SUB_SUBJECT_SUB/FA'
spm_change_paths_dti('/ramSUB_MOUNT_SUB/','SUB_MOUNT_SUB/','N:/DNS.01/','/');

exit