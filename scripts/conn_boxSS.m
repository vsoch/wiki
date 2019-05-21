%--------------------------------------------------------------------------
% CONN_BOXSS: This script is a template used by spm_RESTSS.sh and 
% spm_RESTSS.py on the cluster.  It does quick anatomical preprocessing and
% image normalization for subjects that are to be submit for a rest run.
% Once subjects have been prepped with spm_RESTSS, then spm_RESTGP.sh can be
% run to complete the group analysis and create a directory under
% Analysis/Second_level with a .mat that can be opened in the toolbox GUI
% for Second Level Analysis.  This script, however, is run once per
% individual subject, and takes care of individual subject prep for the
% group analysis.
%--------------------------------------------------------------------------
% DEPENDENCIES: 
% - The connectivity toolbox should be in a folder called "Tools" within 
% the Scripts directory in the Experiment directory.
% - ROI's should be placed in ROI/Rest_toolbox
% - Subjects should already have processed swu* images under
% Analysis/SPM/Processed/SUBJ/rest, as well as an anatomical raw image in
% the format "sdns01-0002-00001-000001-01.img/.hdr" OR
% "sDNS01-0002-00001-000001-01.img/.hdr" in the Processed/SUBJ/ anat dir.
% - Since we create slice timed images (swuaV00*) from the raw VOO images,
% the bash script checks that this data exists, and copies the raw V00*
% images into the Processed/rest directory for working.  We delete
% intermediate images at the end.
%--------------------------------------------------------------------------
% OVERVIEW:

% MATLAB PATHS SETUP
% Add paths to spm and the subject's Processed and Analyzed directories.
% 
% DIRECTORY CREATION
% Checks that we have rest output directory, and swu* images and motion
% regressor file, and V00 images.  Checks for the anatomical folder and
% file.  If we do, we make a subdirectory to copy the raw anatomical.
% If anything is not found, we exit.

% SET UP MATLABBATCH
% 1) Raw V00 images should have been copied into Processed/rest
% 2) Slice timew to make aV00*.img
% 3) Unwarp, cogregister, normalize, and smooth to get swuaV00*.img
% 4) Raw anatomical is in SUBJECT/anat/anat_rest 
% 5) Segment the anatomical data for white, grey, and csf
% 6) Normalize the raw anatomical, c1, c2, and c3 to the T1 template image
% 
% The main script, spm_RESTGP.py will process all individual subjects in
% this manner, and then submit one run of spm_RESTGP.sh to do the group
% analysis with all the subjects specified, creating the output under 
% SPM/Analysis/Second_level/  See the script spm_RESTGP.m (the matlab
% template) and spm_RESTGP.py (the python submission script on the head
% node) for more details.


%% MATLAB PATHS SETUP
BIACroot = 'SUB_BIACROOT_SUB';

startm=fullfile(BIACroot,'startup.m');
if exist(startm,'file')
  run(startm);
else
  warning(sprintf(['Unable to locate central BIAC startup.m file/n  (%s)./n' ...
      '  Connect to network or set BIACMATLABROOT environment variable./n'],startm));
end
clear startm BIACroot
% Add path to spm and script to run
addpath(genpath('SUB_SCRIPTDIR_SUB'));
addpath(genpath('/usr/local/packages/MATLAB/spm8'));

% Add path to subject analyzed and processed data
addpath(genpath('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB'));
addpath(genpath('SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB'));
% Add path to the connectivity toolbox
addpath(genpath('SUB_MOUNT_SUB/Scripts/Tools'));

%Here we set some directory variables to make navigation easier
restdir='SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/rest/';
anatdir='SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/';

%% DIRECTORY CREATION
% check that the anat and rest directories exist for the subject, as well
% as the first swuV00* image.  If they do not, exit with error.
if exist(restdir,'dir')
    cd(restdir)
    % Check for V00 images:
    if exist('V0001.img','file')==0
        error('V000* images possibly do not exist for this subject.  Exiting.')
    end
else
    error('Rest directory (rest) does not exist for this subject. Exiting')
end

if exist(anatdir,'dir')==0
    error('Anat directory for this subject does not exist, exiting')
