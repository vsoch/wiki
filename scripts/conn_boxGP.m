%--------------------------------------------------------------------------
% CONN_BOXGP: This script is a template used by spm_RESTGP.sh and 
% spm_RESTGP.py on the cluster.  It sets up a new ICA analysis for resting 
% bold data for DNS, and then runs the job using the Rest Toolbox developed 
% at MIT.  It is run once for an entire group of subjects, and comes after
% single subject runs using conn_boxSS.m
%
%--------------------------------------------------------------------------
% DEPENDENCIES: 
% - The connectivity toolbox should be in a folder called "Tools" within 
% the Scripts directory in the Experiment directory.
% - ROI's should be placed in ROI/Rest_toolbox.  The names of the
% individual ROIs that we want to use are specified as a list in the python
% script.
%--------------------------------------------------------------------------
% OVERVIEW:

% DATA CHECK
% Since a single analysis with 100+ subjects could take many hours to run,
% before we even get to this script the bash script checks that all of the
% subjects we are running have existing rest swua* images and anatomical
% images that have been normalized.  In the case that anyone has data missing, 
% the script exits and does not continue to produce this template matlab script.
%
% MATLAB PATHS SETUP
% Add paths to the connectivity toolbox (DNS.01/Scripts/Tools), spm8, and
% all subject's Processed and Analyzed directories. (DO I WANT TO ADD PATH
% TO ALL DIRECTORIES? MIGHT SLOW DOWN SCRIPT SUBSTANTIALLY)
 
% DIRECTORY CREATION
% Again checks that we have rest output directory, and swu* images and motion
% regressor file for each subject.  Checks for the anatomical folder, and 
% the anatomical normalized files (grey, white, and csf, and raw) for each
% subject.

% 1) Raw anatomical, grey, white, and csf normalized under SUBJECT/anat/anat_rest 
% 2) Motion regressor file is SUBJECT/rest/rp_aV0001.txt
% 3) Normalized and slice timed images are under Processed/SUBJECT/rest/ in format 
% swuaV0001.img/.hdr through swuaV0128.img/.hdr
% 
% PREPARE FOR REST ANALYSIS
% 4) Set up a new conn .mat design, called conn_NAME to be in the Processed/rest directory.
% 5) Variables are filled into the dummy SUB_VAR_SUB variables by the bash script.
% 6) The conn job is run to do Setup, Preprocessing, and 1st level analysis
% 7) Group analysis is NOT performed (should be done in GUI)

% RUN REST ANALYSIS WITH CONNECTIVITY TOOLBOX
% - The anatomical image is the subjects normalized s* image (ws*...)
% - The grey matter image is the subjects normalized c1 (wc1...)
% - The white and csf images are the (wc2 and wc3)
% - The functional data is the swuaV00* images created with slice timing
% - The conditions are one condition, "Rest" with onset 1, duration 128 TP
% - Regressors should be the rp_aV0001.txt motion parameters file created 
% when we normalized the swua* images. Since if there was an AC PC realign
% done it was done with the raw anatomical and the rest images were
% realigned to the anatomical as well, we should be OK.

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
addpath(genpath('SUB_MOUNT_SUB/Analysis/SPM/Processed/'));
addpath(genpath('SUB_MOUNT_SUB/Analysis/SPM/Analyzed/'));
% Add path to the connectivity toolbox
addpath(genpath('SUB_MOUNT_SUB/Scripts/Tools'));

%Here we set some directory variables to make navigation easier
outputdir='SUB_MOUNT_SUB/Analysis/SPM/Second_level/ICA/Rest/SUB_OUTPUTFOLDER_SUB/conn_SUB_THECONNAME_SUB';


%% DIRECTORY CREATION
% check that the output directory exists, and make it if it does not.
if exist(outputdir,'dir')
    cd(outputdir)
else
    mkdir(outputdir)
    cd(outputdir)
end

