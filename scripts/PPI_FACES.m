%-----------------------------------------------------------------------
% DNS PPI FACES BATCH -
%
% These template scripts are filled in and run by a bash script,
% PPI_FACES.sh and PPI_FACES.py from the head node of BIAC
%
% Output contrasts are as follows:
%   1) Shapes Positive PPI                16) Neutral > Shapes Negative PPI
%   2) Shapes Negative PPI                17) Neutral Positive PPI
%   3) Faces > Shapes Positive PPI        18) Neutral Negative PPI
%   4) Faces > Shapes Negative PPI        19) Surprise > Shapes Positive PPI
%   5) Positive Functional Connectivity   20) Surprise > Shapes Negative PPI
%   6) Negative Functional Connectivity   21) Surprise Positive PPI
%   7) Fear > Shapes Positive PPI         22) Surprise Negative PPI
%   8) Fear > Shapes Negative PPI         23) Fear PPI > Neutral PPI
%   9) Fear Positive PPI                  24) Neutral PPI > Fear PPI
%   10) Fear Negative PPI                 25) Angry PPI > Neutral PPI
%   11) Anger > Shapes Positive PPI       26) Neutral PPI > Angry PPI
%   12) Anger > Shapes Negative PPI       27) Surprise PPI > Neutral PPI
%   13) Anger Positive PPI                28) Neutral PPI > Surprise PPI
%   14) Anger Negative PPI                29) All Faces Positive PPI
%   15) Neutral > Shapes Positive PPI     30) All Faces Negative PPI
%
% The script does the following:
% 1) Creates a VOI - extracted mean time series based on a seed ROI.  The PPI 
% button calls a script called spm_peb_ppi, so we basically call this script
% with input variables, one of them being to suppress graphical output.
% However, a window is still opened, so it's important to have a virtual
% display running when using this on the cluster.
% 2) For each PPI run - the PPI script outputs both a PPI_name.mat, and a 
% variable called PPI_condition.  A PPI analysis is done for each faces
% condition (shapes, fear, anger, surprise, and neutral). The extracted values 
% that we want to use are under PPI.ppi, PPI.Y, PPI.P.  PPI.Y, the seed
% activity, only needs to be used from one of the PPI runs.
% 3) It then sets up single subject analysis with faces and each PPI run 
% for each specified condition as a regressor (see regressor section for
% details.  Additionally, we feed in the ART motion outliers 
% from the previous faces analysis, since we use the same swu images.
% 4) We lastly change paths in the SPM.mat from cluster to local
%
%    The Laboratory of Neurogenetics, 2010
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

if strcmp('SUB_TASK_SUB','faces'); cd(horzcat(SPMdir,'SUB_SUBJECT_SUB/Faces/block/')); else error('The only working task is currently faces!'); end

% We need to manipulate an SPM.mat that has a local (NOT a cluster) path - so we actually need to change the path from local --> cluster, and then
% undo it at the end of the script!
spm_change_paths_swd_reverse('/ramSUB_MOUNT_SUB/','SUB_MOUNT_SUB/','N:/DNS.01/','/')

% Initialize spm jobman
spm('defaults','fmri'); spm_jobman('initcfg'); 

% PREPARE VOI
matlabbatch{1}.spm.util.voi.spmmat = {horzcat(SPMdir,'SUB_SUBJECT_SUB/Faces/block/SPM.mat')};
matlabbatch{1}.spm.util.voi.adjust = SUB_ADJUSTDATA_SUB;
matlabbatch{1}.spm.util.voi.session = SUB_SESSION_SUB;
matlabbatch{1}.spm.util.voi.name = 'SUB_VOINAME_SUB';

