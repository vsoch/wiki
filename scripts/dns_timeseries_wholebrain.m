function dns_timeseries_wholebrain(spmmat,threshtype,thresh,extent,output,mask,contrast,lookup)
%--------------------------------------------------------------------
% dns_timeseries_wholebrain
% Can be called on command line with or without arguments to extract 
% group timeseries data to be saved as .csv files for the DNS database
% These .csv files can be used by individual researchers or by Bart
% to always have access to timeseries data for collaborators.
% It is suggested to use this script each time there is a new data 
% freeze.  See N:/DNS.01/Analysis/SPM/TIMESERIES/XXXs/script for
% an example of how to set this up to create multiple time series
% This "wholebrain" version uses a thresholded whole brain map
% before applying the VOI, and extracting from the mean within a
% user specified mask.  To apply a mask at the time of thresholding,
% use dns_timeseries!
%
% Created for Laboratory of NeuroGenetics, March 2011 by VSochat
%---------------------------------------------------------------------
% DEPENDENCIES
% Must have SPM installed on computer
% Group analysis (with SPM.mats) for group maps of interest must exist
%---------------------------------------------------------------------
% INPUT VARIABLES: Can be called with 0,7, or 8 arguments.
% (1) spmmat:      the full path location to the group SPM.mat (string)
% (2) threshtype:  must be fwe or none (string)
% (3) thresh:      the threshold % (string or number)
% (4) extent:      the voxel extent (string or number)
% (5) output:      the output folder (string)
% (6) mask:        pull path to mask image (string)
% (7) contrast:    the contrast number (string or number) (usually 1)
% (8) lookup:      an excel (.xls, .xlsx, or .csv) lookup table.
%                  Should have "dns_id" and "exam_id" columns
%---------------------------------------------------------------------
% USAGE: You can either call dns_timeseries without any input args, OR
% 7 INPUT: dns_timeseries_wholebrain(spmmat,threshtype,thresh,extent,output,mask,contrast)
% 8 INPUT: dns_timeseries_wholebrain(spmmat,threshtype,thresh,extent,output,mask,contrast,lookup)
%---------------------------------------------------------------------
% OUTPUT
% Saved as .csv files to user specified TIMESERIES output folder
%   list of IDs is extracted from the SPM.mat
%   file name is based on user input
%---------------------------------------------------------------------
% MODIFY:
%
% LINES 196-197: Regular expressions are used to match a subject ID in the 
% format XXXXXXXX_XXXXX.  Modify these statements to match your subject IDs 
% that are being extracted from the xY.P path variable.  These IDs will be
% written to "exam_id" in the output csv file.
% LINES 252-254: Define the strings that are the headers in the lookup table
% LINE 164: Define the headers to be printed to the output csv
%---------------------------------------------------------------------

%% PATH CHECK
% Check if SPM is installed and path added on computer
if exist('spm','file') ~= 2;error('Cannot find SPM.  Please make sure that it is added to your path.'); end;