% We have already checked that all anatomical images, motion regressor
% files, swu, and normalized images exist for all subjects in the bash
% script, so we can go right into the CONN BATCH setup.

%% BATCH SETUP INFORMATION
batch.filename= fullfile(outputdir,'conn_SUB_THECONNAME_SUB.mat');


%% EXPERIMENT INFORMATION
batch.Setup.isnew=1;                 % 0: modifies existing project; 1: creates new proejct

batch.Setup.RT=2;                                   % TR (in seconds)
batch.Setup.nsubjects=SUB_SUBCOUNT_SUB;             % number of subjects

% Images fed into analysis were already smoothed at 6mm - use these
% variables if you want to specify smoothing and voxel size
% batch.FWHM=6;                                       % 8mm FWHM smoothing
% batch.VOX=2;                                        % 2mm voxel size for analyses

% For each subject in the order that they were submitted in the python
% script, put all 128 of their swuaV* images into an array of images.

subjects={ SUB_ALLSUBJECTS_SUB };
for i=1:numel(subjects)
    % Get specific rest directory for subject
    restdir=horzcat('SUB_MOUNT_SUB/Analysis/SPM/Processed/',subjects{i},'/rest/');
    anatdir=horzcat('SUB_MOUNT_SUB/Analysis/SPM/Processed/',subjects{i},'/anat/anat_rest/');
    
    % FUNCTIONAL DATA
    % Place swu* files il files variable from rest directory, and then into the batch variable 
    files=dir(fullfile(restdir,'swuaV*.img'));
    % functional data files (cell array per subject and sessions):
    % batch.Setup.functionals{nsub}{nses} is an array listing the(smoothed/normalized/realigned) functional file(s) for subject "nsub" and session "nses"
    batch.Setup.functionals{i}{1}{1}=[repmat([fullfile(restdir)],[128,1]),strvcat(files(:).name)];   % Point to 128 functional volumes for each subject, 1 session per subject
    clear files
    
    % STRUCTURAL DATA
    % anatomical volumes (cell array per subject):
    % batch.Setup.structurals{nsub} is an array pointing to the (normalized) anatomical volume for subject "nsub"
    structurals=dir(fullfile(anatdir,'wsdns*.img'));
    batch.Setup.structurals{i}=horzcat(anatdir,structurals(1).name);
    clear structurals
    
    % batch.Setup.conditions.onsets{ncondition}{nsub}{nses} is an array of onset value(s) (in seconds) for condition "ncondition" subject "nsub" and sessions "nses"
    batch.Setup.conditions.onsets{1}{i}{1}=0;
    % batch.Setup.conditions.durations{ncondition}{nsub}{nses} is a value defining the duration of each block for condition "ncondition" subject "nsub" and sessions "nses" %(note: setting to "inf" is equivalent to setting this value to the total session time) "
    batch.Setup.conditions.durations{1}{i}{1}=128;
    % cell array of strings (one per covariate and subject and condition): batch.Setup.covariates.files{ncovariate}{nsub}{nses} is an array pointing the a file defining the covariate "ncoviarate" for subject "nsub" and sessions "nses" (note: valid files are .txt or .mat files and should contain as many rows as scans for each given subject/session)
    batch.Setup.covariates.files{1}{i}{1}=char(horzcat(restdir,'rp_aV0001.txt'));
    clear restdir
    
    % MASKS
    % These masks will get fed automatically by conn_batch into batch.Setup.rois 1, 2, and 3.
    grey_matter=dir(fullfile(anatdir,'wc1sdns*.img'));
    batch.Setup.masks.Grey{i}=horzcat(anatdir,grey_matter(1).name);
    
    white_matter=dir(fullfile(anatdir,'wc2sdns*.img'));
    batch.Setup.masks.White{i}=horzcat(anatdir,white_matter(1).name);
    
    csf_matter=dir(fullfile(anatdir,'wc3sdns*.img'));
    batch.Setup.masks.CSF{i}=horzcat(anatdir,csf_matter(1).name);
    
    clear grey_matter white_matter csf_matter
    
    % Specify ROIS to be used for each subject as well as custom ROIs
    % Defaults from toolbox under Scripts/Tools/conn/rois are: BA.img, LLP.tal, PCC.tal, RLP.tal
    % You can add ROIS here to be hardcoded to run, but just make sure that you adjust the (c) value in the loop below to be (c + number of ROIS
    % specified here!)
    % batch.Setup.rois.files{1}{i}='SUB_MOUNT_SUB/Scripts/Tools/conn/rois/RAmy_2D0Dil.img';
    % batch.Setup.rois.files{2}{i}='SUB_MOUNT_SUB/Scripts/Tools/conn/rois/LAmy_2D0Dil.img';
    
    % Note that depending on the number of ROIs you include in the list above, you will need to change the (x+c) field below, where x is the
    % number above.  Since none are specified above, we just have c below.
    if SUB_ROICOUNT_SUB > 0
        rois={ SUB_LISTROI_SUB };
        for c = 1:length(rois)
            batch.Setup.rois.files{c}{i}=horzcat('SUB_MOUNT_SUB/Analysis/SPM/ROI/Rest_toolbox/SUB_FOLDERROI_SUB/',rois{c});
        end
    else
        fprintf('User did not specify any ROIs.  This may be OK, but this is just a warning!');
    end
    
