function send_brains()
% SEND BRAIN IMAGES (send_brains.m)
% Vanessa Sochat
%
% This script takes in a list of subjects processed in SPM, creates a brain
% images zip with two .JPG images to send to the subject, and sends it.
%__________________________________________________________________________
%
% DEPENDENCIES: You need to have the crop.m script in the same folder for
% this to work.
%
% SUBJECT ID: This script is set up to work with DNS data - it is expecting
% IDs to have the format (DATE)_(SUBJECT ID).  As the subject output images
% are named with the five numbers after the "_" (representing the subject
% ID) - this is the format that the script is expecting.  If your subject
% IDs do not fit this format, you can nix the section that goes through the
% processed subject names and creates a string of modified IDs and just use
% the processed subject list raw without any changes to compare the files
% variable list to.
%
%__________________________________________________________________________
%
% USAGE: send_brains()
% no input variables are required as the program takes them into a GUI.
%__________________________________________________________________________
%
% ORGANIZATION: You should maintain the following file structure:
% Output images under DNS.01\Graphics\Brain Images
% Input Data: We will be using the processed highres under "anat" 
% sdns01-005-00001-000001-01.img, to create the image from.
%__________________________________________________________________________
%
% This script works by....
%   1. Creating the list of potential sendees - whoever has been newly 
%   processed that week and does not have a brain image created yet.
%   2. The script then presents this list to the user, and asks if he/she 
%   would like to delete any participants. This is important because we 
%   could have a test folder under Processed, or potentially a participant 
%   that we don't want to send to. To delete a participant, the user simply 
%   enters the ID into the GUI, and then the script presents the user with 
%   the new list. There is no negative consequence of making a typo and 
%   entering an incorrect ID - the script will not find the ID in the list, 
%   and will present the identical list to the user, and he/she can enter 
%   the ID again.
%   3. Next, the script looks for the processed anatomical in the subject's 
%   anat directory under Processed. This image will normally always have 
%   the same name - however in rare cases when the name is different, 
%   for whatever reason, the script will not find the highres, and will 
%   present the user with a GUI to select the image that he/she would like 
%   to use for that participant. It then prepares two slice views of the 
%   highres, crops them, puts them together as a zip, moves the zip to the 
%   Graphics/Brain Images folder, and cleans up the old files.
%   4. Once all brain image zips have been created, the script prompts the 
%   user if he/she wants to send a brain image for each subject, and asks 
%   the user to enter the email. This process is fairly rapid and easy. 
%   In the case that the user mistypes an email, the easiest thing to do 
%   is delete the output image, and quickly run the script again.
%   5. As each address in entered, the script sends the email directly from 
%   MATLAB. 
%__________________________________________________________________________
%__________________________________________________________________________


%-Global Variables
%-----------------------------------------------------------------------
fprintf('SEND_BRAIN.M Alpha\n Vanessa Sochat\n August, 2010\n');

% Here the user specifies the experiment directory
homedir = spm_select(1,'dir','Select top of experiment directory','','N:');

