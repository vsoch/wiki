%-----------------------------------------------------------------------
% DNS PPI CARDS BATCH -
%
% These template scripts are filled in and run by a bash script,
% PPI_CARDS.sh and PPI_CARDS.py from the head node of BIAC
%
% Output contrasts are as follows:
%   1) (+) Functional Connectivity               
%   2) (-) Functional Connectivity               
%   3) Control Positive PPI        
%   4) Control Negative PPI     
%   5) PosFeedback Positive PPI   
%   6) PosFeedback Negative PPI   
%   7) NegFeedback Positive PPI         
%   8) NegFeedback Negative PPI         
%   9) PosFeedback > NegFeedback Positive PPI                 
%   10) PosFeedback > NegFeedback Negative PPI                
%   11) PosFeedback > Control Positive PPI      
%   12) PosFeedback > Control Negative PPI      
%   13) NegFeedback > Control Positive PPI               
%   14) NegFeedback > Control Negative PPI              
%
% The script does the following:
% 1) Creates a VOI - extracted mean time series based on a seed ROI.  The PPI 
% button calls a script called spm_peb_ppi, so we basically call this script
% with input variables, one of them being to suppress graphical output.
% However, a window is still opened, so it's important to have a virtual
% display running when using this on the cluster.
% 2) For each PPI run - the PPI script outputs both a PPI_name.mat, and a 
% variable called PPI_condition.  A PPI analysis is done for each cards
% condition (positive, negative, and control). The extracted values that 
% we want to use are under PPI.ppi, PPI.Y, PPI.P.  PPI.Y, the seed
% activity, only needs to be used from one of the PPI runs.
% 3) It then sets up single subject analysis with cards and each PPI run 
% for each specified condition as a regressor (see regressor section for
% details.  Additionally, we feed in the ART motion outliers 
% from the previous cards analysis, since we use the same swu images.
% 4) We lastly change paths in the SPM.mat from cluster to local
%
%    The Laboratory of Neurogenetics, 2011
%       By Vanessa Sochat, Duke University
%-----------------------------------------------------------------------

% Add necessary BIAC and SPM paths
BIACroot = 'SUB_BIACROOT_SUB'; startm=fullfile(BIACroot,'startup.m');
if exist(startm,'file');  run(startm); else warning(sprintf(['Unable to locate central BIAC startup.m file\n  (%s).\n Connect to network or set BIACMATLABROOT environment variable.\n'],startm)); end; clear startm BIACroot

% Subject specific paths
addpath(genpath('SUB_SCRIPTDIR_SUB')); addpath(genpath('/usr/local/packages/MATLAB/spm8')); 
addpath(genpath('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB'));
addpath(genpath('SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB'));

%Here we set some directory variables to make navigation easier
homedir='SUB_MOUNT_SUB/Analysis/SPM/'; SPMdir='SUB_MOUNT_SUB/Analysis/SPM/Analyzed/'; output=horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/PPI/SUB_CONTRAST_SUB/SUB_OUTPUT_SUB/');

%-------------------------------------------------------------------------
% Create the individual ROI based on user input:
%--------------------------------------------------------------------------

if strcmp('SUB_TASK_SUB','cards'); cd(horzcat(SPMdir,'SUB_SUBJECT_SUB/cards/')); else error('The only working task is currently cards!'); end

% We need to manipulate an SPM.mat that has a local (NOT a cluster) path - so we actually need to change the path from local --> cluster, and then
% undo it at the end of the script!
spm_change_paths_swd_reverse('/ramSUB_MOUNT_SUB/','SUB_MOUNT_SUB/','N:/DNS.01/','/')

% Initialize spm jobman
spm('defaults','fmri'); spm_jobman('initcfg'); 

% PREPARE VOI
matlabbatch{1}.spm.util.voi.spmmat = {horzcat(SPMdir,'SUB_SUBJECT_SUB/cards/SPM.mat')};
matlabbatch{1}.spm.util.voi.adjust = SUB_ADJUSTDATA_SUB;
matlabbatch{1}.spm.util.voi.session = SUB_SESSION_SUB;
matlabbatch{1}.spm.util.voi.name = 'SUB_VOINAME_SUB';

% Regions of interest - Thresholded SPM.mat (must be included)
matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {horzcat(SPMdir,'SUB_SUBJECT_SUB/cards/SPM.mat')};
matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = SUB_CONTRASTNO_SUB;
matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'SUB_THRESHDESC_SUB'; %FWE or none
matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = SUB_THETHRESHOLD_SUB;
matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = SUB_EXTENT_SUB;