% If the anat directory does exist, create "anat_dir" within it to copy the
% subject's anatomical and then segment it into white, grey, and csf, and
% normalize all images to the T1.
else
    cd(anatdir);
    if exist('anat_rest','dir')==0
        fprintf('Creating anat_rest directory under "anat"')
        mkdir anat_rest;
    end
    
    % Check for the anatomical image, both dns01 and DNS01, since it varies
    fprintf('Checking for processed anatomical image...')
    if exist('sdns01-0002-00001-000001-01.img','file');
        fprintf('Copying anatomical image into anat_rest folder...')
        copyfile('sdns01-0002-00001-000001-01.img','anat_rest/sdns01-0002.img');
        copyfile('sdns01-0002-00001-000001-01.hdr','anat_rest/sdns01-0002.hdr');
    elseif exist('sDNS01-0002-00001-000001-01.img','file');
        fprintf('Copying anatomical image into anat_rest folder...')
        copyfile('sDNS01-0002-00001-000001-01.img','anat_rest/sdns01-0002.img');
        copyfile('sDNS01-0002-00001-000001-01.hdr','anat_rest/sdns01-0002.hdr');
    else
        error('Anatomical image cannot be found.  Exiting.')
    end
end

% Here we initialize the spm_jobman to setup the matlabbatch that will
% create out segmented anatomical images (white grey and csf) and then
% normalize these images to the T1 standard image.

spm('defaults','fmri')
spm_jobman('initcfg');


%% PREPARE DATA WITH SPM

% Get V000 images
V00img=dir(fullfile(restdir,'V0*.img')); numimages = length(V00img);
for j=1:numimages; imagearray{1}{j}=horzcat(restdir,V00img(j).name,',1'); end; clear V00img;
    
% In matlabbatch(1) we are creating the slice timed rest images from the raw V0 images
matlabbatch{1}.spm.temporal.st.scans = imagearray;
matlabbatch{1}.spm.temporal.st.nslices = 34;
matlabbatch{1}.spm.temporal.st.tr = 2;
matlabbatch{1}.spm.temporal.st.ta = 1.94117647058824;
matlabbatch{1}.spm.temporal.st.so = [1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34];
matlabbatch{1}.spm.temporal.st.refslice = 1;
matlabbatch{1}.spm.temporal.st.prefix = 'a';

% Create array of aV* image paths
for j=1:numimages; imagename=imagearray{1}{j}(regexp(imagearray{1}{j},'V0'):end); holder{j}=horzcat(restdir,'a',imagename); end;
imagearray = holder; clear holder;

% matlabbatch{2} does image REALIGN and UNWARP
matlabbatch{2}.spm.spatial.realignunwarp.data.scans = imagearray;
matlabbatch{2}.spm.spatial.realignunwarp.data.pmscan = '';
matlabbatch{2}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
matlabbatch{2}.spm.spatial.realignunwarp.eoptions.sep = 4;
matlabbatch{2}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
matlabbatch{2}.spm.spatial.realignunwarp.eoptions.rtm = 0;
matlabbatch{2}.spm.spatial.realignunwarp.eoptions.einterp = 2;
matlabbatch{2}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
matlabbatch{2}.spm.spatial.realignunwarp.eoptions.weight = {''};
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.jm = 0;
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.sot = [];
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.rem = 1;
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.noi = 5;
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.mask = 1;
matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';

% matlabbatch{3} does cogregistration 
matlabbatch{3}.spm.spatial.coreg.estimate.ref = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/rest/meanuaV0001.img,1'};
matlabbatch{3}.spm.spatial.coreg.estimate.source = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/rest/c1sdns01-0002-00001-000001-01.img,1'};
matlabbatch{3}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

% Create array of uaV* image paths
for j=1:numimages; imagename=imagearray{j}(regexp(imagearray{j},'aV0'):end); holder{j}=horzcat(restdir,'u',imagename); end;
imagearray = holder; clear holder;

% matlabbatch{4} holds normalization parameters
matlabbatch{4}.spm.spatial.normalise.estwrite.subj.source = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/rest/c1sdns01-0002-00001-000001-01.img,1'};
matlabbatch{4}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
matlabbatch{4}.spm.spatial.normalise.estwrite.subj.resample = imagearray;
matlabbatch{4}.spm.spatial.normalise.estwrite.eoptions.template = {'/usr/local/packages/MATLAB/spm8/apriori/grey.nii,1'};
matlabbatch{4}.spm.spatial.normalise.estwrite.eoptions.weight = '';
matlabbatch{4}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
matlabbatch{4}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
matlabbatch{4}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
matlabbatch{4}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
matlabbatch{4}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
matlabbatch{4}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
matlabbatch{4}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
matlabbatch{4}.spm.spatial.normalise.estwrite.roptions.bb = [-78 -112 -50
                                                             78 76 85];
