%-----------------------------------------------------------------------
% SPM BATCH ORDER 3 (ASFN) - comes after spm_batch1.m
%
% These template scripts are filled in and run by a bash script,
% spm_preprocess_TEMPLATE.sh from the head node of BIAC
%
% Output contrasts are as follows:
%
% FACES: Faces > Shapes (1), Fearful Faces > Shapes (2), Neutral Faces >
% Shapes (3), Surprise Faces > Shapes (4) for both affect and block design.  
% CARDS: Positive Feedback > Negative Feedback (1), Negative Feedback > 
% Positive Feedback (2), Positive Feedback > Control (3), Negative 
% Feedback > Control (4).  For complete contrasts, please see DNS excel. 
%
%    The Laboratory of Neurogenetics, 2010
%       By Vanessa Sochat, Duke University
%       Patrick Fisher, University of Pittsburgh 
%
% Change log:
%       4/30/11: Added pathlength variable and moved cd(.../task) into 'if' block for each task (Annchen)
%       4/30/11: Suppressed 'beep.m' name conflict warning
%
%-----------------------------------------------------------------------

% Add necessary paths for BIAC, then SPM and data folders
BIACroot = 'SUB_BIACROOT_SUB'; startm=fullfile(BIACroot,'startup.m');
if exist(startm,'file'); run(startm); else warning(sprintf(['Unable to locate central BIAC startup.m file\n  (%s).\n Connect to network or set BIACMATLABROOT environment variable.\n'],startm)); end; clear startm BIACroot

% Suppress 'beep.m' name confict warning, beware that this might suppress something relevant!!
warning('off', 'MATLAB:dispatcher:nameConflict');
fprintf(['**Note: MATLAB:dispatcher:nameConflict warnings have been suppressed**']);

addpath(genpath('SUB_SCRIPTDIR_SUB'));addpath(genpath('/usr/local/packages/MATLAB/spm8'));addpath(genpath('SUB_MOUNT_SUB/Data/Anat/SUB_SUBJECT_SUB'));
addpath(genpath('SUB_MOUNT_SUB/Data/Func/SUB_SUBJECT_SUB'));addpath(genpath('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB'));addpath(genpath('SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB'));

%Here we set the home directory variables to make navigation easier
homedir='SUB_MOUNT_SUB/Analysis/SPM/';

%% ANAT COPY: Here we are copying our anatomicals into each functional directory for registration.
    
if strcmp('SUB_RUNFACES_SUB', 'yes')
    copyfile('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/c1sdns01-0002-00001-000001-01.img','SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/faces');
    copyfile('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/c1sdns01-0002-00001-000001-01.hdr','SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/faces');
end

if strcmp('SUB_RUNCARDS_SUB', 'yes')
    copyfile('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/c1sdns01-0002-00001-000001-01.img','SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/cards');
    copyfile('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/c1sdns01-0002-00001-000001-01.hdr','SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/cards');
end

if strcmp('SUB_RUNREST_SUB', 'yes')
    copyfile('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/c1sdns01-0002-00001-000001-01.img','SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/rest');
    copyfile('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/c1sdns01-0002-00001-000001-01.hdr','SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/rest');
end

%% FACES PROCESSING: realign & unwarp, cogregistration, normalization, and smoothing