%% VARIABLE DEFINITION
if (nargin == 0)
    cont = 'yes'; n=0; one_output = 'no';
    % Give user choice to use lookup table
    lookup_choice = questdlg('Would you like to use a lookup table (with dns_id and exam_id)?','Lookup Table?', 'yes', 'no', 'yes');
    if strcmp(lookup_choice,'yes')
        [lookname, lookpath] = uigetfile({'*.xls','Excel (*.xls)';'*.xlsx','Excel (*.xlsx)';'*.csv','CSV File (*.csv)';},'Select a lookup table (.xls, .xlsx, .csv)');
            if isequal(lookname,0) || isequal(lookpath,0); fprintf('%s','You canceled out of the file selector.  No lookup table will be used.'); lookup = 'none';  
            else lookup = fullfile(lookpath,lookname); clear lookpath lookname; [llist,lookup] = check_lookup(lookup); end; % Check and read lookup table 
    else
        lookup = 'none';
    end
        while strcmp(cont,'yes') 
            % Prompt user to select group SPM.mat
            [filename, pathname] = uigetfile('*.mat', 'Select a group SPM.mat file');
            if isequal(filename,0) || isequal(pathname,0); error('You canceled out of the file selector.  Please run DNS_timeseries again!');
            else
                if strcmp(filename,'SPM.mat')==0; error('You can only select an SPM.mat file.'); end; 
                disp(['   SPM.mat: ', fullfile(pathname, filename) ' is selected.']); spmmat = fullfile(pathname,filename); 
            end
            
            % Prompt user to select mask image
            [filename, pathname] = uigetfile('*.img', 'Select a mask image');
            if isequal(filename,0) || isequal(pathname,0); error('You canceled out of the file selector.  Please run DNS_timeseries again!');
            else
                disp(['Mask Image: ', fullfile(pathname, filename) ' is selected.']); mask = fullfile(pathname,filename);
            end
            
            % Select threshold type
            threshtype = questdlg('Please select a threshold type:','Threshold type', 'FWE', 'none', 'FWE');
            % Select threshold value
            thresh = inputdlg('0.0 to 1.0','Threshold Value',1,{'0.05'});
            thresh = str2double(thresh{1});
            % Select extent value
            extent = inputdlg('0 to n','Extent Voxels',1,{'0'});
            extent = str2double(extent{1});
            % Select contrast number
            SPM = load(spmmat);
            for l=1:length(SPM.SPM.xCon)
                spmcons{l}=SPM.SPM.xCon(l).name;
            end
            contrast = listdlg('PromptString','Select Contrast','SelectionMode','single','ListString',spmcons); clear SPM;
            % Prompt user to select output folder
            if strcmp(one_output,'no'); output = uigetdir(pwd,'Please select an output folder'); if isequal(output,0); error('You canceled out of the folder selector.  Please run DNS_timeseries again!'); end; end;
            % Only on the first setup, ask if the user will use this output folder for all timeseries
            if (n==0); one_output = questdlg('Would you like to use this output directory for all timeseries?','One output folder?', 'yes', 'no', 'yes');end;
            
            % Check all input arguments
            if check_vars(spmmat,threshtype,thresh,extent,output,mask,contrast)
                % Setup matlabbatch variable for run just specified
                group_timeseries(spmmat,threshtype,thresh,extent,output,mask,contrast,n+1);n=n+1;
            else
                fprintf('%s\n','Session will not be added.')
            end
            
            % Ask user if he/she wants to do another extraction            
            cont = questdlg('Would you like to create another timeseries?','Additional timeseries setup?', 'yes', 'no', 'yes');
        end
        
elseif (nargin == 7)
    lookup = 'none';
    % Convert possible character input to double
    if ischar(thresh); thresh = str2double(thresh); end;
    if ischar(extent); extent = str2double(extent); end;
    if ischar(contrast); contrast = str2double(contrast); end;
    % If the user has provided all input arguments, check inputs and setup matlabbatch
    if checkvars(spmmat,threshtype,thresh,extent,output,mask,contrast,lookup)
        fprintf('%s\n','Setting up timeseries with the following parameters:')
        group_timeseries(spmmat,threshtype,thresh,extent,output,contrast,1)
    end
    
elseif (nargin == 8)       % If we have a lookup table!
    [llist,lookup] = check_lookup(lookup);  % Check and read lookup table
    % Convert possible character input to double
    if ischar(thresh); thresh = str2double(thresh); end;
    if ischar(extent); extent = str2double(extent); end;
    if ischar(contrast); contrast = str2double(contrast); end;
    % If the user has provided all input arguments, check inputs and setup matlabbatch
    if check_vars(spmmat,threshtype,thresh,extent,output,mask,contrast)
        fprintf('%s\n','Setting up timeseries with the following parameters:')
        group_timeseries(spmmat,threshtype,thresh,extent,output,mask,contrast,1)
    end    
else
    % If user has provided something other than 0 or 7 or 8 input arguments, exit with error.
    error('Please run dns_timeseries with the following input:\n   Zero Arguments\n   Seven arguments: dns_timeseries(spmmat,threshtype,thresh,extent,output,mask,contrast)\n   Eight Arguments: dns_timeseries(spmmat,threshtype,thresh,extent,output,mask,contrast,lookup)\n   For information about these arguments, please read script documentation.')
end

% Once job is setup, initialize SPM and submit job to spm_jobman
spm('defaults','fmri');spm_jobman('initcfg');
spm_jobman('run_nogui',matlabbatch);