% If the user wants to mask with another contrast
if strcmp('SUB_MASKOTHER_SUB','yes')
    matlabbatch{1}.spm.util.voi.roi{1}.spm.mask.contrast = SUB_MASKOTHERCON_SUB; 
    matlabbatch{1}.spm.util.voi.roi{1}.spm.mask.thresh = SUB_MASKOTHERTHRESH_SUB;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.mask.mtype = SUB_MASKOTHERINCLUSIVE_SUB;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
end

% Here we specify if the user wants to create a sphere, a box, or use a mask.  Since we only make one VOI / PPI analysis, we use a switch
% statement so the user can only select ONE.  It is currently set up so the center of these regions is FIXED - Vanessa would need to add the
% functionality to the script to select a local maxima, global maxima, etc.

switch 'SUB_VOIMASKTYPE_SUB'
    case 'sphere'
        matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre = [SUB_SPHERECENTERX_SUB SUB_SPHERECENTERY_SUB SUB_SPHERECENTERZ_SUB];
        matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius = SUB_SPHERERADIUS_SUB;
        matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
    case 'box'
        matlabbatch{1}.spm.util.voi.roi{2}.box.centre = [SUB_BOXCENTERX_SUB SUB_BOXCENTERY_SUB SUB_BOXCENTERZ_SUB];
        matlabbatch{1}.spm.util.voi.roi{2}.box.dim = [SUB_BOXDIMX_SUB SUB_BOXDIMY_SUB SUB_BOXDIMX_SUB];
        matlabbatch{1}.spm.util.voi.roi{2}.box.move.fixed = 1;
    case 'mask'
        matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {horzcat(homedir,'ROI/PPI/SUB_CONTRAST_SUB/SUB_INCLUDEDSUB_SUB/SUB_VOIMASK_SUB')};
        matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = SUB_VOIMASKTHRESH_SUB;
    otherwise
        error('VOI mask type was incorrectly specified.  Must be sphere, box, or mask!');
end
matlabbatch{1}.spm.util.voi.expression = 'i1 & i2';
spm_jobman('run_nogui',matlabbatch)   % Run the job
clear matlabbatch;                    % Clear matlabbatch

% EMPTY REGIONS
% In the case that the subject has an "empty region" - meaning that no voxels survive the thresholding at the specific ROI, the VOI creation
% wouldn't have occurred, and in this case we do not want to continue with the script!  We test for the existence of the VOI output file to
% determine this.  In the case that it doesn't exist, we change the paths back in the SPM.mat, output a text file that indicates the region was
% empty, and exit the script.
if exist('VOI_SUB_VOINAME_SUB_1.mat','file')==0
    spm_change_paths_swd('/ramSUB_MOUNT_SUB/','SUB_MOUNT_SUB/','N:/DNS.01/','/');
    cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/VOIs/SUB_CONTRAST_SUB/'));
    fid = fopen('EMPTY REGIONS.txt', 'a');
    fprintf(fid, '\n');
    fprintf(fid, '%s%s', date, ': SUB_VOINAME_SUB for SUB_CONTRAST_SUB at SUB_THETHRESHOLD_SUB threshtype: SUB_THRESHDESC_SUB extent: SUB_EXTENT_SUB');
    fclose(fid);
    exit
end  