% FACES ~REALIGN AND UNWARP 
if strcmp('SUB_RUNFACES_SUB', 'yes')                      % Check if the user wants to process faces data:
    cd(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/faces'));   % Make sure that we are in the subjects faces output directory
    spm('defaults','fmri'); spm_jobman('initcfg');        % Initialize spm jobman
    
    % Get V000 images
    V00img=dir(fullfile(homedir,'Processed/SUB_SUBJECT_SUB/faces/','V0*.img')); numimages = 195;
    for j=1:numimages; imagearray{j}=horzcat(homedir,'Processed/SUB_SUBJECT_SUB/faces/',V00img(j).name,',1'); end; clear V00img;

    matlabbatch{1}.spm.spatial.realignunwarp.data.scans = imagearray;                                                       
    matlabbatch{1}.spm.spatial.realignunwarp.data.pmscan = '';
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.sep = 4;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.rtm = 0;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.einterp = 2;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.weight = {''};
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.jm = 0;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.sot = 1;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.rem = 1;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.noi = 5;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.mask = 1;
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';

    % FACES ~COGREGISTRATION: Dependencies include c1* image copied into faces from anat in spm_batch1.m, and meanuV0001.img created during realign & unwarp
    matlabbatch{2}.spm.spatial.coreg.estimate.ref = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/faces/meanuV0001.img,1'};
    matlabbatch{2}.spm.spatial.coreg.estimate.source = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/faces/c1sdns01-0002-00001-000001-01.img,1'};
    matlabbatch{2}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

    % Create array of uV* image paths
    for j=1:numimages; imagename=imagearray{j}(regexp(imagearray{j},'V0'):end); holder{j}=horzcat(homedir,'Processed/SUB_SUBJECT_SUB/faces/u',imagename); end;
    imagearray = holder; clear holder;

    % FACES ~NORMALIZATION: Dependencies include c1* image copied into faces from anat in spm_batch1.m, and 195 uV00* images created after realign & unwarp
    matlabbatch{3}.spm.spatial.normalise.estwrite.subj.source = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/faces/c1sdns01-0002-00001-000001-01.img,1'};
    matlabbatch{3}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
    matlabbatch{3}.spm.spatial.normalise.estwrite.subj.resample = imagearray;
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.template = {'/usr/local/packages/MATLAB/spm8/apriori/grey.nii,1'};
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.weight = '';
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.bb = [-78 -112 -50; 78 76 85];
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.vox = [2 2 2];
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.interp = 1;
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';

    % Create array of wuV* image paths
    for j=1:numimages; imagename=imagearray{j}(regexp(imagearray{j},'uV0'):end); holder{j}=horzcat(homedir,'Processed/SUB_SUBJECT_SUB/faces/w',imagename); end;
    imagearray = holder; clear holder;

    % FACES ~SMOOTHING: Dependencies include wuV00* images created after normalization.  
    matlabbatch{4}.spm.spatial.smooth.data = imagearray;
    matlabbatch{4}.spm.spatial.smooth.fwhm = [6 6 6];
    matlabbatch{4}.spm.spatial.smooth.dtype = 0;
    matlabbatch{4}.spm.spatial.smooth.im = 0;
    matlabbatch{4}.spm.spatial.smooth.prefix = 's';

    % Create array of wuV* image paths
    for j=1:numimages; imagename=imagearray{j}(regexp(imagearray{j},'wuV0'):end); holder{j}=horzcat(homedir,'Processed/SUB_SUBJECT_SUB/faces/s',imagename); end;
    imagearray = holder; clear holder;

    % FACES ~SINGLE SUBJECT PROCESSING: Sets up the design and runs single subject processing.  Dependencies include swuV00* 
    % images created after smoothing. Output goes to faces_pfl under Analysis/SPM/Analyzed
    matlabbatch{5}.spm.stats.fmri_spec.dir = {'SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB/faces_pfl'};
    matlabbatch{5}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{5}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{5}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{5}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
    matlabbatch{5}.spm.stats.fmri_spec.sess.scans = imagearray;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(1).name = 'Shapes';
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(1).onset = [0 44 88 132 176];
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(1).duration = 19;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(2).name = 'Faces1';
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(2).onset = 19;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(2).duration = 25;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(3).name = 'Faces2';
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(3).onset = 63;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(3).duration = 25;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(4).name = 'Faces3';
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(4).onset = 107;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(4).duration = 25;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(5).name = 'Faces4';
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(5).onset = 151;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(5).duration = 25;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(5).tmod = 0;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{5}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{5}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{5}.spm.stats.fmri_spec.sess.multi_reg = {''};
    matlabbatch{5}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{5}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{5}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{5}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{5}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{5}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{5}.spm.stats.fmri_spec.cvi = 'AR(1)';
    matlabbatch{6}.spm.stats.fmri_est.spmmat = {'SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB/faces_pfl/SPM.mat'};
    matlabbatch{6}.spm.stats.fmri_est.method.Classical = 1;

    % FACES JOB SUBMIT: Run matlabbatch job and clear for cards
    spm_jobman('run_nogui',matlabbatch); clear matlabbatch; 
end

%% CARDS PROCESSING: realign & unwarp, cogregistration, normalization, and smoothing for the cards data

% CARDS ~REALIGN AND UNWARP  
if strcmp('SUB_RUNCARDS_SUB', 'yes')                    % Check if user wants to process cards    
    cd(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/cards')); % Go to cards output directory
    spm('defaults','fmri'); spm_jobman('initcfg');      % Initialize SPM JOBMAN

    % Get V000 images
    clear imagearray; V00img=dir(fullfile(homedir,'Processed/SUB_SUBJECT_SUB/cards/','V0*.img')); numimages = 171;
    for j=1:numimages; imagearray{j}=horzcat(homedir,'Processed/SUB_SUBJECT_SUB/cards/',V00img(j).name,',1'); end; clear V00img;

    matlabbatch{1}.spm.spatial.realignunwarp.data.scans = imagearray;
    matlabbatch{1}.spm.spatial.realignunwarp.data.pmscan = '';
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.sep = 4;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.rtm = 0;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.einterp = 2;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.weight = {''};
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.jm = 0;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.sot = 1;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.rem = 1;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.noi = 5;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.mask = 1;
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';

    % CARDS ~COGREGISTRATION: Dependencies include c1* image copied into cards from anat in
    matlabbatch{2}.spm.spatial.coreg.estimate.ref = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/cards/meanuV0001.img,1'};
    matlabbatch{2}.spm.spatial.coreg.estimate.source = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/cards/c1sdns01-0002-00001-000001-01.img,1'};
    matlabbatch{2}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

    % Create array of uV* image paths
    for j=1:numimages; imagename=imagearray{j}(regexp(imagearray{j},'V0'):end); holder{j}=horzcat(homedir,'Processed/SUB_SUBJECT_SUB/cards/u',imagename); end;
    imagearray = holder; clear holder;

    % CARDS ~NORMALIZATION: Dependencies include c1* image copied into cards from anat in spm_batch1.m, and 171 uV00* images created after realign & unwarp
    matlabbatch{3}.spm.spatial.normalise.estwrite.subj.source = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/cards/c1sdns01-0002-00001-000001-01.img,1'};
    matlabbatch{3}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
    matlabbatch{3}.spm.spatial.normalise.estwrite.subj.resample = imagearray;
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.template = {'/usr/local/packages/MATLAB/spm8/apriori/grey.nii,1'};
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.weight = '';
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.bb = [-78 -112 -50; 78 76 85];
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.vox = [2 2 2];
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.interp = 1;
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';

    % Create array of wuV* image paths
    for j=1:numimages; imagename=imagearray{j}(regexp(imagearray{j},'uV0'):end); holder{j}=horzcat(homedir,'Processed/SUB_SUBJECT_SUB/cards/w',imagename); end;
    imagearray = holder; clear holder;
    
    % CARDS ~SMOOTHING: Dependencies include wuV00* images created after normalization.  
    matlabbatch{4}.spm.spatial.smooth.data = imagearray;
    matlabbatch{4}.spm.spatial.smooth.fwhm = [6 6 6];
    matlabbatch{4}.spm.spatial.smooth.dtype = 0;
    matlabbatch{4}.spm.spatial.smooth.im = 0;
    matlabbatch{4}.spm.spatial.smooth.prefix = 's';

    % CARDS ~SINGLE SUBJECT PROCESSING: Sets up the design and runs single subject processing. Dependencies include swuV00* images created 
    % after smoothing. Output goes to cards_pfl under Analysis/SPM/Analyzed

    % Create array of swuV* image paths
    for j=1:numimages; imagename=imagearray{j}(regexp(imagearray{j},'wuV0'):end); holder{j}=horzcat(homedir,'Processed/SUB_SUBJECT_SUB/cards/s',imagename); end;
    imagearray = holder; clear holder;
    
    matlabbatch{5}.spm.stats.fmri_spec.dir = {'SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB/cards_pfl'};
    matlabbatch{5}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{5}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{5}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{5}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
    matlabbatch{5}.spm.stats.fmri_spec.sess.scans = imagearray;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(1).name = 'Control';
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(1).onset = [38 95 152];
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(1).duration = 19;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(2).name = 'Positive Feedback';
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(2).onset = [0 57 114];
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(2).duration = 19;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(3).name = 'Negative Feedback';
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(3).onset = [19 76 133];
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(3).duration = 19;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{5}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{5}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{5}.spm.stats.fmri_spec.sess.multi_reg = {''};
    matlabbatch{5}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{5}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{5}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{5}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{5}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{5}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{5}.spm.stats.fmri_spec.cvi = 'AR(1)';
    matlabbatch{6}.spm.stats.fmri_est.spmmat = {'SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB/cards_pfl/SPM.mat'};
    matlabbatch{6}.spm.stats.fmri_est.method.Classical = 1;

    % CARDS JOB SUBMIT! Submit matlabbatch for cards and clear for rest
    spm_jobman('run_nogui',matlabbatch); clear matlabbatch;
end

%%  RESTING BOLD PROCESSING realign & unwarp, cogregistration, normalization, and smoothing 

% REST ~REALIGN AND UNWARP 
if strcmp('SUB_RUNREST_SUB', 'yes')                         % Check if the user wants to process rest data:
    cd(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/rest'));      % Go to rest output directory
    spm('defaults','fmri'); spm_jobman('initcfg');          % Initialize SPM JOBMAN
    
    % Get V000 images
    clear imagearray; V00img=dir(fullfile(homedir,'Processed/SUB_SUBJECT_SUB/rest/','V0*.img')); numimages = 128;
    for j=1:numimages; imagearray{j}=horzcat(homedir,'Processed/SUB_SUBJECT_SUB/rest/',V00img(j).name,',1'); end; clear V00img;

    matlabbatch{1}.spm.spatial.realignunwarp.data.scans = imagearray;
    matlabbatch{1}.spm.spatial.realignunwarp.data.pmscan = '';
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.sep = 4;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.rtm = 0;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.einterp = 2;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.weight = {''};
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.jm = 0;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.sot = 1;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.rem = 1;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.noi = 5;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.mask = 1;
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';

    % REST ~COGREGISTRATION: Dependencies include c1* image copied into rest from anat in spm_batch1.m, and meanuV0001.img created during realign & unwarp
    matlabbatch{2}.spm.spatial.coreg.estimate.ref = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/rest/meanuV0001.img,1'};
    matlabbatch{2}.spm.spatial.coreg.estimate.source = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/rest/c1sdns01-0002-00001-000001-01.img,1'};
    matlabbatch{2}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

    % Create array of uV* image paths
    for j=1:numimages; imagename=imagearray{j}(regexp(imagearray{j},'V0'):end); holder{j}=horzcat(homedir,'Processed/SUB_SUBJECT_SUB/rest/u',imagename); end;
    imagearray = holder; clear holder;
    
    % REST ~NORMALIZATION: Dependencies include c1* image copied into faces from anat in spm_batch1.m, and 128 uV00* images created after realign & unwarp
    matlabbatch{3}.spm.spatial.normalise.estwrite.subj.source = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/rest/c1sdns01-0002-00001-000001-01.img,1'};
    matlabbatch{3}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
    matlabbatch{3}.spm.spatial.normalise.estwrite.subj.resample = imagearray;
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.template = {'/usr/local/packages/MATLAB/spm8/apriori/grey.nii,1'};
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.weight = '';
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
    matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.bb = [-78 -112 -50;
                                                                 78 76 85];
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.vox = [2 2 2];
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.interp = 1;
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';

    % Create array of wuV* image paths
    for j=1:numimages; imagename=imagearray{j}(regexp(imagearray{j},'uV0'):end); holder{j}=horzcat(homedir,'Processed/SUB_SUBJECT_SUB/rest/w',imagename); end;
    imagearray = holder; clear holder;
   
    % REST ~SMOOTHING: Dependencies include wuV00* images created after normalization.  
    matlabbatch{4}.spm.spatial.smooth.data = imagearray;
    matlabbatch{4}.spm.spatial.smooth.fwhm = [6 6 6];
    matlabbatch{4}.spm.spatial.smooth.dtype = 0;
    matlabbatch{4}.spm.spatial.smooth.im = 0;
    matlabbatch{4}.spm.spatial.smooth.prefix = 's';

    % Create array of swuV* image paths
    for j=1:numimages; imagename=imagearray{j}(regexp(imagearray{j},'wuV0'):end); holder{j}=horzcat(homedir,'Processed/SUB_SUBJECT_SUB/rest/s',imagename); end;
    imagearray = holder; clear holder;

    % REST ~SINGLE SUBJECT PROCESSING: Sets up the design and runs single subject processing.  Dependencies include swuV00* images created after smoothing. Output goes to 
    % rest_pfl under Analysis/SPM/Analyzed
    matlabbatch{5}.spm.stats.fmri_spec.dir = {'SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB/rest_pfl'};
    matlabbatch{5}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{5}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{5}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{5}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
    matlabbatch{5}.spm.stats.fmri_spec.sess.scans = imagearray;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(1).name = 'First Half';
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(1).onset = 0;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(1).duration = 64;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(2).name = 'Second Half';
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(2).onset = 64;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(2).duration = 64;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
    matlabbatch{5}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{5}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{5}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{5}.spm.stats.fmri_spec.sess.multi_reg = {''};
    matlabbatch{5}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{5}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{5}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{5}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{5}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{5}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{5}.spm.stats.fmri_spec.cvi = 'AR(1)';
    matlabbatch{6}.spm.stats.fmri_est.spmmat = {'SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB/rest_pfl/SPM.mat'};
    matlabbatch{6}.spm.stats.fmri_est.method.Classical = 1;

    % REST JOB SUBMIT: and clear matlabbatch
    spm_jobman('run_nogui',matlabbatch); clear matlabbatch
end

%% SPM CHECK REGISTRATION
% After initial pre-processing batch file is completed Check Registration will be used to create visualizations of a random set of 12 smoothed
% functional images for each of the three tasks.  The reason for this is to approximate whether, across all scans, the smoothed image files are of
% good quality.  This can be incorporated into the batch stream, however, it is unclear to me within the batch editory how to print the output to the
% *.ps file that SPM8 creates when it compeltes other steps such as Realign&Unwarp.

cd(horzcat(homedir,'Processed/SUB_SUBJECT_SUB'))
pathlength = 100 + SUB_USRNAMELEN_SUB; % needed to allocate correct amount of array space

% Randomly generates 12 numbers between 1 and 171.  These 12 numbers correspond to the swuV* images that will be loaded with CheckReg to
% visualize 12 random smoothed images from the cards ProcessedData folder for this single subject.
if strcmp('SUB_RUNCARDS_SUB','yes')
    % This allocates a spot in memory for the array so that it doesn't have to find a new spot for every iteration of the loop. 
    i = 171; chreg_cards=char(12,pathlength); f = ceil(i.*rand(12,1));
    for j = 1:12
        if f(j) < 10; chreg_cards(j,1:pathlength) = horzcat(homedir,'Processed/SUB_SUBJECT_SUB/cards/swuV000',num2str(f(j)),'.img,1'); end;
        if f(j) >=10; if f(j) < 100; chreg_cards(j,1:pathlength) = horzcat(homedir,'Processed/SUB_SUBJECT_SUB/cards/swuV00',num2str(f(j)),'.img,1'); end; end;   
        if f(j) >=100; chreg_cards(j,1:pathlength) = horzcat(homedir,'Processed/SUB_SUBJECT_SUB/cards/swuV0',num2str(f(j)),'.img,1'); end;
    end; spm_check_registration(chreg_cards); spm_print  %spm_print will print a *.ps of the 12 smoothed images files to the same *.ps file it created for the other components of the pre-processing
end

% Randomly generates 12 numbers between 1 and 195.  These 12 numbers correspond to the swuV* images that will be loaded with CheckReg to
% visualize 12 random smoothed images from the faces ProcessedData folder for this single subject.
if strcmp('SUB_RUNFACES_SUB','yes')
    %This allocates a spot in memory for the array so that it doesn't have to find a new spot for every iteration of the loop. 
    i=195; chreg_faces=char(12,pathlength); f = ceil(i.*rand(12,1)); 
    for j = 1:12
        if f(j) < 10; chreg_faces(j,1:pathlength) = horzcat(homedir,'Processed/SUB_SUBJECT_SUB/faces/swuV000',num2str(f(j)),'.img,1'); end;
        if f(j) >=10; if f(j) < 100; chreg_faces(j,1:pathlength) = horzcat(homedir,'Processed/SUB_SUBJECT_SUB/faces/swuV00',num2str(f(j)),'.img,1'); end; end;
        if f(j) >=100; chreg_faces(j,1:pathlength) = horzcat(homedir,'Processed/SUB_SUBJECT_SUB/faces/swuV0',num2str(f(j)),'.img,1'); end;
    end; spm_check_registration(chreg_faces); spm_print;
end

% Randomly generates 12 numbers between 1 and 128.  These 12 numbers correspond to the swuV* images that will be loaded with CheckReg to
% visualize 12 random smoothed images from the rest ProcessedData folder for this single subject.
if strcmp('SUB_RUNREST_SUB','yes')
    i = 128; chreg_rest=char(12,pathlength-1); f = ceil(i.*rand(12,1));
    for j = 1:12
        if f(j) < 10; chreg_rest(j,1:pathlength-1) = horzcat(homedir,'Processed/SUB_SUBJECT_SUB/rest/swuV000',num2str(f(j)),'.img,1'); end;
        if f(j) >=10; if f(j) < 100; chreg_rest(j,1:pathlength-1) = horzcat(homedir,'Processed/SUB_SUBJECT_SUB/rest/swuV00',num2str(f(j)),'.img,1'); end; end;   
        if f(j) >=100; chreg_rest(j,1:pathlength-1) = horzcat(homedir,'Processed/SUB_SUBJECT_SUB/rest/swuV0',num2str(f(j)),'.img,1'); end;
    end; spm_check_registration(chreg_rest); spm_print;
end

%% ART BATCH
% Calculates artifact detection for each functional run and creates single subject design matrices that include the outputs from art_batch
% The outputs from this art_batch will include a .mat file specifying particular volumes that are outliers.  This file can be loaded as a
% regressor into single subject designs to control for substantial variability of a single or set of images

addpath(genpath('SUB_MOUNT_SUB/Scripts/SPM/Art')); cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB'))

% ARTBATCH - CARDS
if strcmp('SUB_RUNCARDS_SUB', 'yes'); cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/cards_pfl'));art_batch(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/cards_pfl/SPM.mat')); end;
% ARTBATCH - FACES
if strcmp('SUB_RUNFACES_SUB', 'yes'); cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/faces_pfl'));art_batch(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/faces_pfl/SPM.mat')); end;
% ARTBATCH - REST 
if strcmp('SUB_RUNREST_SUB', 'yes'); cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/rest_pfl')); art_batch(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/rest_pfl/SPM.mat')); end;