% Here the user specifies the output directory
output = spm_select(1,'dir','Select output directory','',[ homedir 'Graphics\' ] );

% Here we set the Processed directory
processed_dir = horzcat(homedir,'Analysis\SPM\Processed\');

% Add the path to the crop script
addpath(genpath('N:\DNS.01\Scripts\MATLAB\Vanessa\Send Brains'));

%-Identify subject list to make brain images for
%-----------------------------------------------------------------------
% Here the script compares the subjects in the "Processed" folder (meaning
% they have been processed and we can send a brain image) to the brain
% images in the output folder.  The subject IDs that appear in the Processed
% folder but not the output folder are saved into a variable as they need
% to have brain images sent.  Then, the user is allowed to delete subjects
% or text from the string, as it could be likely that there is a TEST
% folder or file in the processed directory that isn't a subject to send
% brain images to.

% First get the processed subjects
cd(processed_dir)
processed = [ ls ];

% And then we grab the subject IDs who have had brain images.
cd(output);
files = [ ls ];

% Initialize brain_list variables
brain_list = '';

% We start at the third element because the first two are "." and ".."
for c = 3:size(processed,1)
    
    % The subject ID always starts at the 10th spot, and ends at te 15th, so we
    % use those coordinates to pull the subject IDs fromn the processed variable.  
    % You will need to change this if you have a different format, or you could 
    % just get rid of it completely and use the entire subject ID for the image names.
    current_processed = processed(c,:);
    
   
    % By default, add_var starts out as 'yes' and only gets changed to
        % no if we find a matched subject ID.
        add_var = 'yes';

        % VANESSA - MIGHT WANT TO ADD SOME SORT OF BREAK IF A MATCH IS
        % FOUND, SO DON'T KEEP SEARCHING ONCE IS FOUND!
        for i = 1:size(files,1)
            % We take the first 5 characters of the file name, which is the
            % subject's ID
            subject = files(i,1:5);
            
            if strcmp(current_processed(10:14),subject)
                % If the processed subject can be found under the output files
                % list, then the brain image has already been processed and we
                % exit the loop without adding anything
                add_var = 'no';
            end
        end
        
    % After cycling through the list of brain images already made, we only
    % flag the subject as needing an image if the add_var is set to "yes" -
    % meaning that no match was ever found.
    if strcmp(add_var,'yes')
        brain_list = [ brain_list;current_processed ];
    end
    
    % and now we move on to the next processed subject at the start of the
    % loop
end

% Clean up
clear current_processed subject

fprintf('%s\n','The list of subjects that need brain images is...');
selections = listdlg('PromptString','Select Subjects to send to:','SelectionMode','multiple','ListString',brain_list);

% Pull the user selections from the brain list, and put them in the
% temp_list

add_count = 0;
for j = 1:size(selections,2)
    add_count = add_count +1;
    temp_list{add_count} = deblank(brain_list(selections(j),:));
end

clear selections
    
%-Create brain images
%-----------------------------------------------------------------------
% This part of the script goes to the subject's anatomical directory,
% creates the brain image, and saves it to the output directory.

% Initialize graphic viewer
spm_figure('GetWin','Graphics');
clear global st

% Read in logo and prepare file array (to make zip) just once!
I = imread('http://www.haririlab.com/img/logo_small.jpg');
I = imresize(I, 2);
imagefiles{1}='slices.JPG';
imagefiles{2}='sagittal.JPG';                                

for i=1:size(temp_list,2)
    subject = temp_list{i};
    
    % CD to subject's anatomical folder
    if exist(horzcat(processed_dir,subject,'/anat/'),'dir')
        cd(horzcat(processed_dir,subject,'/anat/'));
        
        % If the default anatomical/highres exists, we use that
        if exist(horzcat(processed_dir,subject,'/anat/sdns01-0005-00001-000001-01.img'),'file');
            anat = horzcat(processed_dir,subject,'/anat/sdns01-0005-00001-000001-01.img');
                
                % Create slices view and save...
                SO=slover(); 
                SO.img(1).vol=spm_vol(anat);   
                SO.slices = [-36:2:70];
                SO=paint(SO);
                
                % Add logo to slices image and save
                image(I)
                axis off
                print -dtiff -noui slices.JPG
                crop('slices.JPG');
                
                % Print sagittal view
                SO=slover(); 
                SO.img(1).vol=spm_vol(anat);   
                SO.slices = [-2:10:52];
                SO.transform = 'sagittal';
                SO=paint(SO);     
                axis off
                print -dtiff -noui sagittal.JPG
                crop('sagittal.JPG');
                
                % Prepare zip of two files
                zip('brain',imagefiles)
             
                % Save final image to output directory
                copyfile('brain.ZIP',[ output,subject(10:14),'.ZIP' ]);
                delete brain.ZIP
                delete slices.JPG
                delete sagittal.JPG
                clear SO    
        else
            % If not, we give the user the option to select the file
            h = msgbox([ 'Default highres does not exist for ' subject '!' ],'File Not Found','warn');
            uiwait(h);
            
            files = [ ls ];
            
            [ selection use_anat ] = listdlg('PromptString','Select file, or CANCEL to skip','SelectionMode','single','ListString',files);
            
            if use_anat == 1
                
                anat = files(selection,:);
                
                % Create slices view and save...
                SO=slover(); 
                SO.img(1).vol=spm_vol(anat);   
                SO.slices = [-36:2:70];
                SO=paint(SO);
                
                % Add logo to slices image and save
                image(I)
                axis off
                print -dtiff -noui slices.JPG
                crop('slices.JPG');
                
                % Print sagittal view
                SO=slover(); 
                SO.img(1).vol=spm_vol(anat);   
                SO.slices = [-2:10:52];
                SO.transform = 'sagittal';
                SO=paint(SO);     
                axis off
                print -dtiff -noui sagittal.JPG
                crop('sagittal.JPG');
                
                % Prepare zip of two files
                zip('brain',imagefiles)
             
                % Save final image to output directory
                copyfile('brain.ZIP',[ output,subject(10:14),'.ZIP' ]);
                delete brain.ZIP
                delete slices.JPG
                delete sagittal.JPG
                clear SO    
                
            else
                fprintf('%s%s%s\n','Please take not that subject ',subject,' has been skipped!');
            end
        end
    else
        fprintf('%s%s%s\n','Subject ',subject,' does not have an anat folder under Processed!')
    end
end
      
%-Send Brain Images
%-----------------------------------------------------------------------
% This part of the script goes to the output directory and sends an email
% for each subject
cd(output);

% Must be in the same folder as the script
load poozie.mat

% Then this code will set up the preferences properly:
setpref('Internet','E_mail',poozie);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',poozie);
setpref('Internet','SMTP_Password',pooziepa);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

for i=1:size(temp_list,2)
    subject = temp_list{i};
    send_var=spm_input([ 'Send image to:',subject(10:14),'?' ],1,'Yes|No');
    if strcmp(send_var,'Yes')
        email = spm_input([ subject(10:14),' email address:' ],2,'s','',1);
        
        % Check to see if the brain image exists, just in case!
        if exist([ subject(10:14),'.ZIP' ],'file')
            brain_image=[ subject(10:14),'.ZIP' ];
            % Send the email. Note that the first input is the address!
            sendmail(email,'Laboratory of Neurogenetics - Brain Image','Attached, please find an image of your brain.  This image is intended for personal use only. The image is NOT intended as and should NOT be used as a substitute for medical evaluation.',brain_image);
        else 
            fprintf('%s%s/n',subject(10:14),'.ZIP cannot be found! Brain image not sent!');
        end
    end
end

fprintf('%s\n','Done sending brain images!');

end