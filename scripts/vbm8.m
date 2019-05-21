%-----------------------------------------------------------------------
% SPM BATCH VBM8
%
% Utilizing VBM8 toolbox, this script preprocesses high resolution t1
% images (segmentation/ normalization/ and smoothing)
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
addpath(genpath('SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB'));

spm('defaults','fmri')
spm_jobman('initcfg');

matlabbatch{1}.spm.tools.vbm8.estwrite.data = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/SUB_NAMEOFANAT_SUB.img,1'};
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.tpm = {'/usr/local/packages/MATLAB/spm8/toolbox/Seg/TPM.nii'};
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.ngaus = [2 2 2 3 4 2];
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.biasreg = 0.0001;
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.biasfwhm = 60;
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.affreg = 'mni';
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.warpreg = 4;
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.samp = 3;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.dartelwarp = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.sanlm = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.mrf = 0.15;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.cleanup = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.print = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.native = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.warped = 0;


% 0: none, 1: affine and nonlinear (SPM Default)  2: non-linear only (SPGR)
matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.modulated = SUB_GMMODULATION_SUB;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.dartel = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.native = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.warped = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.modulated = 2;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.dartel = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.native = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.warped = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.modulated = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.dartel = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.native = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.warped = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.affine = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.native = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.warped = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.dartel = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.jacobian.warped = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.warps = [0 0];


%-----------------------------------------------------------------------
% Smooth the segmented normalized grey matter image
%-----------------------------------------------------------------------


if strcmp('SUB_GMMODULATION_SUB','1')
    
    matlabbatch{2}.spm.spatial.smooth.data = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/mwp1SUB_NAMEOFANAT_SUB.nii,1'};
    matlabbatch{2}.spm.spatial.smooth.fwhm = [12 12 12];
    matlabbatch{2}.spm.spatial.smooth.dtype = 0;
    matlabbatch{2}.spm.spatial.smooth.im = 0;
    matlabbatch{2}.spm.spatial.smooth.prefix = 's';

    matlabbatch{3}.spm.spatial.smooth.data = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/m0wp2SUB_NAMEOFANAT_SUB.nii,1'};
    matlabbatch{3}.spm.spatial.smooth.fwhm = [12 12 12];
    matlabbatch{3}.spm.spatial.smooth.dtype = 0;
    matlabbatch{3}.spm.spatial.smooth.im = 0;
    matlabbatch{3}.spm.spatial.smooth.prefix = 's';

end

if strcmp('SUB_GMMODULATION_SUB','2')
    
    matlabbatch{2}.spm.spatial.smooth.data = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/m0wp1SUB_NAMEOFANAT_SUB.nii,1'};
    matlabbatch{2}.spm.spatial.smooth.fwhm = [12 12 12];
    matlabbatch{2}.spm.spatial.smooth.dtype = 0;
    matlabbatch{2}.spm.spatial.smooth.im = 0;
    matlabbatch{2}.spm.spatial.smooth.prefix = 's';

    matlabbatch{3}.spm.spatial.smooth.data = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/m0wp2SUB_NAMEOFANAT_SUB.nii,1'};
    matlabbatch{3}.spm.spatial.smooth.fwhm = [12 12 12];
    matlabbatch{3}.spm.spatial.smooth.dtype = 0;
    matlabbatch{3}.spm.spatial.smooth.im = 0;
    matlabbatch{3}.spm.spatial.smooth.prefix = 's';

end

spm_jobman('run_nogui',matlabbatch)

%Now we clear matlabbatch to do cards
clear matlabbatch

exit