%% FOLDER CHECK
% Check whether the folders 'cards', 'faces', or 'rest' exist within the single subject Analyzed Data folder.  If not, it creates them.  The single
% subject design matrices with these folders will incorporate the art output when necessary.
cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB'))

if strcmp('SUB_RUNCARDS_SUB','yes'); if isdir('cards')==0; sprintf('%s','Currently no cards folder exists.  Creating cards within single subject AnalyzedData folder.'); mkdir cards; end; end;
if strcmp('SUB_RUNFACES_SUB','yes'); if isdir('Faces')==0; sprintf('%s','Currently no faces folder exists.  Creating faces within single subject AnalyzedData folder.'); mkdir Faces; end; end; 
if strcmp('SUB_RUNREST_SUB','yes'); if isdir('rest')==0; sprintf('%s','Currently no rest folder exists.  Creating rest within single subject AnalyzedData folders.'); mkdir rest; end; end;
    
%% CARDS SINGLE SUBJECT PROCESSING WITH ART
% Creates a single subject design matrix that include the outputs from art_batch

if strcmp('SUB_RUNCARDS_SUB', 'yes')                % Check if the user is processing cards data:    
    spm('defaults','fmri'); spm_jobman('initcfg');  % Initialize SPM JOBMAN

    % Get swuV000 images
    clear imagearray; V00img=dir(fullfile(homedir,'Processed/SUB_SUBJECT_SUB/cards/','swuV0*.img')); numimages = 171;
    for j=1:numimages; imagearray{j}=horzcat(homedir,'Processed/SUB_SUBJECT_SUB/cards/',V00img(j).name,',1'); end; clear V00img;

    % Cards Conditions
    cd(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/cards'))
    matlabbatch{1}.spm.stats.fmri_spec.dir = {'SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB/cards/'};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = imagearray;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'Control';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = [38 95 152];
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = 19;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'Positive Feedback';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = [0 57 114];
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = 19;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = 'Negative Feedback';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = [19 76 133];
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = 19;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {horzcat(homedir,'Processed/SUB_SUBJECT_SUB/cards/art_regression_outliers_swuV0001.mat')};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    % Estimate SPM.mat
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/cards/SPM.mat')};
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    % Cards Contrasts
    matlabbatch{3}.spm.stats.con.spmmat = {horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/cards/SPM.mat')};
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Positive Feedback > Negative Feedback';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Negative Feedback > Positive Feedback';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Positive Feedback > Control';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.convec = [-1 1 0];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Negative Feedback > Control';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.convec = [-1 0 1];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{5}.fcon.name = 'Effects of Interest';
    matlabbatch{3}.spm.stats.con.consess{5}.fcon.convec = {
                                                           [1 0 0
                                                           0 1 0
                                                           0 0 1]
                                                           }';
    matlabbatch{3}.spm.stats.con.consess{5}.fcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;

    spm_jobman('run_nogui',matlabbatch); clear matlabbatch;     % Submit job and clear matlabbatch

end

%% FACES SINGLE SUBJECT ANALYSIS WITH ART
% Creates a single subject design matrix that include the outputs from art_batch

% Faces BLOCK design
if strcmp('SUB_RUNFACES_SUB', 'yes')                    % Check if the user is processing faces data:
    spm('defaults','fmri'); spm_jobman('initcfg');      % Initialize SPM JOBMAN
    cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/'));   % Go to Analyzed directory
    mkdir Faces; cd Faces; mkdir block;                 % Make block directory
    cd(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/faces'))

    % Get swuV000 images
    clear imagearray; V00img=dir(fullfile(homedir,'Processed/SUB_SUBJECT_SUB/faces/','swuV0*.img')); numimages = 195;
    for j=1:numimages; imagearray{j}=horzcat(homedir,'Processed/SUB_SUBJECT_SUB/faces/',V00img(j).name,',1'); end; clear V00img;

    matlabbatch{1}.spm.stats.fmri_spec.dir = {'SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB/Faces/block'};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = imagearray;
    
    % Faces block conditions
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'Shapes';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = [0 44 88 132 176];
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = 19;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'Angry Faces';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = 19;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = 25;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = 'Surprise Faces';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = 63;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = 25;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).name = 'Fearful Faces';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).onset = 107;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).duration = 25;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).name = 'Neutral Faces';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).onset = 151;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).duration = 25;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/faces/art_regression_outliers_swuV0001.mat'};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

    % Estimate SPM.mat
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/Faces/block/SPM.mat')};
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    % Contrasts
    matlabbatch{3}.spm.stats.con.spmmat = {horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/Faces/block/SPM.mat')};
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Faces > Shapes';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [-1 .25 .25 .25 .25];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Fearful Faces > Shapes';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [-1 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Angry Faces > Shapes';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.convec = [-1 1];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Neutral Faces > Shapes';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.convec = [-1 0 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Surprise Faces > Shapes';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.convec = [-1 0 1];
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Fearful Faces > Angry Faces';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.convec = [0 -1 0 1];
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'Fearful Faces > Neutral Faces';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.convec = [0 0 0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'Fearful Faces > Surprise Faces';
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.convec = [0 0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'Angry Faces > Fearful Faces';
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.convec = [0 1 0 -1];
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.name = 'Angry Faces > Neutral Faces';
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.convec = [0 1 0 0 -1];
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{11}.tcon.name = 'Angry Faces > Surprise Faces';
    matlabbatch{3}.spm.stats.con.consess{11}.tcon.convec = [0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{12}.tcon.name = 'Neutral Faces > Fearful Faces';
    matlabbatch{3}.spm.stats.con.consess{12}.tcon.convec = [0 0 0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{13}.tcon.name = 'Neutral Faces > Angry Faces';
    matlabbatch{3}.spm.stats.con.consess{13}.tcon.convec = [0 -1 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{14}.tcon.name = 'Neutral Faces > Surprise Faces';
    matlabbatch{3}.spm.stats.con.consess{14}.tcon.convec = [0 0 -1 0 1];
    matlabbatch{3}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{15}.tcon.name = 'Surprise Faces > Fearful Faces';
    matlabbatch{3}.spm.stats.con.consess{15}.tcon.convec = [0 0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{15}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{16}.tcon.name = 'Surprise Faces > Angry Faces';
    matlabbatch{3}.spm.stats.con.consess{16}.tcon.convec = [0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{16}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{17}.tcon.name = 'Surprise Faces > Neutral Faces';
    matlabbatch{3}.spm.stats.con.consess{17}.tcon.convec = [0 0 1 0 -1];
    matlabbatch{3}.spm.stats.con.consess{17}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{18}.tcon.name = 'Block 1+2 > Block 3+4';
    matlabbatch{3}.spm.stats.con.consess{18}.tcon.convec = [0 .5 .5 -.5 -.5];
    matlabbatch{3}.spm.stats.con.consess{18}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{19}.tcon.name = 'Block 3+4 > Block 1+2';
    matlabbatch{3}.spm.stats.con.consess{19}.tcon.convec = [0 -.5 -.5 .5 .5];
    matlabbatch{3}.spm.stats.con.consess{20}.tcon.name = 'Block 1 > Block 2';
    matlabbatch{3}.spm.stats.con.consess{20}.tcon.convec = [0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{20}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{21}.tcon.name = 'Block 3 > Block 4';
    matlabbatch{3}.spm.stats.con.consess{21}.tcon.convec = [0 0 0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{21}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{22}.tcon.name = 'Block 4 > Block 3';
    matlabbatch{3}.spm.stats.con.consess{22}.tcon.convec = [0 0 0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{22}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{23}.tcon.name = 'Block 2 > Block 1';
    matlabbatch{3}.spm.stats.con.consess{23}.tcon.convec = [0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{23}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{24}.tcon.name = 'Block 2 > Block 3';
    matlabbatch{3}.spm.stats.con.consess{24}.tcon.convec = [0 0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{24}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{25}.tcon.name = 'Block 3 > Block 2';
    matlabbatch{3}.spm.stats.con.consess{25}.tcon.convec = [0 0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{25}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{26}.tcon.name = 'Block 1 > 2 > 3 > 4';
    matlabbatch{3}.spm.stats.con.consess{26}.tcon.convec = [0 .75 .25 -.25 -.75];
    matlabbatch{3}.spm.stats.con.consess{26}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{27}.tcon.name = 'Block 4 > 3 > 2 > 1';
    matlabbatch{3}.spm.stats.con.consess{27}.tcon.convec = [0 -.75 -.25 .25 .75];
    matlabbatch{3}.spm.stats.con.consess{27}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{28}.tcon.name = 'Angry+Fearful > Shapes';
    matlabbatch{3}.spm.stats.con.consess{28}.tcon.convec = [-1 .5 0 .5 0];
    matlabbatch{3}.spm.stats.con.consess{28}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{29}.tcon.name = 'Surprise+Neutral > Shapes';
    matlabbatch{3}.spm.stats.con.consess{29}.tcon.convec = [-1 0 .5 0 .5];
    matlabbatch{3}.spm.stats.con.consess{29}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{30}.tcon.name = 'Angry+Fearful > Surprise+Neutral';
    matlabbatch{3}.spm.stats.con.consess{30}.tcon.convec = [0 .5 -.5 .5 -.5];
    matlabbatch{3}.spm.stats.con.consess{30}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{31}.tcon.name = 'Surprise+Neutral > Angry+Fearful';
    matlabbatch{3}.spm.stats.con.consess{31}.tcon.convec = [0 -.5 .5 -.5 .5];
    matlabbatch{3}.spm.stats.con.consess{31}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{32}.tcon.name = 'Angry+Fearful > Neutral';
    matlabbatch{3}.spm.stats.con.consess{32}.tcon.convec = [0 .5 0 .5 -1];
    matlabbatch{3}.spm.stats.con.consess{32}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{33}.tcon.name = 'Neutral > Angry+Fearful';
    matlabbatch{3}.spm.stats.con.consess{33}.tcon.convec = [0 -.5 0 -.5 1];
    matlabbatch{3}.spm.stats.con.consess{33}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{34}.tcon.name = 'Angry+Fearful > Surprise';
    matlabbatch{3}.spm.stats.con.consess{34}.tcon.convec = [0 .5 -1 .5 0];
    matlabbatch{3}.spm.stats.con.consess{34}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{35}.tcon.name = 'Surprise > Angry+Fearful';
    matlabbatch{3}.spm.stats.con.consess{35}.tcon.convec = [0 -.5 1 -.5 0];
    matlabbatch{3}.spm.stats.con.consess{35}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{36}.tcon.name = 'Shapes > Faces';
    matlabbatch{3}.spm.stats.con.consess{36}.tcon.convec = [1 -.25 -.25 -.25 -.25];
    matlabbatch{3}.spm.stats.con.consess{36}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{37}.fcon.name = 'Effects of Interest';
    matlabbatch{3}.spm.stats.con.consess{37}.fcon.convec = {
                                                           [1 0 0 0 0
                                                           0 1 0 0 0
                                                           0 0 1 0 0
                                                           0 0 0 1 0
                                                           0 0 0 0 1]
                                                           }';
    matlabbatch{3}.spm.stats.con.consess{37}.fcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    
    spm_jobman('run_nogui',matlabbatch); clear matlabbatch % Submit job and clear matlabbatch for affect

    % Faces AFFECT design
    spm('defaults','fmri'); spm_jobman('initcfg');         % Initialize SPM JOBMAN
    cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/'))       % Go to Analyzed directory
    cd Faces; mkdir affect                                 % Create output directory
    cd(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/faces'))

    % Faces affect Conditions
    matlabbatch{1}.spm.stats.fmri_spec.dir = {'SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB/Faces/affect'};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = imagearray; % same images as with block

    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'Shapes';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = [0 44 88 132 176];
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = 19;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'Angry Faces';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = [20 23 27 32 37 40];
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = 2;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = 'Surprise Faces';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = [64 68 73 77 80 85];
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = 2;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).name = 'Fearful Faces';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).onset = [108 111 116 120 125 129];
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).duration = 2;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).name = 'Neutral Faces';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).onset = [152 155 159 164 168 173];
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).duration = 2;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/faces/art_regression_outliers_swuV0001.mat'};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

    % Estimate SPM.mat
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/Faces/affect/SPM.mat')};
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    % Faces affect Contrasts
    matlabbatch{3}.spm.stats.con.spmmat = {horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/Faces/affect/SPM.mat')};
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Faces > Shapes';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [-1 .25 .25 .25 .25];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Fearful Faces > Shapes';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [-1 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Angry Faces > Shapes';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.convec = [-1 1];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Neutral Faces > Shapes';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.convec = [-1 0 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Surprise Faces > Shapes';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.convec = [-1 0 1];
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Fearful Faces > Angry Faces';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.convec = [0 -1 0 1];
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'Fearful Faces > Neutral Faces';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.convec = [0 0 0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'Fearful Faces > Surprise Faces';
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.convec = [0 0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'Angry Faces > Fearful Faces';
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.convec = [0 1 0 -1];
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.name = 'Angry Faces > Neutral Faces';
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.convec = [0 1 0 0 -1];
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{11}.tcon.name = 'Angry Faces > Surprise Faces';
    matlabbatch{3}.spm.stats.con.consess{11}.tcon.convec = [0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{12}.tcon.name = 'Neutral Faces > Fearful Faces';
    matlabbatch{3}.spm.stats.con.consess{12}.tcon.convec = [0 0 0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{13}.tcon.name = 'Neutral Faces > Angry Faces';
    matlabbatch{3}.spm.stats.con.consess{13}.tcon.convec = [0 -1 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{14}.tcon.name = 'Neutral Faces > Surprise Faces';
    matlabbatch{3}.spm.stats.con.consess{14}.tcon.convec = [0 0 -1 0 1];
    matlabbatch{3}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{15}.tcon.name = 'Surprise Faces > Fearful Faces';
    matlabbatch{3}.spm.stats.con.consess{15}.tcon.convec = [0 0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{15}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{16}.tcon.name = 'Surprise Faces > Angry Faces';
    matlabbatch{3}.spm.stats.con.consess{16}.tcon.convec = [0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{16}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{17}.tcon.name = 'Surprise Faces > Neutral Faces';
    matlabbatch{3}.spm.stats.con.consess{17}.tcon.convec = [0 0 1 0 -1];
    matlabbatch{3}.spm.stats.con.consess{17}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{18}.tcon.name = 'Block 1+2 > Block 3+4';
    matlabbatch{3}.spm.stats.con.consess{18}.tcon.convec = [0 .5 .5 -.5 -.5];
    matlabbatch{3}.spm.stats.con.consess{18}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{19}.tcon.name = 'Block 3+4 > Block 1+2';
    matlabbatch{3}.spm.stats.con.consess{19}.tcon.convec = [0 -.5 -.5 .5 .5];
    matlabbatch{3}.spm.stats.con.consess{20}.tcon.name = 'Block 1 > Block 2';
    matlabbatch{3}.spm.stats.con.consess{20}.tcon.convec = [0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{20}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{21}.tcon.name = 'Block 3 > Block 4';
    matlabbatch{3}.spm.stats.con.consess{21}.tcon.convec = [0 0 0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{21}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{22}.tcon.name = 'Block 4 > Block 3';
    matlabbatch{3}.spm.stats.con.consess{22}.tcon.convec = [0 0 0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{22}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{23}.tcon.name = 'Block 2 > Block 1';
    matlabbatch{3}.spm.stats.con.consess{23}.tcon.convec = [0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{23}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{24}.tcon.name = 'Block 2 > Block 3';
    matlabbatch{3}.spm.stats.con.consess{24}.tcon.convec = [0 0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{24}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{25}.tcon.name = 'Block 3 > Block 2';
    matlabbatch{3}.spm.stats.con.consess{25}.tcon.convec = [0 0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{25}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{26}.tcon.name = 'Block 1 > 2 > 3 > 4';
    matlabbatch{3}.spm.stats.con.consess{26}.tcon.convec = [0 .75 .25 -.25 -.75];
    matlabbatch{3}.spm.stats.con.consess{26}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{27}.tcon.name = 'Block 4 > 3 > 2 > 1';
    matlabbatch{3}.spm.stats.con.consess{27}.tcon.convec = [0 -.75 -.25 .25 .75];
    matlabbatch{3}.spm.stats.con.consess{27}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{28}.tcon.name = 'Angry+Fearful > Shapes';
    matlabbatch{3}.spm.stats.con.consess{28}.tcon.convec = [-1 .5 0 .5 0];
    matlabbatch{3}.spm.stats.con.consess{28}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{29}.tcon.name = 'Surprise+Neutral > Shapes';
    matlabbatch{3}.spm.stats.con.consess{29}.tcon.convec = [-1 0 .5 0 .5];
    matlabbatch{3}.spm.stats.con.consess{29}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{30}.tcon.name = 'Angry+Fearful > Surprise+Neutral';
    matlabbatch{3}.spm.stats.con.consess{30}.tcon.convec = [0 .5 -.5 .5 -.5];
    matlabbatch{3}.spm.stats.con.consess{30}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{31}.tcon.name = 'Surprise+Neutral > Angry+Fearful';
    matlabbatch{3}.spm.stats.con.consess{31}.tcon.convec = [0 -.5 .5 -.5 .5];
    matlabbatch{3}.spm.stats.con.consess{31}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{32}.tcon.name = 'Angry+Fearful > Neutral';
    matlabbatch{3}.spm.stats.con.consess{32}.tcon.convec = [0 .5 0 .5 -1];
    matlabbatch{3}.spm.stats.con.consess{32}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{33}.tcon.name = 'Neutral > Angry+Fearful';
    matlabbatch{3}.spm.stats.con.consess{33}.tcon.convec = [0 -.5 0 -.5 1];
    matlabbatch{3}.spm.stats.con.consess{33}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{34}.tcon.name = 'Angry+Fearful > Surprise';
    matlabbatch{3}.spm.stats.con.consess{34}.tcon.convec = [0 .5 -1 .5 0];
    matlabbatch{3}.spm.stats.con.consess{34}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{35}.tcon.name = 'Surprise > Angry+Fearful';
    matlabbatch{3}.spm.stats.con.consess{35}.tcon.convec = [0 -.5 1 -.5 0];
    matlabbatch{3}.spm.stats.con.consess{35}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{36}.tcon.name = 'Shapes > Faces';
    matlabbatch{3}.spm.stats.con.consess{36}.tcon.convec = [1 -.25 -.25 -.25 -.25];
    matlabbatch{3}.spm.stats.con.consess{36}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{37}.fcon.name = 'Effects of Interest';
    matlabbatch{3}.spm.stats.con.consess{37}.fcon.convec = {
                                                           [1 0 0 0 0
                                                           0 1 0 0 0
                                                           0 0 1 0 0
                                                           0 0 0 1 0
                                                           0 0 0 0 1]
                                                           }';
    matlabbatch{3}.spm.stats.con.consess{37}.fcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;

    spm_jobman('run_nogui',matlabbatch); clear matlabbatch;     % Submit the job and clear matlabbatch
end

%% DATA CHECK
% For QA checks, we produce a PDF printout of each subject's data for Faces > Shapes, block design, Positive Feedback > Negative Feedback
% for Cards, and display a T1. In the bash script we then move all files to Graphics / Data_Check /, where Ahmad can click through maps to 
% get an overall idea of data quality.

% Faces Data Check
if strcmp('SUB_RUNFACES_SUB','yes')
    spm('defaults','fmri'); spm_jobman('initcfg');
    cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/Faces/block'));
    matlabbatch{1}.spm.stats.results.spmmat = {'SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB/Faces/block/SPM.mat'};
    matlabbatch{1}.spm.stats.results.conspec.titlestr = 'SUB_SUBJECT_SUB Faces > Shapes';
    matlabbatch{1}.spm.stats.results.conspec.contrasts = 1;
    matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{1}.spm.stats.results.conspec.thresh = 0.001;
    matlabbatch{1}.spm.stats.results.conspec.extent = 10;
    matlabbatch{1}.spm.stats.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
    matlabbatch{1}.spm.stats.results.units = 1;
    matlabbatch{1}.spm.stats.results.print = true;
    spm_jobman('run_nogui',matlabbatch);clear matlabbatch
end

% Cards Data Check
if strcmp('SUB_RUNCARDS_SUB','yes')
    spm('defaults','fmri'); spm_jobman('initcfg');
    cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/cards'))
    matlabbatch{1}.spm.stats.results.spmmat = {'SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB/cards/SPM.mat'};
    matlabbatch{1}.spm.stats.results.conspec.titlestr = 'SUB_SUBJECT_SUB Pos Feedbk > Control';
    matlabbatch{1}.spm.stats.results.conspec.contrasts = 3;
    matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{1}.spm.stats.results.conspec.thresh = 0.001;
    matlabbatch{1}.spm.stats.results.conspec.extent = 10;
    matlabbatch{1}.spm.stats.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
    matlabbatch{1}.spm.stats.results.units = 1;
    matlabbatch{1}.spm.stats.results.print = true;
    spm_jobman('run_nogui',matlabbatch); clear matlabbatch;
end

% T1 Data Check
cd(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/anat'))

if exist('sdns01-0005-00001-000001-01.img','file'); tone = 'sdns01-0005-00001-000001-01.img';
elseif exist('sDNS01-0005-00001-000001-01.img','file'); tone = ('sDNS01-0005-00001-000001-01.img'); end;

if exist('tone','var')
    spm('defaults','fmri'); spm_jobman('initcfg');    
    matlabbatch{1}.spm.util.disp.data = { 'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/' tone };
    spm_jobman('run_nogui',matlabbatch); spm_print; clear matlabbatch;
end


%% CLEANUP and SPM.mat path changing
% Here we go back to the Processed directory, and delete the copied over V000* images, the uV00*, and wuV00* images, to save space.  We
% also go to the output directories and change the SPM.mat paths so they will work on the local machine!

% CARDS
if strcmp('SUB_RUNCARDS_SUB', 'yes')
    cd(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/cards'))
    % If we are only processing functionals, then we don't want to delete the original V00 images, because we probably had to manually re-set the origin
    % and re-align these images to that setting, so we don't want to delete them in case we need them again.
    if strcmp('SUB_ONLYDOFUNC_SUB','no'); delete V0*; end
    delete uV0*; delete wuV0*
    % Fixing paths for cards_pfl SPM.mat
    cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/cards_pfl')); spm_change_paths_swd('/ramSUB_MOUNT_SUB/','SUB_MOUNT_SUB/','N:/DNS.01/','/');
    % Fixing paths for Cards SPM.mat
    cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/Cards')); spm_change_paths('SUB_MOUNT_SUB/','N:/DNS.01/','/');
end

% FACES
if strcmp('SUB_RUNFACES_SUB', 'yes')          
    cd(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/faces'))
    if strcmp('SUB_ONLYDOFUNC_SUB','no'); delete V0*; end
    delete uV0*; delete wuV0*;
    % Fixing paths for faces_pfl
    cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/faces_pfl')); spm_change_paths_swd('/ramSUB_MOUNT_SUB/','SUB_MOUNT_SUB/','N:/DNS.01/','/');
    % Fixing paths for Faces/block
    cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/Faces/block')); spm_change_paths('SUB_MOUNT_SUB/','N:/DNS.01/','/');
    % Fixing paths for Faces/affect
    cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/Faces/affect')); spm_change_paths('SUB_MOUNT_SUB/','N:/DNS.01/','/');
end

% REST
if strcmp('SUB_RUNREST_SUB', 'yes')    
    cd(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/rest'))
    if strcmp('SUB_ONLYDOFUNC_SUB','no'); delete V0*; end
    delete uV0*; delete wuV0*;
    % Fixing paths for rest_pfl
    cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/rest_pfl')); spm_change_paths_swd('/ramSUB_MOUNT_SUB/','SUB_MOUNT_SUB/','N:/DNS.01/','/');
end

exit