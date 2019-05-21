function covcheck_free()
% COVERAGE CHECKING for SPM ANALYSIS (covcheck_free.m)
% Vanessa Sochat
%
% This script takes in a list of subjects processed in SPM, an ROI mask
% that will be used for group analysis, and a user specified coverage 
% percentage.  It will calculate the size of a single subject mask and
% determine if the subject has that percentage coverage.
%__________________________________________________________________________
%
% DEPENDENCIES: You have to have the BIAC tools in your path for this
% function to work.
% e.g. if the tools are saved under yourpath\MATLAB\BIAC\
% addpath yourpath\Programs\MATLAB\BIAC\general
% addpath yourpath\MATLAB\BIAC\mr
% addpath yourpath\MATLAB\BIAC\fix
%
% This script was modified to allow for the user to select any mask.img
% files, so it does not ask for an experiment name, or present with user
% directories.  Support is currently only for .hdr/.img files.
%
% The user simply needs to enter the list of paths to the mask.img files
% The mask can also be selected from anywhere.
% The user must also select an output folder, within which a run folder
% will be created.
%__________________________________________________________________________
%
% USAGE: covcheck_free()
% no input variables are required as the program takes them into a GUI.
%__________________________________________________________________________
%
% This script works by reading in the imaging file, then counting the
% number of 1's in the image (each representing one voxel in the mask).  In
% the case that the subject has a number of voxels in his/her individual
% mask that is greater than or equal to the user specified percent coverage
% desired, the subject gets added to a list of subjects to be used.  In the
% case that the subject has a number of voxels in his/her mask that is less
% than the user specified percent coverage desired, the subject gets added
% to a second list.  The script prepares visual output of both passing and
% non-passing subjects so its accurac can be visually verified.
%__________________________________________________________________________
%
% When the user is happy with the output, the subjects can then be used in
% the group level analysis with the ROI, and we can be sure that the
% included subjects each have the minimum coverage desired.
%__________________________________________________________________________
%
% CHANGELOG:
% 11/18/2010 (VS): Script modified to accomodate FIGS standard file structure.
% 02/24/2011 (VS): Script modified to allow for any file structure.
% 02/28/2011 (VS): Added check for non zero or non 1 values in masks.
%__________________________________________________________________________

%-Global Variables
%-----------------------------------------------------------------------
fprintf('CovCheck Free\n Vanessa Sochat\n February, 2011\n');

% Here the user specifies the subjects to be included in the coverage check
subjects = spm_select(Inf,'.img','Select mask.img files to check coverage','',pwd);
subj_count = size(subjects,1);

% Here the user specifies the output directory
output_dir = spm_select(1,'dir','Select directory for output folder','',pwd);

% Here the user specifies the ROI to use
ROI = spm_select(1,'.img','Select ROI to use in analysis','',pwd);

% Here the user specifies the percentage coverage desired for each subject:
coverage = spm_input('Percent coverage desired',1,'',.95,1);

%-Output Directory Creation
%-----------------------------------------------------------------------
fprintf('Creating output directories...\n');

% Check that 'Coverage_Check' exists, and if it doesn't, create it
if exist(output_dir,'dir')
    cd(output_dir);
else error('Output directory no longer exists.  Exiting.')
end

% Create an output directory based on date and time.
mkdir(horzcat(date,'_',datestr(clock, 'HH-MM')));
output_dir=horzcat(output_dir,date,'_',datestr(clock, 'HH-MM'));
fprintf('Output can be found in:\n');
fprintf('%s',output_dir);

% Create directories for logs and raw images
fprintf('\nCreating logs and masks output directories...\n');
cd(output_dir);
mkdir('logs');
mkdir('masks');
mkdir('results');
cd masks
mkdir('ROI_applied');

%-Calculate Number of Voxels in ROI Mask
%-----------------------------------------------------------------------
fprintf('Calculating voxels in ROI...\n');
% Read in the ROI mask
ROI_data=readmr(ROI);
x_size=ROI_data.info.dimensions(1).size;
y_size=ROI_data.info.dimensions(2).size;
z_size=ROI_data.info.dimensions(3).size;

%Initialize a variable to count the voxels in the ROI mask
ROI_count=0;

