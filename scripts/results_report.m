%-----------------------------------------------------------------------
% RESULTS_REPORT:  This script was thrown together by Vanessa to create
% results reports for various runs and save them to Graphics / Data_Check 
% / Task.  This was added to the processing pipeline to be done 
% automatically, and would need to be done manually for all subjects
% who have not had it at this point!
% ----------------------------------------------------------------------
% VARIABLES:
% runfaces: should be 'yes' or 'no' (set in script)
% runcards: should be 'yes' or 'no' (set in script)
% runtone: should be 'yes' or 'no' (set in script)
% homedir and outdir: (set in script)
%-----------------------------------------------------------------------
% --the following description is in the matlab script template--
% DATA CHECK
% For QA checks, we produce a PDF printout of each subject's data for
% Faces > Shapes, block design, Positive Feedback > Negative Feedback
% for Cards, and display a T1. In the bash script we then move all  
% files to Graphics / Data_Check /, where Ahmad can click through maps to 
% get an overall idea of data quality.
% ----------------------------------------------------------------------

%% Cluster prep

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
addpath(genpath('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB'));
addpath(genpath('SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB'));

%% Set variables and paths
homedir='SUB_MOUNT_SUB/Analysis/SPM/';
outdir='SUB_MOUNT_SUB/Graphics/Data_Check/';
runfaces='SUB_RUNFACES_SUB'; runcards='SUB_RUNCARDS_SUB'; runtone='SUB_TONE_SUB';
spm_ps = horzcat('spm_',datestr(date,'yyyymmmdd'));
     
% Run the results reports for FACES
if strcmp(runfaces,'yes')
    spm('defaults','fmri'); spm_jobman('initcfg');
    if exist(strcat(homedir,'Analyzed/SUB_SUBJECT_SUB/Faces/block'),'dir')
        cd(strcat(homedir,'Analyzed/SUB_SUBJECT_SUB/Faces/block'))
        matlabbatch{1}.spm.stats.results.spmmat = {strcat(homedir,'/Analyzed/SUB_SUBJECT_SUB/Faces/block/SPM.mat')};
        matlabbatch{1}.spm.stats.results.conspec.titlestr = {'SUB_SUBJECT_SUB Faces > Shapes'};
        matlabbatch{1}.spm.stats.results.conspec.contrasts = 1;
        matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none';
        matlabbatch{1}.spm.stats.results.conspec.thresh = 0.001;
        matlabbatch{1}.spm.stats.results.conspec.extent = 10;
        matlabbatch{1}.spm.stats.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
        matlabbatch{1}.spm.stats.results.units = 1;
        matlabbatch{1}.spm.stats.results.print = true;       
        spm_jobman('run_nogui',matlabbatch);
        clear matlabbatch
        
        % Move the newly creaated file
        cd(strcat(homedir,'Analyzed/SUB_SUBJECT_SUB/Faces/block'))
        if exist(strcat(spm_ps,'.ps'),'file')
            copyfile(strcat(spm_ps,'.ps'),strcat(outdir,'Faces/block/SUB_SUBJECT_SUB_',datestr(date,'yyyymmmdd'),'.ps'))
            delete(strcat(spm_ps,'.ps'));
        end
        if exist('spm_2010Dec22.ps','file')
           delete('spm_2010Dec22.ps');
        end 
    end
end


% Run the results reports for CARDS
if strcmp(runcards,'yes')
    spm('defaults','fmri'); spm_jobman('initcfg');
    if exist(strcat(homedir,'Analyzed/SUB_SUBJECT_SUB/cards'),'dir')
        cd(strcat(homedir,'Analyzed/SUB_SUBJECT_SUB/cards'))
        matlabbatch{1}.spm.stats.results.spmmat = {strcat(homedir,'/Analyzed/SUB_SUBJECT_SUB/cards/SPM.mat')};
        matlabbatch{1}.spm.stats.results.conspec.titlestr = {'SUB_SUBJECT_SUB PosFeedbk > NegFeedbk'};
        matlabbatch{1}.spm.stats.results.conspec.contrasts = 1;
        matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none';
        matlabbatch{1}.spm.stats.results.conspec.thresh = 0.001;
        matlabbatch{1}.spm.stats.results.conspec.extent = 10;
        matlabbatch{1}.spm.stats.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
        matlabbatch{1}.spm.stats.results.units = 1;
        matlabbatch{1}.spm.stats.results.print = true;       
        spm_jobman('run_nogui',matlabbatch);
        clear matlabbatch
        
        % Move the newly creaated file
        cd(strcat(homedir,'Analyzed/SUB_SUBJECT_SUB/cards'))
        if exist(strcat(spm_ps,'.ps'),'file')
            copyfile(strcat(spm_ps,'.ps'),strcat(outdir,'cards/SUB_SUBJECT_SUB_',datestr(date,'yyyymmmdd'),'.ps'))
            delete(strcat(spm_ps,'.ps'));
        end
        if exist('spm_2010Dec22.ps','file')
           delete('spm_2010Dec22.ps');
        end 
    end
end
 
% Create display image for highres
if strcmp(runtone,'yes')
    if exist(strcat(homedir,'Processed/SUB_SUBJECT_SUB/anat'),'dir')
        cd(strcat(homedir,'Processed/SUB_SUBJECT_SUB/anat'));
        if exist('sdns01-0005-00001-000001-01','file')
            tone = 'sdns01-0005-00001-000001-01.img';
        elseif exist('sDNS01-0005-00001-000001-01.img','file')
            tone = ('sDNS01-0005-00001-000001-01.img');
        end
        if exist('tone','var')
            spm('defaults','fmri'); spm_jobman('initcfg');
                matlabbatch{1}.spm.util.disp.data = {strcat(homedir,'Processed/SUB_SUBJECT_SUB/anat/',tone)};
                spm_jobman('run_nogui',matlabbatch);
                clear matlabbatch
                spm_print;
                if exist(strcat(spm_ps,'.ps'),'file')
                    copyfile(strcat(spm_ps,'.ps'),strcat(outdir,'T1/SUB_SUBJECT_SUB_',datestr(date,'yyyymmmdd'),'.ps'))
                    delete(strcat(spm_ps,'.ps'));
                end
                if exist('spm_2010Dec22.ps','file')
                   delete('spm_2010Dec22.ps');
                end
               
        end
    end
end

exit