end
   
% condition names: cell array of strings (one per condition) - We just have% one condition for each subject, "Rest"
batch.Setup.conditions.names={'Rest'};       
% names of temporal (first-level) covariates
batch.Setup.covariates.names={'motion_params'};      
batch.Setup.done=1;                 % 0: only edits project fields (do not run Setup->'Done'); 1: run Setup->'Done'
                                    % 1: Performs initial steps (segmentation, data extraction, etc.) on the defined experiment (equivalent to pressing "Done" in the gui "Setup" window)
                                    % set to 0 if you prefer to further inspect/edit the experiment information in the gui before performing this step
batch.Setup.overwrite='Yes';        % overwrite existing results if they exist (set to 'No' if you want to skip preprocessing steps for subjects/ROIs already analyzed; if in doubt set to 'Yes')    
                                    % For example you would set this field to 'No' if you have already run this script and later you add a few more subjets and/or ROIs and want to run this modified script again without having the existing subjects unnecessarily reanalyzed. 
                                    % note: removing some subjects needs to
                                    % be done through the gui, if done through the batch you need to set overwrite to 'Yes' 


%% PREPROCESSING INFORMATION
batch.Preprocessing.filter=[0.0080 0.09];           % frequency filter (band-pass values, in Hz)
                                                    % This filter is from Adam when he had conn tutorial
% IF WE ARE USING ROIS AS COUNFOUNDS - NEED TO ADD THEIR NAMES
% HERE, and also add dimensions and derivatives
batch.Preprocessing.confounds.names=...          % Effects to be included as confounds (cell array of effect names, effect names can be first-level covariate names, condition names, or noise ROI names)
{'Grey Matter','White Matter','CSF','motion_params','Effect of rest'};
    
batch.Preprocessing.confounds.dimensions=...        % dimensionality of each effect listed above (cell array of values, leave empty a particular value to set to the default value -maximum dimensions of the corresponding effect-)
    {1, 3, 3, 6, []};
batch.Preprocessing.confounds.deriv=...             % derivatives order of each effect listed above (cell array of values, leave empty a particular value to set to the default value)
    {0, 0, 0, 0, 1};

batch.Preprocessing.done=1;
batch.Preprocessing.overwrite='Yes';                % overwrite existing results if they exist (set to 'No' if you want to skip preprocessing steps for subjects/ROIs already analyzed)    