% go to each output folder, read the timeseries from the VOI, 
% and print with subject ID and parameters to csv file.  When we finish, delete intermediate files.

for i=1:length(job)
    % Go to output folder
    cd(job(i).output)
    % Load VOI that was created, save timeseries to another variable
    VOI = load(horzcat(job(i).input,job(i).voifile)); job(i).timeseries = VOI.Y; clear VOI;
    % Delete VOI.mat file?
    % delete(horzcat(job(i).input,job(i).voifile));
    % Create CSV with voiname, maskname, include list of values next to list of subjects
    save workspace.mat
    fid = fopen([ job(i).voiname '.csv' ], 'wt');
    if strcmp(lookup,'none')
       fprintf(fid, '%s%s%s\n','exam_id,',job(i).maskname,',');
       for k=1:numel(job(i).scans); fprintf(fid, '%s%s%s%s\n',job(i).scans{k},',',job(i).timeseries(k),','); end;
    else
        fprintf(fid, '%s%s%s\n','dns_id,exam_id,',job(i).maskname,',');
        for k=1:numel(job(i).scans); 
            if isempty(llist.get(job(i).scans{k})); curr_id = '.'; else curr_id = num2str(llist.get(job(i).scans{k})); end;
            fprintf(fid, '%s%s%s%s%s%s\n',curr_id,',',job(i).scans{k},',',job(i).timeseries(k),','); clear curr_id; 
        end      
    end
    fclose(fid);
end

fprintf('%s\n','Done running dns_timeseries')

