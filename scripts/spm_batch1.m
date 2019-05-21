%-----------------------------------------------------------------------
% SPM BATCH - includes spm_batch1.m & spm_batch2.m
%
% These template scripts are filled in and run by a bash script,
% spm_batch_TEMPLATE.sh from the head node of BIAC
%
%    The Laboratory of Neurogenetics, 2010
%       By Vanessa Sochat, Duke University
%       Patrick Fisher, University of Pittsburgh 
%-----------------------------------------------------------------------

% Add necessary paths for BIAC, then SPM and data folders
BIACroot = 'SUB_BIACROOT_SUB';
startm=fullfile(BIACroot,'startup.m'); if exist(startm,'file'); run(startm); else; warning(sprintf(['Unable to locate central BIAC startup.m file\n  (%s).\n Connect to network or set BIACMATLABROOT environment variable.\n'],startm)); end; clear startm BIACroot;
addpath(genpath('SUB_SCRIPTDIR_SUB')); addpath(genpath('/usr/local/packages/MATLAB/spm8')); addpath(genpath('SUB_MOUNT_SUB/Data/Anat/SUB_SUBJECT_SUB'));
addpath(genpath('SUB_MOUNT_SUB/Data/Func/SUB_SUBJECT_SUB')); addpath(genpath('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB'));

%Here we set some directory variables to make navigation easier
homedir='SUB_MOUNT_SUB/Analysis/SPM/'; scriptdir='SUB_MOUNT_SUB/Scripts/'; datadir='SUB_MOUNT_SUB/Data/';

%% DIRECTORY CREATION: creates the proper directories under Analysis/SPM/Processed and Analysis/SPM/Analyzed

spm('defaults','fmri');spm_jobman('initcfg');                               % Initialize SPM JOBMAN
cd 'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/'; mkdir anat;     % Make "anat" under Analysis/SPM/Processed
cd(horzcat(homedir,'Analyzed/SUB_SUBJECT_SUB'));                            % Make Analyzed Data directories, if they don't exist
if strcmp('SUB_RUNFACES_SUB','yes'); if isdir('Faces')==0; mkdir Faces; end; end;
if strcmp('SUB_RUNCARDS_SUB','yes'); if isdir('cards')==0; mkdir cards; end; end
if strcmp('SUB_RUNREST_SUB','yes'); if isdir('rest')==0; mkdir rest; end; end;

%'pfl' stands for 'pseudo first-level'.  These design matrices are without regard to any individual outliers volumes flagged by ART.  The primary
% reason for the creation of these 'pfl' folders is the SPM.mat file can be used to execute art_batch.  These are legitimate design matrices and can be used for analyses.

if strcmp('SUB_RUNCARDS_SUB','yes'); if isdir('cards_pfl')==0; mkdir cards_pfl; end; end;
if strcmp('SUB_RUNFACES_SUB','yes'); if isdir('faces_pfl')==0; mkdir faces_pfl; end; end;
if strcmp('SUB_RUNREST_SUB','yes'); if isdir('rest_pfl')==0; mkdir rest_pfl; end; end
cd(horzcat(homedir,'Processed/SUB_SUBJECT_SUB'));

%% FUNCTIONAL DATA COPY
% We copy the raw data from Data/Func into Analysis/Processed/(Subject)/ faces, since we don't want to touch our original data.  At the end of
% processing in spm_batch2.m, we delete the copied data and preprocessed files to conserve space. We check whether task subfolders exist in the Processed folder. 
% if the folder exists, the functional data is copied into it.  If it does not, the folder is created, and then the data is copied.  If also checks to see
% if the functional data exists.  At the end of the run, the preprocessed images will be deleted to save space.