%Calculate the number of voxels in the ROI mask
for i = 1:x_size
    for j = 1:y_size
        for k = 1:z_size
         current_voxel=ROI_data.data(i,j,k);
         if current_voxel == 1
             ROI_count=ROI_count+1;
         elseif (current_voxel ~= 0) && (current_voxel ~= 1)
             error('The mask image needs to be binarized (0s and 1s).  Please binarize the image and run again!')
         end
        end
    end
end
fprintf('...done!\n');
fprintf('%s','Number of voxels in mask is ',num2str(ROI_count));


%-Calculate Threshold for Individual Masks
%-----------------------------------------------------------------------
% Coverage and ROI_count are both doubles
vox_min=coverage*ROI_count;


%-Calculate Number of Voxels in Subject Masks
%-----------------------------------------------------------------------

fprintf('\n Preparing individual subject masks...\n');

% Set up counts for recording subjects, included and eliminated. 
inc_count=0;
flag_count=0;
miss_count=0;

% Go to each single subject directory and copy the mask
% if the mask doesn't exist, exit with error
for su=1:subj_count
    s=deblank(subjects(su,:));
    
    % Get a list of all the slashes, and then find the last
    last_marker = regexp(s,'\');
    ext_marker = regexp(s,'[.]');
    
    if isempty(last_marker)
        last_marker = regexp(s,'/');
    end
    sfol = s(1:last_marker(end));
    sname = s(last_marker(end)+1:ext_marker(end)-1);
    
    % Check here if the mask exists, if it does, put it in masks folder,
    % add one to the included count, and then mask the image.  If the mask
    % does not exist, then we print to "missing" file.
    if exist(horzcat(sfol,sname,'.img'),'file')
        
        % Copy the .hdr
        %subj_mask=horzcat(sfol,'mask_',num2str(su),'.hdr');  
        subj_mask_dir=horzcat(output_dir,'\masks\mask_',num2str(su),'.hdr');
        fprintf(horzcat(sfol,sname,'.hdr'))
        copyfile(horzcat(sfol,sname,'.hdr'),subj_mask_dir);
        
        % Copy the .img
        % subj_mask=horzcat(sfol,'mask_',num2str(su),'.img');
        % subj_mask_dir=horzcat(output_dir,'\masks\',subj_mask);
        subj_mask_dir=horzcat(output_dir,'\masks\mask_',num2str(su),'.img');
        copyfile(horzcat(sfol,sname,'.img'),subj_mask_dir);
        cd(horzcat(output_dir,'\masks\'));
        
        % Use the ROI to mask the subject mask using IMcalc
        P1=(subj_mask_dir);
        P2=(ROI);

        cd(horzcat(output_dir,'\masks\ROI_applied\'));
        for i=1:size(P1,1),
            P = strvcat(P1(i,:),P2(i,:));
            Q = [ output_dir '\masks\ROI_applied\brainmsk' num2str(su) '.img'];
            % We find the intersection by adding the two images and
            % including only those greater than 1.5, meaning both images
            % have coverage there.
            f = '(i1+i2)>1.5';
            flags = {[],[],[],[]};
            Q = spm_imcalc_ui(P,Q,f,flags);
        end
        
        % Read in the subject mask
        subj_mask=horzcat(output_dir,'\masks\ROI_applied\brainmsk',num2str(su),'.img');
        subj_data=readmr(subj_mask);
        xsub_size=subj_data.info.dimensions(1).size;
        ysub_size=subj_data.info.dimensions(2).size;
        zsub_size=subj_data.info.dimensions(3).size;
        
        % Initialize a variable to count the voxels in the subject mask
        smask_count=0;

        % Calculate the number of voxels in the individual subject mask
        for i = 1:xsub_size
            for j = 1:ysub_size
                for k = 1:zsub_size
                    current_voxel=subj_data.data(i,j,k);
                    if current_voxel == 1
                        smask_count=smask_count+1;
                    elseif (current_voxel ~= 0) && (current_voxel ~= 1)
                        error(horzcat('Subject ',num2str(su), ' has a mask that is not binarized (0s and 1s).  Please binarize the image and run again!'));
                    end
                end
            end
        end
       
        fprintf('%s','Number of voxels in subject ',num2str(su), ' mask is ',num2str(smask_count));
        fprintf('\n');

        
%-Subject Sorting
%-----------------------------------------------------------------------
% Place subject IDs into "INCLUDED," "FLAGGED," or "MISSING" variables 
% based on coverage percentage.    
     
        % If subject meets criteria, put into "INCLUDED"
        if (smask_count >= vox_min)
            inc_count=inc_count+1;
            fprintf('%s','Subject is greater than minimum of ',num2str(vox_min), ' voxels, adding to INCLUDED.');
            fprintf('\n');
            per_cov = smask_count/ROI_count;
            INCLUDED(inc_count)= struct('Subject_ID', s, 'Mask_Number', su, 'Voxels', smask_count, 'Percent_Coverage', per_cov);
        end
        
        % If subject does not meet criteria, put them into FLAGGED
        % variable. 
        if (smask_count < vox_min)
            flag_count=flag_count+1;
            fprintf('%s','Subject does not meet minimum of ',num2str(vox_min), ' voxels, adding to FLAGGED.');
            fprintf('\n');
            per_cov = smask_count/ROI_count;
            FLAGGED(flag_count)= struct('Subject_ID', s, 'Mask_Number', su, 'Voxels', smask_count, 'Percent_Coverage', per_cov);
        end
    
    else
        % If subject mask does not exist, we add them to  MISSING variable
            miss_count=miss_count+1;
            fprintf('Subject does not have a mask. Adding to ELIMINATED\n.');
            MISSING(miss_count)= struct('Subject_ID', s, 'Mask_Number', su);
    end
    
    % Clean up variables to ready for next subject
    clear xsub_size ysub_size zsub_size subj_mask subj_data subj_mask_dir

end


%-Graphical Flagged Subject Checking
%-----------------------------------------------------------------------
% Here we give the user the choice to visually browse through the 
% flagged subject masks, and decide to include each subject or not. The
% user is also given the choice to print the visual output to file.

fprintf(['There are ' num2str(flag_count) ' subjects flagged for elimination.']);
print_var=spm_input('Print views to file?',2,'Yes|No');

if exist('FLAGGED','var')~= 0
    fprintf('','%s','Would you like to visually check eliminated subjects?');
    check=spm_input('Visual Check Flagged?',1,'Yes|No');
    
    % If subject selects yes, then we present each mask and ask user to choose
    % whether or not to include it:
    if strcmp(check,'Yes')
        cd(output_dir);
        spm_figure('GetWin','Graphics');
        clear global st

        % Initialize an elim_count to keep track of subjects definitely getting
        % eliminated.
        elim_count=0;
    
        % Cycle through the flagged subjects, first show a 3D image so the user
        % can click around the mask, and then show a slices image, and then ask
        % the user if the person should be eliminated.
        for n=1:flag_count
            subj_mask=horzcat(output_dir,'\masks\ROI_applied\brainmsk',num2str(FLAGGED(n).Mask_Number),'.img');
            T1(1,:)=fullfile(spm('dir'),'canonical','single_subj_T1.nii');
            P = strvcat(T1(1,:),subj_mask);
        
            % Display with spm_check_registration
            spm_check_registration(P);
            title_handle = title('Figure 1');
            set(title_handle,'String',[ 'Mask Number: ' num2str(FLAGGED(n).Mask_Number) ])
        
            if strcmp(print_var,'Yes')
                % need to CD to right directory
                % Need to look up print and figure out how to add labels!
                spm_print();
            end

            slice_var=spm_input('Slice View',3,'View|Skip');
        
            if strcmp(slice_var,'View')
                SO=slover(); 
                SO.img(1).vol=spm_vol(subj_mask);  
                SO.img(2).vol=spm_vol(T1(1,:));   
                SO.slices = -36:2:70;
                SO=paint(SO);
            
                if strcmp(print_var,'Yes')
                    spm_figure('Print');
                end
            end
        
            % After viewing the mask, give the user the choice to eliminate the subject.
            elim_var=spm_input('Eliminate this subject?',1,'Yes|No');

            % If we eliminate the subject, we add them to the ELIMINATED
            % variable
            if strcmp(elim_var,'Yes')
                elim_count=elim_count+1;
                ELIMINATED(elim_count)= struct('Subject_ID', FLAGGED(n).Subject_ID, 'Mask_Number', FLAGGED(n).Mask_Number, 'Voxels', FLAGGED(n).Voxels, 'Percent_Coverage', FLAGGED(n).Percent_Coverage);
            end
        
            % If we don't eliminate the subject, we add them to the INCLUDED
            % variable
            if strcmp(elim_var,'No')
                inc_count=inc_count+1;
                INCLUDED(inc_count)= struct('Subject_ID', FLAGGED(n).Subject_ID, 'Mask_Number', FLAGGED(n).Mask_Number, 'Voxels', FLAGGED(n).Voxels, 'Percent_Coverage', FLAGGED(n).Percent_Coverage);
            end
        end
        close Figure 1;
    else
        % If subject selects no, then we put all flagged subjects into ELIMINATED
        ELIMINATED=FLAGGED;
        elim_count=flag_count;
    end
end
 
%-Record eliminated and incuded subjects to file
%-----------------------------------------------------------------------
% Here we want to take our ELIMINATED and INCLUDED variables and print them
% to file for the user.  The file is only created if the variables exist,
% and it includes the Subject ID, Mask Number, and Voxels included.  
% Additionally, it includes the subject count for each, the vox_min,
% ROI-count, threshold specified, and task.

% The first thing that we do is pull the location of the subject ID from the 
% path string. We do this by using regexp to search for all the '/'s, and 
% we know that the last two enclose the subject ID.  This assumes that 
% all subjects have the same top directory and ID length.

cd(horzcat(output_dir,'\logs\'));

if exist('MISSING','var')~= 0  
    % Initialize and print to file
    fid = fopen('missing.txt', 'wt');
    fprintf(fid, 'Date: ');
    fprintf(fid,'%s\n', date');
    fprintf(fid, 'Subject''s Missing: ');
    fprintf(fid, '%g\n', miss_count);
    fprintf(fid, 'ROI: ');
    fprintf(fid, '%s\n', ROI);
    fprintf(fid, 'Total Mask Size: ');
    fprintf(fid, '%g\n', ROI_count);
    fprintf(fid, 'User Specified Coverage %%: ');
    fprintf(fid, '%g\n', coverage);
    fprintf(fid, 'Coverage Minimum for Inclusion: ');
    fprintf(fid, '%g\n\n', vox_min);
    fprintf(fid, 'Subject_Path\tMask_Number\tVoxels\n');
    for i=1:numel(MISSING)
        fprintf(fid, '%s\t%d\t\n', MISSING(i).Subject_ID(1,:), MISSING(i).Mask_Number);
    end
    fclose(fid);
end

if exist('INCLUDED','var')~= 0    
    % Initialize and print to file
    fid = fopen('included.txt', 'wt');
    fprintf(fid, 'Date: ');
    fprintf(fid,'%s\n', date');
    fprintf(fid, 'Subject''s Included: ');
    fprintf(fid, '%g\n', inc_count);
    fprintf(fid, 'ROI: ');
    fprintf(fid, '%s\n', ROI);
    fprintf(fid, 'Total Mask Size: ');
    fprintf(fid, '%g\n', ROI_count);
    fprintf(fid, 'User Specified Coverage %%: ');
    fprintf(fid, '%g\n', coverage);
    fprintf(fid, 'Coverage Minimum for Inclusion: ');
    fprintf(fid, '%g\n\n', vox_min);
    fprintf(fid, 'Subject_Path\tMask_Number\tVoxels\tPercent_Coverage\n');
    for i=1:numel(INCLUDED)
        fprintf(fid, '%s\t%d\t%d\t%.3f\n', INCLUDED(i).Subject_ID(1,:), INCLUDED(i).Mask_Number, INCLUDED(i).Voxels, INCLUDED(i).Percent_Coverage);
    end
    fclose(fid);
end

if exist('ELIMINATED','var')~= 0    
    % Initialize and print to file
    fid = fopen('eliminated.txt', 'wt');
    fprintf(fid, 'Date: ');
    fprintf(fid,'%s\n', date');
    fprintf(fid, 'Subject''s Eliminated: ');
    fprintf(fid, '%g\n', elim_count);
    fprintf(fid, 'ROI: ');
    fprintf(fid, '%s\n', ROI);
    fprintf(fid, 'Total Mask Size: ');
    fprintf(fid, '%g\n', ROI_count);
    fprintf(fid, 'User Specified Coverage %%: ');
    fprintf(fid, '%g\n', coverage);
    fprintf(fid, 'Coverage Minimum for Inclusion: ');
    fprintf(fid, '%g\n\n', vox_min);
    fprintf(fid, 'Subject_Path\tMask_Number\tVoxels\tPercent_Coverage\n');
    for i=1:numel(ELIMINATED)
        fprintf(fid, '%s\t%d\t%d\t%.3f\n', ELIMINATED(i).Subject_ID(1,:), ELIMINATED(i).Mask_Number, ELIMINATED(i).Voxels, ELIMINATED(i).Percent_Coverage);
    end
    fclose(fid);
end


%-Create Results Image for BrainMasked Images
%-----------------------------------------------------------------------
% Here we add up all of the finalized masks with IMCalc and produce
% a final "coverage" image for both the whole brain and a single mask.

% Use IMcalc to create a master mask from the smaller masks.  We first need
% to prepare a list of paths to subject masks (P) and a list of i1+i2+...in
% to feed into IM_calc

if exist('INCLUDED','var')~= 0
add_var='';
P = '';

    for i=1:size(INCLUDED,2)
        pathy{i,:}=[ output_dir '\masks\ROI_applied\brainmsk' num2str(INCLUDED(i).Mask_Number) '.img' ];
    
        if (i ~= size(INCLUDED,2))
            add_var = [ add_var 'i' num2str(i) '+' ];
            P = strvcat(P,pathy{i,:});
        else
            add_var = [ add_var 'i' num2str(i) ];
            P = strvcat(P,pathy{i,:});
        end
        denom_var = size(INCLUDED,2)-.5;
    end

% Now we use IMCalc to create the group mask image
Q = [ output_dir '\results\groupmsk.img' ];

cd(horzcat(output_dir,'\results\'));

for i=1:size(INCLUDED,1)
    %We find the intersection by adding the images and
    %including only those greater than the count minus .5, 
    %meaning all subjects have coverage there.
    f = [ '(' add_var ')>' num2str(denom_var) ];
    flags = {[],[],[],[]};
    Q = spm_imcalc_ui(P,Q,f,flags);      
end
       
%-Display Results Image
%-----------------------------------------------------------------------
group_mask=horzcat(output_dir,'\results\groupmsk.img');
T1(1,:)=fullfile(spm('dir'),'canonical','single_subj_T1.nii');
P = strvcat(T1(1,:),group_mask);

cd([ output_dir '\results\' ]);
spm_figure('GetWin','Graphics');
clear global st
        
% Display with spm_check_registration
spm_check_registration(P);
title_handle = title('Figure 1');
set(title_handle,'String','Group Mask')

if strcmp(print_var,'Yes')
    spm_print();
end

slice_var=spm_input('Slice View',3,'View|Skip');
        
if strcmp(slice_var,'View')
    SO=slover(); 
    SO.img(1).vol=spm_vol(group_mask);  
    SO.img(2).vol=spm_vol(T1(1,:));   
    SO.slices = -36:2:70;
    SO=paint(SO);
   
    if strcmp(print_var,'Yes')
        spm_figure('Print');
    end
end


%-Create Results Image for Whole Brain Images
%-----------------------------------------------------------------------
% Here we add up all of the finalized masks with IMCalc and produce
% a final "coverage" image for both the whole brain and a single mask.

% Use IMcalc to create a master mask from the smaller masks.  We first need
% to prepare a list of paths to subject masks (P) and a list of i1+i2+...in
% to feed into IM_calc
clear pathy;
add_var='';
P = '';

for i=1:size(INCLUDED,2)
    pathy{i,:}=[ output_dir '\masks\mask_' num2str(INCLUDED(i).Mask_Number) '.img' ];
    
    if (i ~= size(INCLUDED,2))
        add_var = [ add_var 'i' num2str(i) '+' ];
        P = strvcat(P,pathy{i,:});
    else
        add_var = [ add_var 'i' num2str(i) ];
        P = strvcat(P,pathy{i,:});
    end
end

% Now we use IMCalc to create the group mask image
Q = [ output_dir '\results\wholebrain.img' ];

cd(horzcat(output_dir,'\results\'));
for i=1:size(INCLUDED,1)
    %We find the intersection by adding the two images and
    %including only those greater than the sum of all the images 
    % minus .5, meaning all images have coverage there.
    f = [ '(' add_var ')>' num2str(denom_var) ];
    flags = {[],[],[],[]};
    Q = spm_imcalc_ui(P,Q,f,flags);      
end
       
%-Display Results Image
%-----------------------------------------------------------------------
brain_mask=horzcat(output_dir,'\results\wholebrain.img');
T1(1,:)=fullfile(spm('dir'),'canonical','single_subj_T1.nii');
P = strvcat(T1(1,:),brain_mask);

cd([ output_dir '\results\' ]);
spm_figure('GetWin','Graphics');
clear global st
        
% Display with spm_check_registration
spm_check_registration(P);
title_handle = title('Figure 1');
set(title_handle,'String','Whole Brain Mask')
        
        if strcmp(print_var,'Yes')
            spm_print();
        end

slice_var=spm_input('Slice View',3,'View|Skip');
        
if strcmp(slice_var,'View')
    SO=slover(); 
    SO.img(1).vol=spm_vol(brain_mask);  
    SO.img(2).vol=spm_vol(T1(1,:));   
    SO.slices = -36:2:70;
    SO=paint(SO);
    
    if strcmp(print_var,'Yes')
        spm_figure('Print');
    end
end


%-Calculate Statistics for Final Group Mask
%-----------------------------------------------------------------------
fprintf('Calculating statistics of group mask...\n');
% Read in the final mask
group_data=readmr(group_mask);
xg_size=group_data.info.dimensions(1).size;
yg_size=group_data.info.dimensions(2).size;
zg_size=group_data.info.dimensions(3).size;

%Initialize a variable to count the voxels in the ROI mask
group_count=0;

%Calculate the number of voxels in the ROI mask
for i = 1:xg_size
    for j = 1:yg_size
        for k = 1:zg_size
         current_voxel=group_data.data(i,j,k);
         if current_voxel ~= 0
             group_count=group_count+1;
         end
        end
    end
end
fprintf('...done!\n');
fprintf('%s\n','Number of voxels in group mask is ',num2str(group_count));

else
    fprintf('\n%s\n','No subjects were included, so no final mask will be produced.');
    end

%-Print Statistics for Final Group Mask to File
%-----------------------------------------------------------------------
if exist('INCLUDED','var')~= 0
    % Initialize and print to file
    fid = fopen('group_inc.txt', 'wt');
    fprintf(fid, 'Date: ');
    fprintf(fid,'%s\n', date');
    fprintf(fid, 'Subject''s Included: ');
    fprintf(fid, '%g\n', inc_count);
    fprintf(fid, 'ROI: ');
    fprintf(fid, '%s\n', ROI);
    fprintf(fid, 'Total Mask Size: ');
    fprintf(fid, '%g\n', ROI_count);
    fprintf(fid, 'User Specified Coverage %%: ');
    fprintf(fid, '%g\n', coverage);
    fprintf(fid, 'Coverage Minimum for Inclusion: ');
    fprintf(fid, '%g\n', vox_min);
    fprintf(fid, 'Group Mask Size: ');
    fprintf(fid, '%g\n', group_count);
    fprintf(fid, 'Coverage Obtained: ');
    fprintf(fid, '%g\n\n', group_count/ROI_count);
    fprintf(fid, 'Subject_Path\tMask_Number\tVoxels\tPercent_Coverage\n');
    for i=1:numel(INCLUDED)
        fprintf(fid, '%s\t%d\t%d\t%.3f\n', INCLUDED(i).Subject_ID(1,:), INCLUDED(i).Mask_Number, INCLUDED(i).Voxels, INCLUDED(i).Percent_Coverage);
    end
    fclose(fid);   
end
fprintf('%s\n','Done running CovCheck Free');
end