%--------------------------------------------------------------------
% group_timeseries
% A subfunction which sets up matlabbatch for each extraction
% If DNS_Timeseries is called with no arguments, can be run multiple
% times, otherwise just gets called once
%--------------------------------------------------------------------
    function group_timeseries(spmmat,threshdesc,thresh,extent,output,mask,contrast,i)
        matlabbatch{i}.spm.util.voi.spmmat = {spmmat};
        matlabbatch{i}.spm.util.voi.adjust = 0;
        matlabbatch{i}.spm.util.voi.session = 1;
        
        % Grab name of mask from mask image name
        marker = regexp(mask,'/|\'); 
        maskname = mask(marker(length(marker))+1:end);
        maskname = regexprep(maskname,'[.].*','');
        
        SPM=load(spmmat);  % Load spmmat to create name from contrast, threshold type, threshold, and extent
        info.voiname = deblank(horzcat(regexprep(regexprep(regexprep(SPM.SPM.xCon(contrast).name,{' ','%',':','/','\','*','?','/"','|'},'_'),'<','lt'),'>','gr'),'_',maskname,'_',threshdesc,'_',regexprep(num2str(thresh),'0\.','pt')));
        info.maskname = maskname;
        % Grab list of raw scans to pull subject IDs from
        for j=1:length(SPM.SPM.xY.P)
            start = SPM.SPM.xY.P(j,:); start = regexp(start,'\d{8}_\d{5}','start');
            endmark = SPM.SPM.xY.P(j,:); endmark = regexp(endmark,'\d{8}_\d{5}','end');
            scan = SPM.SPM.xY.P{j}(start{1}:endmark{1});
            info.scans{j} = scan;
        end
        
        matlabbatch{i}.spm.util.voi.name = info.voiname;
        matlabbatch{i}.spm.util.voi.roi{1}.spm.spmmat = {''};
        matlabbatch{i}.spm.util.voi.roi{1}.spm.contrast = contrast;
        matlabbatch{i}.spm.util.voi.roi{1}.spm.conjunction = 1;
        matlabbatch{i}.spm.util.voi.roi{1}.spm.threshdesc = threshdesc;
        matlabbatch{i}.spm.util.voi.roi{1}.spm.thresh = thresh;
        matlabbatch{i}.spm.util.voi.roi{1}.spm.extent = extent;
        matlabbatch{i}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
        matlabbatch{i}.spm.util.voi.roi{2}.mask.image = {horzcat(mask,',1')};
        matlabbatch{i}.spm.util.voi.roi{2}.mask.threshold = 0.5;
        matlabbatch{i}.spm.util.voi.expression = 'i1&i2';
       
        % Add analysis variables to a structural array so we can print the .csv and clean up files
        % when it finishes running.
        info.input = regexprep(spmmat,'SPM.mat',''); info.output = output; info.spmmat = spmmat; info.voifile = horzcat('VOI_',info.voiname,'.mat'); job(i) = info; 
    end
    
%--------------------------------------------------------------------
% check_lookup
% takes in the full path to an .xls, .xlsx, or .csv lookup table
% checks that the lookup table is valid, and if so, reads into variable
% If the table is not valid or not found, lookup is set to 'none'
% and an empty variable is returned, and no table used.
%--------------------------------------------------------------------
    function [result,lookup_path]=check_lookup(lookup)
        % First check if the file exists, period
        if exist(lookup,'file')
            if (regexp(lookup,'.xls')||regexp(lookup,'.xlsx')||regexp(lookup,'.csv'))==1
                [result,lookup_path] = read_lookup(lookup);
            else
                fprintf('%s\n','Lookup table format must be .csv, .xls, or .xlsx. Will not use.')
                result = 'none'; lookup_path = 'none';
            end
        else
            fprintf('%s\n','Lookup table file cannot be found.  Will not use.')
            result = 'none'; lookup_path = 'none';
        end  
    end

%--------------------------------------------------------------------
% read_lookup 
% Reads the lookup table into a variable
%--------------------------------------------------------------------
    function [result_table,path]=read_lookup(lookup)  
        [~, ~, raw] = xlsread(lookup);
        % raw{1,1}: the title of the first column
        % raw{2,1}: the title of the second column
        % Read in titles and find the column with dns_id and exam_id
        dns_id = 0; exam_id = 0;
        for h=1:size(raw,2);
            if strcmp(raw{1,h},'dns_id');dns_id = h;
            elseif strcmp(raw{1,h},'exam_id'); exam_id = h;
            end
        end
        
        % Check to see if we found exam_id and dns_id columns
        if ((dns_id==0)||(exam_id==0))
            fprintf('%s\n%s','Cannot find both columns with label exam_id and dns_id.',' No lookup table will be used.')
            result_table = 'none'; path = 'none'; return;
        end 
        
        % We will use java to create a hash lookup table
        import java.util.*;
        result_table = HashMap;
        % If we have correctly formatted file, read in IDs to array
        for h=2:length(raw)
            result_table.put(raw{h,exam_id},raw{h,dns_id});
        end
        path = lookup; disp(['Lookup Table: ', lookup ' is read successfully.']);
    end
%--------------------------------------------------------------------
% check_vars
% checks that all input arguments are correct. Returns a boolean
%--------------------------------------------------------------------
    function res = check_vars(spmmat,threshdesc,thresh,extent,output,mask,contrast)
        % Make sure it is a group file and not an individual file
        SPM=load(spmmat); if isfield(SPM.SPM.xVi,'I')~=1; fprintf('%s\n','ERROR: Please select an individual SPM.mat file!'); res = 0; return; end; clear SPM;
        % Make sure the threshold description is FWE or none
        if (strcmp(threshdesc,'FWE')~=1)&&(strcmp(threshdesc,'none')~=1); fprintf('%s\n','ERROR, threshold description must be FWE or none'); res = 0; return; end;
        % Make sure the threshold is a number - if the user entered a string the variable will be empty
        if (strcmp(class(thresh),'double')==0)||isempty(thresh); fprintf('%s\n','ERROR: Please enter a valid threshold!'); res = 0; return; end;
        % Make sure the extent is a number
        if (strcmp(class(extent),'double')==0)||isempty(extent); fprintf('%s\n','ERROR: Please enter a valid extent voxels!'); res = 0; return; end;
        % Make sure the contrast is  number
        if (strcmp(class(contrast),'double')==0)||isempty(contrast); fprintf('%s\n','ERROR: Please enter a valid contrast number!'); res = 0; return; end;
        % Make sure the output folder exists
        if isdir(output)==0; error([ 'Output directory ' output  ' does not exist!' ]); end;
        % Make sure the mask exists
        if exist(mask,'file')==0; fprintf('%s%s%s\n','Mask: ',mask,' does not exist!'); res = 0; return; end;
        res = 1;
    end
end