% Regions of interest - Thresholded SPM.mat (must be included)
matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {horzcat(SPMdir,'SUB_SUBJECT_SUB/Faces/block/SPM.mat')};
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
if strcmp('SUB_TASK_SUB','faces'); cd(horzcat(SPMdir,'SUB_SUBJECT_SUB/Faces/block/')); else error('The only working task is currently faces!'); end
copyfile(roi,'VOI.mat')  % copies the ROI as VOI.mat - what we need it to be!
load SPM.mat             % load the SPM.mat as a variable called SPM

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUNNING PPI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First we must set our matrices, depending on the order number. SUB_ORDER_SUB feeds in the order number from the higher level scripts
% The bash script checks that the order number is 1,2,3, or 4. The format of these matrices is [condition#,session#,weight]

%Order #     Shapes	All Faces	                Anger	Surprise Fear   Neutral
%1 (FNAS)	[1,1,1]	[2,1,1;3,1,1;4,1,1;5,1,1]	[4,1,1]	[5,1,1]	[2,1,1]	[3,1,1]
%2 (NFSA)	[1,1,1]	[2,1,1;3,1,1;4,1,1;5,1,1]	[5,1,1]	[4,1,1]	[3,1,1]	[2,1,1]
%3 (ASFN)	[1,1,1]	[2,1,1;3,1,1;4,1,1;5,1,1]	[2,1,1]	[3,1,1]	[4,1,1]	[5,1,1]
%4 (SANF)	[1,1,1]	[2,1,1;3,1,1;4,1,1;5,1,1]	[3,1,1]	[2,1,1]	[5,1,1]	[4,1,1]

switch 'SUB_ORDER_SUB'
    case '1' %FNAS
        fear_matrix=[2,1,1];
        anger_matrix=[4,1,1];
        neutral_matrix=[3,1,1];
        surprise_matrix=[5,1,1];
    case '2' % NFSA
        fear_matrix=[3,1,1];
        anger_matrix=[5,1,1];
        neutral_matrix=[2,1,1];
        surprise_matrix=[4,1,1];    
    case '3' % ASFN
        fear_matrix=[4,1,1];
        anger_matrix=[2,1,1];
        neutral_matrix=[5,1,1];
        surprise_matrix=[3,1,1];
    case '4' % SANF
        fear_matrix=[5,1,1];
        anger_matrix=[3,1,1];
        neutral_matrix=[4,1,1];
        surprise_matrix=[2,1,1];
end
        
% The shapes matrix is the same for all subjects        
shapes_matrix=[1,1,1];
allfaces_matrix=[2,1,1;3,1,1;4,1,1;5,1,1];

% To process faces for multiple design types, we must prepare PPI for each of 1) Shapes, 2) All Faces, 3) Angry, 4) Surprise, 5) Fearful, 6)
% Neutral.  ALL of these will get fed into the single subject analysis as regressors, however the PPI.Y only needs to go in once.
if strcmp('SUB_TASK_SUB','faces')
    % Use the script to run PPI without a GUI, and print the output as we go
    % PPI = spm_peb_ppi(SPM.mat,'type of analysis','VOI in .mat form','matrix of inputs','output name',0=no gui!)
    PPIshapes =     spm_peb_ppi(SPM,'ppi','VOI.mat',shapes_matrix,'SUB_OUTPUT_SUB_shapes.mat',1); print -dtiff -noui SUB_OUTPUT_SUB_shapes.JPG;
    PPIallfaces =   spm_peb_ppi(SPM,'ppi','VOI.mat',allfaces_matrix,'SUB_OUTPUT_SUB_allfaces.mat',1); print -dtiff -noui SUB_OUTPUT_SUB_allfaces.JPG;
    PPIfear =       spm_peb_ppi(SPM,'ppi','VOI.mat',fear_matrix,'SUB_OUTPUT_SUB_fear.mat',1); print -dtiff -noui SUB_OUTPUT_SUB_fear.JPG;
    PPIanger =      spm_peb_ppi(SPM,'ppi','VOI.mat',anger_matrix,'SUB_OUTPUT_SUB_anger.mat',1); print -dtiff -noui SUB_OUTPUT_SUB_anger.JPG;
    PPIneutral =    spm_peb_ppi(SPM,'ppi','VOI.mat',neutral_matrix,'SUB_OUTPUT_SUB_neutral.mat',1); print -dtiff -noui SUB_OUTPUT_SUB_neutral.JPG;
    PPIsurprise =   spm_peb_ppi(SPM,'ppi','VOI.mat',surprise_matrix,'SUB_OUTPUT_SUB_surprise.mat',1); print -dtiff -noui SUB_OUTPUT_SUB_surprise.JPG;
    
    % move the output PPI and VOI files into the output folder so we can look at them later
    copyfile('PPI_SUB_OUTPUT_SUB_shapes.mat',output); copyfile('SUB_OUTPUT_SUB_shapes.JPG',output); delete('PPI_SUB_OUTPUT_SUB_shapes.mat'); delete('SUB_OUTPUT_SUB_shapes.JPG');
    copyfile('PPI_SUB_OUTPUT_SUB_allfaces.mat',output); copyfile('SUB_OUTPUT_SUB_allfaces.JPG',output); delete('PPI_SUB_OUTPUT_SUB_allfaces.mat'); delete('SUB_OUTPUT_SUB_allfaces.JPG');
    copyfile('PPI_SUB_OUTPUT_SUB_fear.mat',output); copyfile('SUB_OUTPUT_SUB_fear.JPG',output); delete('PPI_SUB_OUTPUT_SUB_fear.mat'); delete('SUB_OUTPUT_SUB_fear.JPG');
    copyfile('PPI_SUB_OUTPUT_SUB_anger.mat',output); copyfile('SUB_OUTPUT_SUB_anger.JPG',output); delete('PPI_SUB_OUTPUT_SUB_anger.mat'); delete('SUB_OUTPUT_SUB_anger.JPG');
    copyfile('PPI_SUB_OUTPUT_SUB_neutral.mat',output); copyfile('SUB_OUTPUT_SUB_neutral.JPG',output); delete('PPI_SUB_OUTPUT_SUB_neutral.mat'); delete('SUB_OUTPUT_SUB_neutral.JPG');
    copyfile('PPI_SUB_OUTPUT_SUB_surprise.mat',output); copyfile('SUB_OUTPUT_SUB_surprise.JPG',output); delete('PPI_SUB_OUTPUT_SUB_surprise.mat'); delete('SUB_OUTPUT_SUB_surprise.JPG');
    copyfile('VOI.mat',output); delete('VOI.mat');