% After we create the VOI, we copy it (also with the image) to the subject's VOI directory, and set it in a variable to be applied
copyfile('VOI_SUB_VOINAME_SUB_1.mat',horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/VOIs/SUB_CONTRAST_SUB/VOI_SUB_VOINAME_SUB.mat'));
copyfile('VOI_SUB_VOINAME_SUB.img',horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/VOIs/SUB_CONTRAST_SUB/VOI_SUB_VOINAME_SUB.img'));
copyfile('VOI_SUB_VOINAME_SUB.hdr',horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/VOIs/SUB_CONTRAST_SUB/VOI_SUB_VOINAME_SUB.hdr'));
roi=horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/VOIs/SUB_CONTRAST_SUB/VOI_SUB_VOINAME_SUB.mat');
delete('VOI_SUB_VOINAME_SUB_1.mat');
delete('VOI_SUB_VOINAME_SUB.img');
delete('VOI_SUB_VOINAME_SUB.hdr');

%-------------------------------------------------------------------------
% Extract values for ROI (Using PPI Button in SPM)
%--------------------------------------------------------------------------

%This part of the script extracts and calcuates mean time series from the seed roi.  

% CD to the single subject directory of the task specified
if strcmp('SUB_TASK_SUB','cards'); cd(horzcat(SPMdir,'SUB_SUBJECT_SUB/cards/')); else error('The only working task is currently cards!'); end
copyfile(roi,'VOI.mat')  % copies the ROI as VOI.mat - what we need it to be!
load SPM.mat             % load the SPM.mat as a variable called SPM

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUNNING PPI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First we must set our matrices. The format of these matrices is [condition#,session#,weight]

% Positive Feedback     Negative Feedback     Control
% [2,1,1]               [3,1,1]               [1,1,1] 

positivefbk = [2,1,1];
negativefbk = [3,1,1];
control_mat = [1,1,1];

% To process cards for multiple design types, we must prepare PPI for each of 1) Positive Feedback, 2) Negative Feedback, 3) Control
% ALL of these will get fed into the single subject analysis as regressors, however the PPI.Y only needs to go in once.
if strcmp('SUB_TASK_SUB','cards')
    % Use the script to run PPI without a GUI, and print the output as we go
    % PPI = spm_peb_ppi(SPM.mat,'type of analysis','VOI in .mat form','matrix of inputs','output name',0=no gui!)
    PPIpos =   spm_peb_ppi(SPM,'ppi','VOI.mat',positivefbk,'SUB_OUTPUT_SUB_pos.mat',1); print -dtiff -noui SUB_OUTPUT_SUB_pos.JPG;
    PPIneg =   spm_peb_ppi(SPM,'ppi','VOI.mat',negativefbk,'SUB_OUTPUT_SUB_neg.mat',1); print -dtiff -noui SUB_OUTPUT_SUB_neg.JPG;
    PPIcon =   spm_peb_ppi(SPM,'ppi','VOI.mat',control_mat,'SUB_OUTPUT_SUB_con.mat',1); print -dtiff -noui SUB_OUTPUT_SUB_con.JPG;
    
    % move the output PPI and VOI files into the output folder so we can look at them later
    copyfile('PPI_SUB_OUTPUT_SUB_pos.mat',output); copyfile('SUB_OUTPUT_SUB_pos.JPG',output); delete('PPI_SUB_OUTPUT_SUB_pos.mat'); delete('SUB_OUTPUT_SUB_pos.JPG');
    copyfile('PPI_SUB_OUTPUT_SUB_neg.mat',output); copyfile('SUB_OUTPUT_SUB_neg.JPG',output); delete('PPI_SUB_OUTPUT_SUB_neg.mat'); delete('SUB_OUTPUT_SUB_neg.JPG');
    copyfile('PPI_SUB_OUTPUT_SUB_con.mat',output); copyfile('SUB_OUTPUT_SUB_con.JPG',output); delete('PPI_SUB_OUTPUT_SUB_con.mat'); delete('SUB_OUTPUT_SUB_con.JPG');
    copyfile('VOI.mat',output); delete('VOI.mat');

else error('The only working task is currently cards!');
end


%-------------------------------------------------------------------------
% Single Subject Analysis
%--------------------------------------------------------------------------
% Lastly we need to run the analysis with these extracted values as a covariate.  This script is configured for FACES.  If you want
% another task, you will need to add it!

%-------------------------------------------------------------------------
% Faces (note that conditions and contrasts are block) which vary based on 
% the order number specified by the user
%--------------------------------------------------------------------------
cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/PPI/SUB_CONTRAST_SUB/SUB_OUTPUT_SUB/'));

if strcmp('SUB_TASK_SUB','cards')

    % Initialize jobman
    spm('defaults','fmri'); spm_jobman('initcfg'); 

    matlabbatch{1}.spm.stats.fmri_design.dir = {output};
    matlabbatch{1}.spm.stats.fmri_design.timing.units = 'scans';
    matlabbatch{1}.spm.stats.fmri_design.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_design.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_design.timing.fmri_t0 = 1;
    matlabbatch{1}.spm.stats.fmri_design.sess.nscan = 171;
    matlabbatch{1}.spm.stats.fmri_design.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {});
    matlabbatch{1}.spm.stats.fmri_design.sess.multi = {''};

    % Here are the regression outliers - we only need the Seed Activity (PPIcon.Y) once
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(1).name = 'PPI Control';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(1).val = PPIcon.ppi;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(2).name = 'Control Conditions';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(2).val = PPIcon.P;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(3).name = 'PPI Positive Feedback';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(3).val = PPIpos.ppi;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(4).name = 'Positive Feedback Conditions';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(4).val = PPIpos.P;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(5).name = 'PPI Negative Feedback';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(5).val = PPIneg.ppi;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(6).name = 'Negative Feedback Conditions';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(6).val = PPIneg.P;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(7).name = 'Seed Activity';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(7).val = PPIcon.Y;

    % Here is the path to the art regression outliers
    matlabbatch{1}.spm.stats.fmri_design.sess.multi_reg = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/cards/art_regression_outliers_swuV0001.mat'};
    matlabbatch{1}.spm.stats.fmri_design.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_design.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_design.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_design.volt = 1;
    matlabbatch{1}.spm.stats.fmri_design.global = 'None';
    matlabbatch{1}.spm.stats.fmri_design.cvi = 'AR(1)';

    % Get swuV000 images
        V00img=dir(fullfile('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/SUB_TASK_SUB/swuV0*.img')); numimages = 171;
        for j=1:numimages; imagearray{j}=horzcat('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/SUB_TASK_SUB/',V00img(j).name,',1'); end; clear V00img;

    matlabbatch{2}.spm.stats.fmri_data.scans = imagearray;
    matlabbatch{2}.spm.stats.fmri_data.spmmat = {horzcat(output,'SPM.mat')};
    matlabbatch{2}.spm.stats.fmri_data.mask = {''};
    matlabbatch{3}.spm.stats.fmri_est.spmmat = {horzcat(output,'SPM.mat')};
    matlabbatch{3}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{4}.spm.stats.con.spmmat = {horzcat(output,'SPM.mat')};

    %[PPIcontrol Condcontrol PPIPositiveFbk CondPositiveFbk PPINegativeFbk CondNegativeFbk SeedActivity]
    matlabbatch{4}.spm.stats.con.consess{1}.tcon.name = '(+) Functional Connectivity';
    matlabbatch{4}.spm.stats.con.consess{1}.tcon.convec = [0 0 0 0 0 0 1];
    matlabbatch{4}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{2}.tcon.name = '(-) Functional Connectivity';
    matlabbatch{4}.spm.stats.con.consess{2}.tcon.convec = [0 0 0 0 0 0 -1];
    matlabbatch{4}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{3}.tcon.name = 'Control Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{3}.tcon.convec = 1;
    matlabbatch{4}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{4}.tcon.name = 'Control Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{4}.tcon.convec = -1;
    matlabbatch{4}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{5}.tcon.name = 'PosFeedback Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{5}.tcon.convec = [0 0 1];
    matlabbatch{4}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{6}.tcon.name = 'PosFeedback Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{6}.tcon.convec = [0 0 -1];
    matlabbatch{4}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{7}.tcon.name = 'NegFeedback Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{7}.tcon.convec = [0 0 0 0 1];
    matlabbatch{4}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{8}.tcon.name = 'NegFeedback Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{8}.tcon.convec = [0 0 0 0 -1];
    matlabbatch{4}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{9}.tcon.name = 'PosFeedback > NegFeedback Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{9}.tcon.convec = [0 0 1 0 -1];
    matlabbatch{4}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{10}.tcon.name = 'PosFeedback > NegFeedback Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{10}.tcon.convec = [0 0 -1 0 1];
    matlabbatch{4}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{11}.tcon.name = 'PosFeedback > Control Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{11}.tcon.convec = [-1 0 1];
    matlabbatch{4}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{12}.tcon.name = 'PosFeedback > Control Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{12}.tcon.convec = [1 0 -1];
    matlabbatch{4}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{13}.tcon.name = 'NegFeedback > Control Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{13}.tcon.convec = [-1 0 0 0 1];
    matlabbatch{4}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{14}.tcon.name = 'NegFeedback > Control Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{14}.tcon.convec = [1 0 0 0 -1];
    matlabbatch{4}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.delete = 0;

    % Run the job and clear matlabbatch
    spm_jobman('run_nogui',matlabbatch); clear matlabbatch imagearray;

end

%--------------------------------------------------------------------------
% Clean Up
%--------------------------------------------------------------------------

% Lastly, we want to change the paths in spm.mat from cluster to run on the local machine.

% Fixing paths for SPM.mat under new PPI directory
cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB/PPI/SUB_CONTRAST_SUB/SUB_OUTPUT_SUB/'));
spm_change_paths_swd('SUB_MOUNT_SUB/','SUB_MOUNT_SUB/','N:/DNS.01/','/');

% Fixing paths for SPM.mat under task

if strcmp('SUB_TASK_SUB','cards')
    cd(horzcat(SPMdir,'SUB_SUBJECT_SUB/cards/'));
    spm_change_paths_swd('/ramSUB_MOUNT_SUB/','SUB_MOUNT_SUB/','N:/DNS.01/','/');
end

exit