% CARDS
if strcmp('SUB_RUNCARDS_SUB', 'yes'); if isdir('cards')==0; mkdir cards; cd(horzcat(datadir,'Func/SUB_SUBJECT_SUB')); if isdir ('SUB_CARDSFOLDER_SUB')==0; sprintf('%s','Cards data for this subject does not exist.'); return; 
        else copyfile(horzcat(datadir,'Func/SUB_SUBJECT_SUB/SUB_CARDSFOLDER_SUB/*'),(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/cards/'))); end;
    else cd(horzcat(datadir,'Func/SUB_SUBJECT_SUB')); if isdir ('SUB_CARDSFOLDER_SUB')==0; sprintf('%s','Cards data for this subject does not exist.'); return;
        else copyfile(horzcat(datadir,'Func/SUB_SUBJECT_SUB/SUB_CARDSFOLDER_SUB/*'),(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/cards/'))); end; end;
end

% FACES
cd(horzcat(homedir,'Processed/SUB_SUBJECT_SUB')); 
if strcmp('SUB_RUNFACES_SUB', 'yes'); if isdir('faces')==0; mkdir faces; cd(horzcat(datadir,'Func/SUB_SUBJECT_SUB')); if isdir ('SUB_FACESFOLDER_SUB')==0; sprintf('%s','Faces data for this subject does not exist.'); return;
        else copyfile(horzcat(datadir,'Func/SUB_SUBJECT_SUB/SUB_FACESFOLDER_SUB/*'),(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/faces/'))); end
    else cd(horzcat(datadir,'Func/SUB_SUBJECT_SUB')); if isdir ('SUB_FACESFOLDER_SUB')==0; sprintf('%s','Faces data for this subject does not exist.'); return
        else copyfile(horzcat(datadir,'Func/SUB_SUBJECT_SUB/SUB_FACESFOLDER_SUB/*'),(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/faces/'))); end; end;
end;

% REST
cd(horzcat(homedir,'Processed/SUB_SUBJECT_SUB'))
if strcmp('SUB_RUNREST_SUB', 'yes'); if isdir('rest')==0; mkdir rest; cd(horzcat(datadir,'Func/SUB_SUBJECT_SUB')); if isdir ('SUB_RESTFOLDER_SUB')==0; sprintf('%s','Resting BOLD data for this subject does not exist.'); return;
        else copyfile(horzcat(datadir,'Func/SUB_SUBJECT_SUB/SUB_RESTFOLDER_SUB/*'),(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/rest/'))); end;
    else cd(horzcat(datadir,'Func/SUB_SUBJECT_SUB')); if isdir ('SUB_RESTFOLDER_SUB')==0; sprintf('%s','Resting BOLD data for this subject does not exist.'); return;
        else copyfile(horzcat(datadir,'Func/SUB_SUBJECT_SUB/SUB_RESTFOLDER_SUB/*'),(horzcat(homedir,'Processed/SUB_SUBJECT_SUB/rest/'))); end; end;
end;

%% DICOM TO NIFTI CONVERSIONS, ANATOMICAL DATA
% We import the dicom images for the anatomical used for functional registration as well as for the high rest T1.  The scan folder names
% are specified by the user, however the anatomical is usually "series002" and the highres is "series005."  The script assumes the highres has 
% 162 images, and the anatomical 32. Output goes into Processed/anat.

%Make sure that we are in the subjects raw anatomical data directory
cd(horzcat(homedir,'Processed/SUB_SUBJECT_SUB')); foldertogoto=('SUB_MOUNT_SUB/Data/Anat/SUB_SUBJECT_SUB/SUB_ANATFOLDER_SUB'); cd(foldertogoto);

% Anatomical for Functional Data
if strcmp('SUB_ANATFOLDER_SUB', 'series002')
    % Get DICOM images
    V00img=dir(fullfile(datadir,'Anat/SUB_SUBJECT_SUB/SUB_ANATFOLDER_SUB/','SUB_DICOM_SUB*.dcm')); numimages = length(V00img);
    for j=1:numimages; imagearray{j}=horzcat(datadir,'Anat/SUB_SUBJECT_SUB/SUB_ANATFOLDER_SUB/',V00img(j).name); end; clear V00img;
    matlabbatch{1}.spm.util.dicom.data = imagearray;
    matlabbatch{1}.spm.util.dicom.root = 'flat';
    matlabbatch{1}.spm.util.dicom.outdir = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/'};
    matlabbatch{1}.spm.util.dicom.convopts.format = 'img';
    matlabbatch{1}.spm.util.dicom.convopts.icedims = 0;
end; clear imagearray;

%% T1 MPRAGE Import
foldertogoto=('SUB_MOUNT_SUB/Data/Anat/SUB_SUBJECT_SUB/'); cd(foldertogoto);    % Make sure we are in top data directory
% If the subject does not have a high-res 3D structural image, this step replaces the position within the SPM8 batch file normally occupied by the DICOM
% convert for the 3D structural with a second DICOM convert for the T1 in-plane.  This is redudant, however, removing this component of the batch
% changes what number in the processing batch each step occupies (from n to n-1).  This would create errors downstream when the dependency function is instantiated.
if isdir('SUB_TFOLDER_SUB')==0; matlabbatch{2}=matlabbatch{1}; else cd SUB_TFOLDER_SUB;
    if strcmp('SUB_TFOLDER_SUB', 'series005')
        V00img=dir(fullfile(datadir,'Anat/SUB_SUBJECT_SUB/SUB_TFOLDER_SUB/','SUB_DICOMTWO_SUB*.dcm')); numimages = length(V00img);
        for j=1:numimages; imagearray{j}=horzcat(datadir,'Anat/SUB_SUBJECT_SUB/SUB_TFOLDER_SUB/',V00img(j).name); end; clear V00img;
        matlabbatch{2}.spm.util.dicom.data = imagearray;
        matlabbatch{2}.spm.util.dicom.root = 'flat';
        matlabbatch{2}.spm.util.dicom.outdir = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/'};
        matlabbatch{2}.spm.util.dicom.convopts.format = 'img';
        matlabbatch{2}.spm.util.dicom.convopts.icedims = 0;    
    end
end

%% Segmentation
% only segments the anatomical image if we aren't doing an ACPC realign (meaning we aren't running only preprocessing)  If we are doing an AC PC realign, the segmentation is done manually.

if strcmp('SUB_ONLYDOPRE_SUB','no')
    matlabbatch{3}.spm.spatial.preproc.data = {'SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB/anat/sdns01-0002-00001-000001-01.img,1'};
    matlabbatch{3}.spm.spatial.preproc.output.GM = [0 0 1];
    matlabbatch{3}.spm.spatial.preproc.output.WM = [0 0 1];
    matlabbatch{3}.spm.spatial.preproc.output.CSF = [0 0 0];
    matlabbatch{3}.spm.spatial.preproc.output.biascor = 1;
    matlabbatch{3}.spm.spatial.preproc.output.cleanup = 0;
    matlabbatch{3}.spm.spatial.preproc.opts.tpm = {
                                                   '/usr/local/packages/MATLAB/spm8/tpm/grey.nii'
                                                   '/usr/local/packages/MATLAB/spm8/tpm/white.nii'
                                                   '/usr/local/packages/MATLAB/spm8/tpm/csf.nii'
                                                   };
    matlabbatch{3}.spm.spatial.preproc.opts.ngaus = [2 2 2 4];
    matlabbatch{3}.spm.spatial.preproc.opts.regtype = 'mni';
    matlabbatch{3}.spm.spatial.preproc.opts.warpreg = 1;
    matlabbatch{3}.spm.spatial.preproc.opts.warpco = 25;
    matlabbatch{3}.spm.spatial.preproc.opts.biasreg = 0.0001;
    matlabbatch{3}.spm.spatial.preproc.opts.biasfwhm = 60;
    matlabbatch{3}.spm.spatial.preproc.opts.samp = 3;
    matlabbatch{3}.spm.spatial.preproc.opts.msk = {''};
end

spm_jobman('run_nogui',matlabbatch);  clear matlabbatch     %Execute the job to process the anatomicals and clear matlabbatch

exit