else error('The only working task is currently faces!');
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

if strcmp('SUB_TASK_SUB','faces')

    % Initialize jobman
    spm('defaults','fmri'); spm_jobman('initcfg'); 

    matlabbatch{1}.spm.stats.fmri_design.dir = {output};
    matlabbatch{1}.spm.stats.fmri_design.timing.units = 'scans';
    matlabbatch{1}.spm.stats.fmri_design.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_design.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_design.timing.fmri_t0 = 1;
    matlabbatch{1}.spm.stats.fmri_design.sess.nscan = 195;
    matlabbatch{1}.spm.stats.fmri_design.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {});
    matlabbatch{1}.spm.stats.fmri_design.sess.multi = {''};

    % Here are the regression outliers - we only need the Seed Activity (PPIshapes.Y) once
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(1).name = 'PPI Shapes';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(1).val = PPIshapes.ppi;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(2).name = 'Shapes Conditions';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(2).val = PPIshapes.P;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(3).name = 'PPI Fear';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(3).val = PPIfear.ppi;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(4).name = 'Fear Conditions';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(4).val = PPIfear.P;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(5).name = 'PPI Anger';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(5).val = PPIanger.ppi;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(6).name = 'Anger Conditions';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(6).val = PPIanger.P;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(7).name = 'PPI Neutral';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(7).val = PPIneutral.ppi;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(8).name = 'Neutral Conditions';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(8).val = PPIneutral.P;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(9).name = 'PPI Surprise';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(9).val = PPIsurprise.ppi;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(10).name = 'Surprise Conditions';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(10).val = PPIsurprise.P;
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(11).name = 'Seed Activity';
    matlabbatch{1}.spm.stats.fmri_design.sess.regress(11).val = PPIshapes.Y;

    % Here is the path to the art regression outliers
    matlabbatch{1}.spm.stats.fmri_design.sess.multi_reg = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/faces/art_regression_outliers_swuV0001.mat'};
    matlabbatch{1}.spm.stats.fmri_design.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_design.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_design.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_design.volt = 1;
    matlabbatch{1}.spm.stats.fmri_design.global = 'None';
    matlabbatch{1}.spm.stats.fmri_design.cvi = 'AR(1)';

    % Get swuV000 images
        V00img=dir(fullfile('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/SUB_TASK_SUB/swuV0*.img')); numimages = 195;
        for j=1:numimages; imagearray{j}=horzcat('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/SUB_TASK_SUB/',V00img(j).name,',1'); end; clear V00img;

    matlabbatch{2}.spm.stats.fmri_data.scans = imagearray;
    matlabbatch{2}.spm.stats.fmri_data.spmmat = {horzcat(output,'SPM.mat')};
    matlabbatch{2}.spm.stats.fmri_data.mask = {''};
    matlabbatch{3}.spm.stats.fmri_est.spmmat = {horzcat(output,'SPM.mat')};
    matlabbatch{3}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{4}.spm.stats.con.spmmat = {horzcat(output,'SPM.mat')};

    %[PPIshapes Condshapes PPIfear Condfear PPIanger Condanger PPIneutral Condneutral PPIsurprise Condsurprise SeedActivity]
    matlabbatch{4}.spm.stats.con.consess{1}.tcon.name = 'Shapes Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{1}.tcon.convec = 1;
    matlabbatch{4}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{2}.tcon.name = 'Shapes Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{2}.tcon.convec = -1;
    matlabbatch{4}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{3}.tcon.name = 'Faces > Shapes Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{3}.tcon.convec = [-4 0 1 0 1 0 1 0 1];
    matlabbatch{4}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{4}.tcon.name = 'Faces > Shapes Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{4}.tcon.convec = [4 0 -1 0 -1 0 -1 0 -1];
    matlabbatch{4}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{5}.tcon.name = '(+) Functional Connectivity';
    matlabbatch{4}.spm.stats.con.consess{5}.tcon.convec = [0 0 0 0 0 0 0 0 0 0 1];
    matlabbatch{4}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{6}.tcon.name = '(-) Functional Connectivity';
    matlabbatch{4}.spm.stats.con.consess{6}.tcon.convec = [0 0 0 0 0 0 0 0 0 0 -1];
    matlabbatch{4}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{7}.tcon.name = 'Fear > Shapes Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{7}.tcon.convec = [-1 0 1];
    matlabbatch{4}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{8}.tcon.name = 'Fear > Shapes Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{8}.tcon.convec = [1 0 -1];
    matlabbatch{4}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{9}.tcon.name = 'Fear Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{9}.tcon.convec = [0 0 1];
    matlabbatch{4}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{10}.tcon.name = 'Fear Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{10}.tcon.convec = [0 0 -1];
    matlabbatch{4}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{11}.tcon.name = 'Anger > Shapes Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{11}.tcon.convec = [-1 0 0 0 1];
    matlabbatch{4}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{12}.tcon.name = 'Anger > Shapes Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{12}.tcon.convec = [1 0 0 0 -1];
    matlabbatch{4}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{13}.tcon.name = 'Anger Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{13}.tcon.convec = [0 0 0 0 1];
    matlabbatch{4}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{14}.tcon.name = 'Anger Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{14}.tcon.convec = [0 0 0 0 -1];
    matlabbatch{4}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{15}.tcon.name = 'Neutral > Shapes Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{15}.tcon.convec = [-1 0 0 0 0 0 1];
    matlabbatch{4}.spm.stats.con.consess{15}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{16}.tcon.name = 'Neutral > Shapes Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{16}.tcon.convec = [1 0 0 0 0 0 -1];
    matlabbatch{4}.spm.stats.con.consess{16}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{17}.tcon.name = 'Neutral Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{17}.tcon.convec = [0 0 0 0 0 0 1];
    matlabbatch{4}.spm.stats.con.consess{17}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{18}.tcon.name = 'Neutral Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{18}.tcon.convec = [0 0 0 0 0 0 -1];
    matlabbatch{4}.spm.stats.con.consess{18}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{19}.tcon.name = 'Surprise > Shapes Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{19}.tcon.convec = [-1 0 0 0 0 0 0 0 1];
    matlabbatch{4}.spm.stats.con.consess{19}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{20}.tcon.name = 'Surprise > Shapes Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{20}.tcon.convec = [1 0 0 0 0 0 0 0 -1];
    matlabbatch{4}.spm.stats.con.consess{20}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{21}.tcon.name = 'Surprise Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{21}.tcon.convec = [0 0 0 0 0 0 0 0 1];
    matlabbatch{4}.spm.stats.con.consess{21}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{22}.tcon.name = 'Surprise Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{22}.tcon.convec = [0 0 0 0 0 0 0 0 -1];
    matlabbatch{4}.spm.stats.con.consess{22}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{23}.tcon.name = 'Fear PPI > Neutral PPI';
    matlabbatch{4}.spm.stats.con.consess{23}.tcon.convec = [0 0 1 0 0 0 -1];
    matlabbatch{4}.spm.stats.con.consess{23}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{24}.tcon.name = 'Neutral PPI > Fear PPI';
    matlabbatch{4}.spm.stats.con.consess{24}.tcon.convec = [0 0 -1 0 0 0 1];
    matlabbatch{4}.spm.stats.con.consess{24}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{25}.tcon.name = 'Angry PPI > Neutral PPI';
    matlabbatch{4}.spm.stats.con.consess{25}.tcon.convec = [0 0 0 0 1 0 -1];
    matlabbatch{4}.spm.stats.con.consess{25}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{26}.tcon.name = 'Neutral PPI > Angry PPI';
    matlabbatch{4}.spm.stats.con.consess{26}.tcon.convec = [0 0 0 0 -1 0 1];
    matlabbatch{4}.spm.stats.con.consess{26}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{27}.tcon.name = 'Surprise PPI > Neutral PPI';
    matlabbatch{4}.spm.stats.con.consess{27}.tcon.convec = [0 0 0 0 0 0 -1 0 1];
    matlabbatch{4}.spm.stats.con.consess{27}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{28}.tcon.name = 'Neutral PPI > Surprise PPI';
    matlabbatch{4}.spm.stats.con.consess{28}.tcon.convec = [0 0 0 0 0 0 1 0 -1];
    matlabbatch{4}.spm.stats.con.consess{28}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{29}.tcon.name = 'All Faces Positive PPI';
    matlabbatch{4}.spm.stats.con.consess{29}.tcon.convec = [0 0 .25 0 .25 0 .25 0 .25];
    matlabbatch{4}.spm.stats.con.consess{29}.tcon.sessrep = 'none';
    matlabbatch{4}.spm.stats.con.consess{30}.tcon.name = 'All Faces Negative PPI';
    matlabbatch{4}.spm.stats.con.consess{30}.tcon.convec = [0 0 -.25 0 -.25 0 -.25 0 -.25];
    matlabbatch{4}.spm.stats.con.consess{30}.tcon.sessrep = 'none';
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

if strcmp('SUB_TASK_SUB','faces')
    cd(horzcat(SPMdir,'SUB_SUBJECT_SUB/Faces/block/'));
    spm_change_paths_swd('/ramSUB_MOUNT_SUB/','SUB_MOUNT_SUB/','N:/DNS.01/','/');
end

exit