%% FINALLY DO ANALYSIS
batch.Analysis.analysis_number=1;       % Sequential number identifying each set of independent first-level analyses
batch.Analysis.measure=1;               % connectivity measure used {1 = 'correlation (bivariate)', 2 = 'correlation (semipartial)', 3 = 'regression (bivariate)', 4 = 'regression (multivariate)';
batch.Analysis.weight=2;                % within-condition weight used {1 = 'none', 2 = 'hrf', 3 = 'hanning';
%batch.Analysis.sources=...             % Sources names (seeds) for connectivity analyses - these correspond to a subset of ROI file names in the ROI folder (if this variable does not exist the toolbox will perform the analyses for all of the ROI files imported in the Setup step which are not defined as confounds in the Preprocessing step 
%    {'V2','V5'};
batch.Analysis.done=1;
batch.Analysis.overwrite='Yes';         % overwrite existing results if they exist (set to 'No' if you want to skip Analysis steps for subjects/ROIs already analyzed)    

%% CONN Results - leave out results for now!              % Default options (compute second-level results for all sources); see conn_batch for additional options 
%batch.Results.between_subjects.effect_names={'All'};    % Second-level analyses for all subjects
%batch.Results.between_subjects.contrast=[1];
%batch.Results.between_conditions.effect_names=...       % All sessions, average effect across sessions
%    cellstr([repmat('Session',[128,1]),num2str((1:128)')]);
%batch.Results.between_conditions.contrast=ones(1,nconditions)/nconditions;
%batch.Results.done=1;
%batch.Results.overwrite='Yes';

conn_batch(batch);

%% RENAME CONN_REST.mat paths for a local machine
% The following files have paths that need to be changed to work on a local
% machine:

%% REX.mat:
% params.sources
% params.VF.fnames
% params.rois
% params.ROIinfo.files{1}{1}

%% conn_rest.mat (The .mat with the same name as the analysis)
% CONN_x.filename
% CONN_x.folders.rois
% CONN_x.folders.data
% CONN_x.folders.firstlevel
% CONN_x.folders.secondlevel
% CONN_x.Setup.functional{subnum}{1}{1}
% CONN_x.Setup.structural{subnum}{1}
% CONN_x.Setup.rois.files{nsub}{nroi}{1}
% CONN_x.Setup.l1covariates.files{nsub}{1}{1}{1}
% CONN_x.Setup.functional{subnum}{1}{3}(1).fname
% CONN_x.Setup.functional{subnum}{1}{3}(1).private.dat.fname
% CONN_x.Setup.structural{subnum}{3}.fname
% CONN_x.Setup.structural{subnum}{3}.private.dat.fname
% CONN_x.Setup.structural{subnum}{2}{2}
% CONN_x.Setup.rois.files{subnum}{1}{2}{2}
% CONN_x.Setup.rois.files{subnum}{1}{3}.fname
% CONN_x.Setup.rois.files{subnum}{1}{3}.private.dat.fname
% CONN_x.Setup.l1covariates.files{subnum}{1}{1}{2}{2}

cd(outputdir);
conn_change_paths('conn_SUB_THECONNAME_SUB.mat','SUB_MOUNT_SUB','N:/DNS.01','/')
 

%% LOG CREATION
% Create a log for the group batch that includes subject numbers, etc.
subjects = { SUB_ALLSUBJECTS_SUB };

fid = fopen('subject_list.txt', 'wt');
    fprintf(fid, 'Date: ');
    fprintf(fid,'%s\n', date');
    fprintf(fid, 'Subject''s Included: ');
    fprintf(fid, '%g\n', SUB_SUBCOUNT_SUB);
    fprintf(fid, 'Name of Analysis: ');
    fprintf(fid, '%s\n', 'SUB_OUTPUTFOLDER_SUB');
    fprintf(fid, 'ROIs Included: ');
    for j=1:numel(rois)
        fprintf(fid, '%s%s',rois{j},':');
    end
    fprintf(fid,'\n%s\n','Subject_ID   Analysis_Number');
    for i=1:numel(subjects)
        fprintf(fid, '%s\t%d\t\n',subjects{i},i);
    end
    fclose(fid);

    
% When we finish, exit matlab
exit