matlabbatch{4}.spm.spatial.normalise.estwrite.roptions.vox = [2 2 2];
matlabbatch{4}.spm.spatial.normalise.estwrite.roptions.interp = 1;
matlabbatch{4}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
matlabbatch{4}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';

% Create array of wuaV* image paths
for j=1:numimages; imagename=imagearray{j}(regexp(imagearray{j},'uaV0'):end); holder{j}=horzcat(restdir,'w',imagename); end;
imagearray = holder; clear holder;

% matlabbatch{5} holds smoothing parameters
matlabbatch{5}.spm.spatial.smooth.data = imagearray;
matlabbatch{5}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{5}.spm.spatial.smooth.dtype = 0;
matlabbatch{5}.spm.spatial.smooth.prefix = 's';

% In matlabbatch(6) we are segmented the anatomical image for white, grey, and csf
matlabbatch{6}.spm.spatial.preproc.data = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/anat_rest/sdns01-0002.img,1'};
matlabbatch{6}.spm.spatial.preproc.output.GM = [0 0 1];
matlabbatch{6}.spm.spatial.preproc.output.WM = [0 0 1];
matlabbatch{6}.spm.spatial.preproc.output.CSF = [0 0 1];
matlabbatch{6}.spm.spatial.preproc.output.biascor = 1;
matlabbatch{6}.spm.spatial.preproc.output.cleanup = 0;
matlabbatch{6}.spm.spatial.preproc.opts.tpm = {
                                               '/usr/local/packages/MATLAB/spm8/tpm/grey.nii'
                                               '/usr/local/packages/MATLAB/spm8/tpm/white.nii'
                                               '/usr/local/packages/MATLAB/spm8/tpm/csf.nii'
                                               };
matlabbatch{6}.spm.spatial.preproc.opts.ngaus = [2
                                                 2
                                                 2
                                                 4];
matlabbatch{6}.spm.spatial.preproc.opts.regtype = 'mni';
matlabbatch{6}.spm.spatial.preproc.opts.warpreg = 1;
matlabbatch{6}.spm.spatial.preproc.opts.warpco = 25;
matlabbatch{6}.spm.spatial.preproc.opts.biasreg = 0.0001;
matlabbatch{6}.spm.spatial.preproc.opts.biasfwhm = 60;
matlabbatch{6}.spm.spatial.preproc.opts.samp = 3;
matlabbatch{6}.spm.spatial.preproc.opts.msk = {''};

% In matlabbatch(7) we are normalizing the c1,c2,c3, and s* raw image to
% the standard T1 using the c1 image as a template.
matlabbatch{7}.spm.spatial.normalise.estwrite.subj.source = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/anat_rest/c1sdns01-0002.img,1'};
matlabbatch{7}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
matlabbatch{7}.spm.spatial.normalise.estwrite.subj.resample = {
                                                               'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/anat_rest/sdns01-0002.img,1'
                                                               'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/anat_rest/c1sdns01-0002.img,1'
                                                               'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/anat_rest/c2sdns01-0002.img,1'
                                                               'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/anat_rest/c3sdns01-0002.img,1'
                                                               };

matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.template = {'/usr/local/packages/MATLAB/spm8/apriori/grey.nii,1'};
matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.weight = '';
matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
matlabbatch{7}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
matlabbatch{7}.spm.spatial.normalise.estwrite.roptions.bb = [-78 -112 -50
                                                             78 76 85];
matlabbatch{7}.spm.spatial.normalise.estwrite.roptions.vox = [2 2 2];
matlabbatch{7}.spm.spatial.normalise.estwrite.roptions.interp = 1;
matlabbatch{7}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
matlabbatch{7}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';

% Run the job with spm_jobman
spm_jobman('run_nogui',matlabbatch)

% Now we clear matlabbatch and continue to the rest analysis
save matlabbatch.mat; clear matlabbatch

% Return to rest directory and delete intermediate files
cd(restdir); delete V0*.img aV0*.img uaV0*.img wuaV0*.img V0*.hdr aV0*.hdr uaV0*.hdr wuaV0*.hdr

% When we finish, exit matlab
exit