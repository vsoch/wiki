# Cluster Pipeline Tutorial

## Creating an SPM Batch Job to Run on the Cluster

This simple tutorial walks through some steps and ideas for creating a pipeline utilizing a matlab, bash, and python script template to run SPM analysis in a non-graphical, cluster environment.  These snippets are by no means the best or only way to achieve this functionality, but rather a collection of ideas that could be useful that I would like to share.  You can think of the relationship between these various scripts as follows:  The python can be thought of as the executer of the process, taking in all subject IDs and user variables, and submitting a bunch of instances of a template bash script (one per subject) to whatever cluster environment the job is to be run on, and each of these bash scripts further feeds the variables into the matlab template script to be launched  in matlab in the cluster environment, initialize spm, and run the job.  You can follow the steps chronologically, or use the links below to get information about a particular component.

  * [SPM Batch Editor](#spm-batch-editor) 
  * [MATLAB Script Template](#matlab-script-template) 
    * [File Manipulation](#file-manipulation) 
    * [Additional Components to Add](#additional-components-to-add) ART, Data Check, change SPM.mat paths, etc. 
  * [BASH Script Template](#bash-script-template) 
    * [Variables, File and Path Manipulation](#variables-files-and-path-manipulation) 
    * [Setting up a Graphical Environment](#setting-up-a-graphical-environment) 
  * [PYTHON Script Template](#python-script-template) 
    * [Submitting your Scripts](#submitting-your-scripts)
    * [Troubleshooting](#troubleshooting)

### SPM BATCH EDITOR

**1)** Create your batch job in the SPM Batch editor.  The best way to do this is to create a dummy data set, and manually process the data to both make sure that the pipeline works, and to check the output file names at each step.  You can start by setting the entire batch up with dependencies, running it successfully, and then go back and change the dependencies to the actual file output that was created.  When you are finished with your batch job, all paths should be filled in with the dummy data, and there should be no dependencies.  This will be helpful when you turn this script into a template.

**2)** Save the batch as a script (.m file) and a design .mat file.  The .mat will be helpful if you ever want to open up the job again in the batch editor, however for the creation of your cluster template, you will want to use the file called (name)_job.m  You can move this .m file into an experiment Scripts folder and give it a relevant name for the pipeline that you are setting up.

### MATLAB SCRIPT TEMPLATE

**3)** Open up your (name)_.job.m file in the MATLAB editor.  If you haven't already, save it somewhere salient on your local machine with a good identifying name.  You will see a bunch of cryptic lines referring to "matlabbatch."  The way that SPM works, it stores the entirety of job information in a variable called matlabbatch.  The reason that you see matlabbatch{number} is because matlabbatch is actually a cellular array. Each numbered spot corresponds to a specific module that is in your job.  The matlabbatch part is the variable name, and the part after the equals sign is the value in the variable.  There is a function in SPM called the spm_jobman that knows how to translate this cellular array into something that SPM can understand.  These matlabbatch lines will be the basic meat of your template .m script.

**4)** This tutorial will provide snippets of code that can be copy pasted into your .m script to create the template.  Since every batch job is different, you will need to carefully piece together the correct snippets of code to put together the entire thing.  As you work, keep track of all variable names that you make, as these will need to be accounted for in the bash and python template scripts that are run on the cluster. For more information about how these scripts work together, please see SPM Cluster Processing on the wiki.  The basic idea is that the python takes in user variables to submit a bunch of instances of the bash script (one per subject) to the cluster, and each of these bash scripts further feeds the variables into the matlab template script to run the job. 

#### General Tips
Any code that goes into a script can be typed into the matlab terminal and tested.  The variables you create appear in the top right of the matlab window, and typing a variable name will have it spit out in the main window.  It is recommended that when you are learning some of this syntax, to test things in the matlab terminal as you go.  This is also the best way to troubleshoot code and scripts.  You can walk through them one line at a time in the matlab terminal window to try and reproduce any errors and keep track of what variables you have in your workspace.  It is also a good strategy when you are trying to figure out how to do something, or "playing around."  Keep in mind that Matlab has its own full documentation / script library / API online, so you can search for how to do things via (insert link here) or in Google!

##### ADD A DOCUMENTATION HEADER

**5)** The longevity of a script is only as good as its documentation.  The first thing that you should add to your matlab script template is a good header.  The header should provide the script name, when it was created, by whom, and details about what it does.  It is important to have dependencies, as well as variable desriptions, and assumptions that the script makes.  An example is provided below from a script that preps data for resting connectivity analysis.  It is good to provide details about what is done, as well as intermediate and output files, if applicable.  Think of the situation of someone opening up your template script in 10 years, and needing to figure out what it is from your header.

<code matlab>
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
%--------------------------------------------------------------------------
</code>

You can of course start simple and add details as you put together the pipeline.  Here is a generic header to start with:

<code matlab>
%-----------------------------------------------------------------------
% SPM CLUSTER TEMPLATE
% Created for the Laboratory of Neurogenetics, MM/DD/YYYY
% See (insert link here and text file name) for instructions
%       By YourNameHere, Duke University
%-----------------------------------------------------------------------
</code>

##### SUBSTITUTION VARIABLES
**6)** The snippets of script provided in this tutorial contain a lot of words that look like SUB_SOMETHING_SUB.  These are text substitutions that are looked for by the bash script, and filled in with an actual variable (a folder, subject ID, path, etc).  It is important to know that these variables are linked between the python, bash, and matlab template scripts.  You will likely need to define some of your own, but first let's review the variables that are included in the script snippets on here and the python and bash templates. because they don't change.

##### NON CHANGING VARIABLES

**7)** The template matlab, bash, and python scripts include the following variables that generally do not change.  They are linked in the following way:

**SUB_BIACROOT_SUB:** this is the path to the BIAC tools on the cluster, which is usually always...  This is defined in the bash script, and carried to the matlab template.

**SUB_SCRIPTDIR_SUB:** Is the path to the script directory, assumed to be the "Scripts" folder in your Experiment directory.  This is also defined in the bash sript

**SUB_MOUNT_SUB:** Is the experiment mount on the cluster, which is a long string of letters and numbers that is a temporary path from the node that the script is running on to the data.  You can think of this as the N:/DNS.01/ part of the path.  On the BIAC cluster, this path is always referenced in the bash script as $EXPERIMENT, and does not need to be set in the Python.  You should reference this path in each template as follows:

**SUB_SUBJECT_SUB:** Is the subject ID, or the name of the folder under Data, and the name of the folder that you would want to create under Analysis

^ Variable         ^ Python         ^ Sub to Bash Script      ^ Bash Variable       ^ Sub to Matlab Template          ^
|SUB_BIACROOT_SUB| not defined    |none| $BIACROOT     | SUB_BIACROOT_SUB        |
|SUB_SCRIPTDIR_SUB| not defined    |none| $SCRIPTDIR     | SUB_SCRIPTDIR_SUB        |
|SUB_MOUNT_SUB| experiment    | none - fed in with qsub as "experiment" | $EXPERIMENT     | SUB_MOUNT_SUB        |
|SUB_SUBJECT_SUB| subnums - list of all IDs    | SUB_SUBNUM_SUB | $SUBJ     | SUB_SUBJECT_SUB        |
|| subnum - single ID     

It is your decision if you want to feed the substitutions into each file path, or make variables from the substitutions that can be referenced later.  It is generally easier to make your variables that are substituted as simple as possible to allow for the greatest use.

##### BIAC CLUSTER HEADER
**8)** Since running spm and other tools in matlab is dependent on having the correct paths added to the workspace, this is the first thing that your script should do.  Right underneath your documentation header you will want to copy paste the BIAC CLUSTER HEADER. as shown below:

<code matlab>
%% BIAC CLUSTER HEADER
% Add necessary paths for BIAC, then SPM and data folders.
BIACroot = 'SUB_BIACROOT_SUB';
startm=fullfile(BIACroot,'startup.m'); if exist(startm,'file'); run(startm); else; warning(sprintf(['Unable to locate central BIAC startup.m filen  (%s).n Connect to network or set BIACMATLABROOT environment variable.n'],startm)); end; clear startm BIACroot;
addpath(genpath('SUB_SCRIPTDIR_SUB')); addpath(genpath('/usr/local/packages/MATLAB/spm8')); 
</code>

The BIACROOT is detailed in [[cluster_pipeline_tutorial#NON CHANGING VARIABLES|NON CHANGING VARIABLES]] and is a path to a folder on BIAC with a custom file of pathdefinitions (starm) for running matlab on the cluster.  The first section of this header looks for this file, and alerts the user if it isn't found.  If you want to use a custom path definition file, then you can change the path to the startm variable.  Generally, it is easier to stick with BIACs file and add paths that you need using addpath(genpath()), as shown above.  Using just addpath() only adds one folder, while addpath(genpath()) adds the path with all subdirectories.  In the snippet above you will see that we add paths to the installation of spm8 on the cluster, as well as the script directory, where your template script and any other scripts that you call can reside.

Other paths that you might want to add include the paths to your single subject raw Data, as well as Analyzed and Processed folders.  Since adding a folder with subdirectories to the path means that matlab will search the entire thing exhaustively looking for each function call, it is smart to add the path for only your single subject, as opposed to the entire Data or Analysis folders.  So you would want to do something like:

<code matlab>
addpath(genpath('SUB_MOUNT_SUB/Data/Anat/SUB_SUBJECT_SUB'));
addpath(genpath('SUB_MOUNT_SUB/Data/Func/SUB_SUBJECT_SUB')); 
addpath(genpath('SUB_MOUNT_SUB/Analysis/SPM/Processed/SUB_SUBJECT_SUB'));
addpath(genpath('SUB_MOUNT_SUB/Analysis/SPM/Analyzed/SUB_SUBJECT_SUB'));
</code>

The above shows adding paths to the subject's functional and anatomical data, as well as the appropriate folders under Processed and Analyzed.  Keep in mind that SUB_MOUNT_SUB refers to the experiment folder, and SUB_SUBJECT_SUB should refer to the subject folder / ID. An important note is that, for any folders that are created at the time of the script run that the matlab template will search through, it is wisest to create these in your bash script and then add them as paths in your matlab script.  That way, when you type the command addpath(genpath, all subfolders are already created and added to the path.  If you choose to make directories in your matlab template script that are not part of the current path, just make sure to add them with the command above.

##### INITIALIZE SPM JOBMAN
**9)** Before you do anything with matlabbatch, you need to "warm up" the spm module that will read matlabbatch, which is called the spm_jobman.  So next in your script you will want to have the following:

<code matlab>
spm('defaults','fmri');spm_jobman('initcfg');    % Initialize SPM JOBMAN
</code>

This line tells the spm_jobman that we want to initialize both spm and the spm_jobman with the default settings.

##### GLOBAL VARIABLES CREATION

**10)** You could write out a full path every single time a path is referenced, or you could create global variables for paths to be referenced later, to make life easier.  A path is nothing but a string variable.  Keep in mind that the cluster is a unix environment, so the "correct" direction of the slash is "/"  On windows (and you will likely see this in paths in your matlabbatch created in windows) the direction is ""  An incorrect direction can sometimes lead to script errors, so make sure that all directions are "/" for a unix environment.  Here are examples of how to set the start of a path to data directories and Analysis directories:

<code matlab>
%Here we set some directory variables to make navigation easier
homedir='SUB_MOUNT_SUB/Analysis/SPM/'; 
scriptdir='SUB_MOUNT_SUB/Scripts/'; 
datadir='SUB_MOUNT_SUB/Data/';
</code>

The above directories say that 'SUB_MOUNT_SUB/Analysis/SPM/' is a string that is placed in the homedir variable, for example.  We can use commands called horzcat to put different strings together to make a full path.  You can try this out on the MATLAB command line to see how it works.  For example, let's look at having subject, data, and task name variables, and putting them together into one string.

<code matlab>
subject = '12345_1234'
task = 'faces'
</code>

Keep in mind that strings in matlab are placed into quotes.  If you have a number variable, you could say number = 1.  For paths you will always use strings. Matlab will spit out an error if you have the wrong type of something.  With horzcat, however, you can concatenate numbers and strings.  For the above we could do:

<code matlab>
mynewpath = horzcat(homedir,subject,'/',task,','/','myimagename.img'); 
% would mean that mynewpath is SUB_MOUNT_SUB/Analysis/SPM/12345_1234/faces/myimagename.img
</code>

Note how each variable is references as is, and separated by commas.  Since the task and subject variables don't end in "/" (since we don't always want to use them as a path) note how we have added the "/" as strings to be concatenated.  We finish with the name of an image that the variable is pointing to. Keep in mind that it's a very common error to forget a slash, or accidentally have multiple.  When matlab spits out an error that it cannot find a path, the first thing to do is usually to check that the path is correct and exists!

So you can see how it would be easy to create global paths, and then do things like:

<code matlab>
% Create a path variable and go there later
mypath = horzcat(homedir,subject,'/',task,','/');
cd(mypath)

% Go directly to a concatenated path without creating a variable
cd(horzcat(homedir,subject,'/',task,','/')
</code>

So it's a good idea at the creation of your template script to figure out the main directories that you are going to be jumping around to, and creating the appropriate variables, using SUB_MOUNT_SUB as a substitution for the experiment folder, and SUB_SUBJECT_SUB as a substitution for the subject ID/folder name.


#### DIRECTORY CREATION and FILE MANIPULATION
Before editing your matlabbatch variable, you will likely need to do some file manipulation or directory creation.  As you walk through your script, keep in mind of the "present working directory" - or where you are.  When the template script first starts running, it is likely located in what you could call the home folder of the node, as opposed to anywhere within your experiment directory.  So you will want to use [=cd=] to change directories, and as you move through your script, ALWAYS ask yourself where you are before writing commands.  The following examples should help you to put together code to move, copy, and navigate.

<code matlab>
% Moving to different directory - variable directory name
cd(variable_directory_name)

% Moving to a different directory - string name
cd N:/Path/goes/here
cd('N:/Path/goes/here')

% Creating a directory
mkdir namegoeshere
mkdir('N:/Path/goes/here')
mkdir N:/Path/goes/here

% Delete files
delete file.img
delete file.*

% Delete a directory
rmdir directoryname

% Copy data
% data_to_copy should be a full path to a file, either in a variable, or as a string input into the function
% destination should also be a variable or a string itself.  If destination is a directory, the copied file will have the same name.  To rename
% the file, have the destination string or variable include the new file name and extension.
copyfile(data_to_copy,destination)
</code>


##### RESPONSIBLE FILE MANIPULATION
Many times, a script needs to move, copy, or delete files.  It is always smart to include checks before any file manipulation to make sure that you are in the correct directory, or working with the correct file.  If you were to cd to a directory and then run a delete command, in the case that there was an error in navigating to the directory and you didn't put any checks, you would run the delete command in the previous directory.  Bad. You can use if statements with the delete/move/copy inside to ensure that criteria are met before any file manipulation.

<code matlab>
% Check to see if a directory exists
if isdir(directory)
	% Code to execute if the directory exists
end

if isdir(directory)==0
	% Code to execute if the directory does NOT exist
end

% Check to see if a file exists
if exist(filevariable,'file')
	% Write code here to execute if the file exists
end
</code>


##### CUSTOM RUN-TIME VARIABLES
Very commonly it is useful to have variables in your python script that can be set to "yes" and "no" or "1" and "0" to dictate if things should be run, or not.  These variables can be passed through the bash script like any other variable, and then you can use a function called strcmp (string compare) to make yes/no decisions about entering loops.  For example, let's say we have a section of the script that we want to run ONLY if the user has selected to process a task called faces.  Let's assume that this choice (yes or no) gets fed into the matlab template script as SUB_FACESRUN_SUB.  We then can do the following:

<code matlab>
if strcmp('SUB_RUNFACES_SUB', 'yes');
	% Insert code here to execute if the user has chosen "yes" to run faces, meaning the variable filled in to SUB_RUNFACES_SUB is 'yes'
end
</code>

Keep in mind that if you include conditional statements for parts of the matlabbatch, your script must accomodate running with or without the section. This means that if matlabbatch{1} comes before the conditional statement, and matlabbatch{2} is inside, and then you want matlabbatch{3} to happen after, you would either need to submit the spm_jobman to run AFTER the conditional loop and start your old matlabbatch{3} as matlabbatch{1}, or in the case that the loop isn't entered, do something like matlabbatch{2} = matlabbatch{1} to run the exact same analysis again in the second cell, and then jump to matlabbatch{3}.  If you jump from matlabbatch{1} to matlabbatch{3} without setting anything for matlabbatch{2} you will get an error!  The else statement (part of the if loop) is helpful in cases like this.  For example:

<code matlab>
matlabbatch{1} = ...
matlabbatch{1} = ...
matlabbatch{1} = ...

if strcmp('SUB_RUNFACES_SUB', 'yes');
	matlabbatch{2} = ...
	matlabbatch{2} = ...	
else
	matlabbatch{2} = matlabbatch{1}
end

matlabbatch{3}
</code>

If you choose this method, make sure that it is OK to run the same thing twice!  Otherwise, you will want to submit the spm_jobman, and re-initialize, detailed below.


##### EDITING THE MATLABBATCH

When your directories and global variables are set up, you can start to edit the matlabbatch section of the code.  Keep in mind that you have already intitialized the spm_jobman, and when you add the many lines of matlabbatch, you are simply putting together a large variable (a cellular array).  Nothing happens in terms of running anything until you submit the spm_jobman with the following:

<code matlab>
spm_jobman('run_nogui',matlabbatch);  clear matlabbatch     %Execute the job to process the anatomicals and clear matlabbatch
</code>

The lines above tell the jobman to run without a GUI, and to use the matlabbatch variable.  It is safe enough to copy paste the code above directly below the end of your matlabbatch variable specification.  If you need to break up your job further into different matlabbatch instances (in the case that you have conditional blocks for running a task, for example) you can simply re-initialize and re-submit the spm_jobman at the beginning and end of the conditional block.  Don't forget to clear the matlabbatch variable between uses, or else you will likely have overlap between jobs that would lead to an error!

##### Creating File Paths
In many cases, the spm batch will require a long list of file paths, printed out in the matlabbatch as such.  You could edit the strings to each include various substitutions, or you could use some code to populate this file path variable.  The following example shows how to create a cellular array of paths, called imagearray, and then set it to the data variable in a particular matlabbatch:

<code matlab>
V00img=dir(fullfile(datadir,'Path/to/data/image_prefix*.dcm')); 
numimages = length(V00img);
for j=1:numimages; 
	imagearray{j}=horzcat(datadir,'Path/to/data/',V00img(j).name); 
end 
clear V00img;

matlabbatch{2}.spm.util.dicom.data = imagearray;
clear imagearray;
</code>

V00img is an array variable that we are creating to put a bunch of custom dicom image paths.  The fullfile function in matlab will put together a bunch of strings to make a complete path (in this case, a datadirectory variable (datadir) and then a string path, and all images that start with "image_prefix" and end with the extension ".dcm"  We then create a variable called "numimages" to hold the number of images of this type found, which is the length of the V00img array.  We could also skip over this variable and just reference length(V00img), but it's nice to have this variable in the script in the case that fullfile finds more images than you want to use.  If you wanted to use the first 171 out of 172 total images, you could set numimages = 171.  You could also achieve this functionality by tweaking the range of the loop that cycles  through the images and puts them into the imagearray variable.  Instead of saying for j = 1:numimages, you might say j = 5:numimages, or j=1:171, or whatever range you desire!
The next line in the for loop puts a concatenated string of the path (using horzcat) with the name of the image at the jth location (V00img(j).name) into a spot in the imagearray variable (also at j).  The imagearray should be filled from 1 through n, so if you change the code around so that the loop doesn't go from 1 to n, you will want to create separate variables for cycling through the for loop and referencing imagearray{ } and V00img( ).

Keep in mind that when you refernce a spot in an array, using { }'s will usually refer to the contents within a cell, while the ( ) is a pointer to the cell itself.  So if you have a cell with a string array in it, if you type myvar{1} into matlab, it will display

<code matlab>
mystring
</code>

If you type myvar(1) you will see

<code matlab>
'mystring'
</code>

the difference (I think) is that the first is referencing the string itself, while the second is referencing the cell, so it shows the 'mystring' as a string variable inside the cell.  For the purposes of setting paths in the array, we generally want to use the { }.  There are likely cases with matlabbatch variables when it expects a different type of variable to hold your paths, in which case you can troubleshoot in matlab to figure out what is expected, or look at the original matlabbatch job script (.m) file.

At the end it is a good idea to clear the V00img variable, especially since we have already put the paths into the matlabbatch variable, as is done above with the clear command.


##### Exit from Matlab
Since we are calling matlab from a bash script (meaning from command line in likely a unix environment) if we don't have "exit" at the end of our script, we will never leave matlab, and the job will run until it's terminated by some other process.  So make sure the last line of your script is

<code matlab>
exit
</code>


##### ADDITIONAL COMPONENTS TO ADD
The snippets below are examples of other functionality that you want want to integrate into your template script.

**Modifying a path (the imagearray variable by a letter or so).**  In many of SPM's processing modules, the output of one module is simply adding a letter prefix to a set of images, such as going from V0001.img to uV0001.img after you have realigned and unwarped.  In cases like this, instead of completely re-doing your imagearray variable each time, you can opt to not clear the array, and use it again, simply adding a "u" to the image names.  For example, here we set up the original imagearray variable based on a list of V00*.img files:

<code matlab>
V00img=dir(fullfile(homedir,'Path/to/images/','V0*.img')); numimages = 195;
for j=1:numimages; imagearray{j}=horzcat(homedir,'Path/to/images/',V00img(j).name,',1'); end; clear V00img;
</code>

and here we modify the imagearray variable to change the image name from V00*.img to uV00*.img

<code matlab>
% Create array of uV* image paths
for j=1:numimages; imagename=imagearray{j}(regexp(imagearray{j},'V0'):end); holder{j}=horzcat(homedir,'Path/to/image/u',imagename); end;
    imagearray = holder; clear holder;
</code>

The function "regexp" is in reference to "regular expressions" - which are commonly used in many scripting languages to find particular patterns of text.  In the example shown here, the string to be searched is the first argument, and the pattern to be searched for is the second, 'V0'  This function will return the starting location of this particular pattern as an index (a number).  In the example above, this index is used to grab the entire name V00*.img from it's start (indicated by the V0 index) to the end.  This name is placed in the "imagename" variable, which is then used to create a new image path to be placed in a holder variable, being sure to add a "u" to the beginning.  After the holder has been filled for every image in the original imagearray, we replace the entire imagearray with holder, and then can use the variable imagearray with the new paths to be as a data input for the next matlabbatch.


##### Checking Registration and Printing a PDF
This original functionality and idea was implemented by Patrick Fisher, who was a postdoc at the University of Pittsburgh and is now galavanting around Germany.  It has been modified a few times but the idea is the same.  We navigate to a folder with smoothed, realigned and unwarped, and normalized images, and place 12 randomly chosen images into a chreg_task variable, and then use spm's check_registration script to bring up an image of the 12 images, which we can print to file using spm_print.

After initial pre-processing batch file is completed Check Registration will be used to create visualizations of a random set of 12 smoothed functional images for each of the three tasks.  The reason for this is to approximate whether, across all scans, the smoothed image files are of good quality.  

The example below randomly generates 12 numbers between 1 and n.  These 12 numbers correspond to the swuV* images that will be loaded with check_registration to visualize 12 random smoothed images from the tasks Processed Data. The first line after the cd allocates a spot in memory for the array so that it doesn't have to find a new spot for every iteration of the loop. i should be the number of total images, and 12,104 means that we are allocating an array of length 12 with 104 characters (the length of the file path).

<code matlab>
cd(image_directory)

i = 171; chreg_task = char(12,104); f = ceil(i.*rand(12,1));
    for j = 1:12
        if f(j) < 10; chreg_task(j,1:104) = horzcat(homedir,'Path/to/images/swuV000',num2str(f(j)),'.img,1'); end;
        if f(j) >=10; if f(j) < 100; chreg_task(j,1:104) = horzcat(homedir,'Path/to/images/swuV00',num2str(f(j)),'.img,1'); end; end;   
        if f(j) >=100; chreg_task(j,1:104) = horzcat(homedir,'Path/to/images/swuV0',num2str(f(j)),'.img,1'); end;
    end; spm_check_registration(chreg_task); spm_print  %spm_print will print a *.ps of the 12 smoothed images files to the same *.ps file it created for the other components of the pre-processing
end
</code>


##### CHANGING PATHS IN SPM.MAT
A huge challenge in doing any sort of processing with SPM in a cluster environment has to do with the paths that are set in the SPM.mat (the design matrix) to the original swu images, and the swd (standard working directory).  If you process a single subject or group analysis in a cluster environment with temporary paths and then load the SPM.mat in matlab, if you look at the following variables:

<code matlab>
SPM.swd
SPM.xY.P
SPM.VY.fname
</code>

you would see paths to the various images and standard working directory that are set based on where the analysis is done.
Clearly, any cluster processing needs to have a step at the end that changes any temporary paths (random strings of letters and numbers) into a path that makes sense on  local machine (like N:/TASK.01/etc).  If the data is stored on a mapped server, this would be good rationale for each computer that maps the data to use a common drive.  To fix this issue, there are a series of scripts that can be called with input arguments  to fix the paths.

This first script is meant for paths with a different SPM.swd path.  The first argument is the SPM.swd path to change, the second is the SPM.xY.P and SPM.VY.fname path to change (which are the same), the third input argument is the path to change all three to, and the last is the slash direction desired. We of course want to make sure that we are in the same directory as the SPM.mat before running.  Since you can only have one SPM.mat per directory, the function is called and looks to load this file.

<code matlab>
% spm_change_paths_swd
cd(horzcat(homedir,'Path/to/task/')); 
spm_change_paths_swd('/ramSUB_MOUNT_SUB/','SUB_MOUNT_SUB/','N:/TASK.01/','/');
<code>

The simpleset version (spm_change_paths) only takes three input arguments, as it assumes that the beginning section of all paths to change is the same for all three variables.  The second argument is the path to change to, and the third is the direction of the slash desired.  In this case, SUB_MOUNT_SUB refers to the temporary path, and is filled in by the bash script at runtime.	

<code matlab>
% spm_change_paths
cd(horzcat(homedir,'Path/to/task/')); 
spm_change_paths('SUB_MOUNT_SUB/','N:/TASK.01/','/');
</code>

I did not write the original spm_change_paths script, however I did modify it to create spm_change_paths_swd, as well as spm_change_paths_dti (for dti design matrices) as well as spm_change_paths_reverse, which does the exact opposite - taking the local path and changing it to a cluster path, for analysis like PPI that require taking a design matrix set for a local machine and loading it successfully back in a cluster environment to extract timeseries data.  The idea behind these scripts is simple - you load the SPM.mat, identify the old path and the old slash direction, take a new slash direction and path as input, and rewrite the variables with the new path portion and the part of the old path that you want to keep.  With this functionality you can do any sort of analysis in a cluster environment that creates design matrices with embedded paths.  From this basic idea I was able to create scripts to work with the CONN toolbox from MIT to set up and process/run groups of many subjects, and then go back into the design matrix (that can be opened in a GUI on a local machine) and change all the embedded paths from cluster to local.  Thus, instead of spending hours clicking through one subject in a time in a GUI, a script can do everything for you.  It's lovely how matlab is transparent enough to be able to figure that out!  Thank you Matlab <3!

These scripts of course would need to be located in a folder (such as the Scripts directory linked to SUB_SCRIPTDIR_SUB) that is added to the matlab path.


#### RUNNING ART BATCH
The artifact detection tool (ART and ART Repair) can be used to find motion outliers in a SPM single subject analysis. The output of running ART Batch can be used towards ART Repair (to "fix" the data), or used as a covariate in another single subject analysis.  We run a task "pseudo first level" analysis to create an original SPM.mat, then we run ART batch on this SPM.mat to find the motion outliers, and then we use this motion outlier text file as a regressor file / input to an equivalent first level analysis.  You can find the tools at http://www.nitrc.org/projects/artifact_detect/ and again, make sure that these scripts are located somewhere that MATLAB can find them, such as the Scripts directory linked to SUB_SCRIPTDIR_SUB.

<code matlab>
addpath(genpath('SUB_MOUNT_SUB/Scripts/SPM/Art')); cd(horzcat(homedir,'Subject/Task/Directory'))

% ARTBATCH - TASK
art_batch(horzcat(homedir,'Subject/Task/Directory/SPM.mat'));
</code> 

It isn't necessary, but it's another step of carefulness to also specify the complete path to the SPM.mat.  ART will automatically generate various graphical window popups, so it's important to have support for graphics (discussed later in the bash script template area).  Once art has finished, it produces a motion outliers file that starts with "art_regression_outliers_" and ends with the name of the first image specified in the SPM.xY.P variable.  This could be fed into a single subject analysis as  regressor, an example of the line to add it from the fmri specification module is shown below:

<code matlab>
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {horzcat(homedir,'Path/to/swu/data/art_regression_outliers_swuV0001.mat')};
</code>

##### DATA CHECK (Results report for single subject analysis)
In addition to using the registration check utility to look at 12 randomly selected swu (smoothed, reaigned and unwarped, and normalized images) it is also helpful to create a results report for a single subject analysis to check the activation maps.  The results report is just another module in the SPM batch utility, and so generating the matlabbatch code to do a report can be done just like with any module, however since this is an important part of our pipeline and I will include examples of how to convert the resulting .ps file to .pdf and move it around using bash, I will also include the matlabbatch code as an example here.  I've also added another example of using strcmp() to determine whether or not to run this section, depending on if the user has said "yes" to run the task:

<code matlab>
% TASK Data Check
if strcmp('SUB_RUNTASK_SUB','yes')
    spm('defaults','fmri'); spm_jobman('initcfg');			% Initialize spm jobman
    cd(horzcat(homedir,'Path/to/first/level/analysis'));
    matlabbatch{1}.spm.stats.results.spmmat = {'SUB_MOUNT_SUB/Path/to/first/level/analysis/SPM.mat'};
    matlabbatch{1}.spm.stats.results.conspec.titlestr = 'SUB_SUBJECT_SUB Contrast > Name';
    matlabbatch{1}.spm.stats.results.conspec.contrasts = 1;		% Contrast number
    matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none'; % none or FWE
    matlabbatch{1}.spm.stats.results.conspec.thresh = 0.001;      % Threshold
    matlabbatch{1}.spm.stats.results.conspec.extent = 10;	      % Voxel extent
    matlabbatch{1}.spm.stats.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
    matlabbatch{1}.spm.stats.results.units = 1;
    matlabbatch{1}.spm.stats.results.print = true;
    spm_jobman('run_nogui',matlabbatch);clear matlabbatch		% Submit jobman and clear matlabbatch variable
end
</code>

##### DATA CHECK (display an anatomical image)
A similar check for an anatomical image would be using the display image component of the batch editor to produce and print an image. An example is shown below.

<code matlab>
% T1 Data Check
cd(horzcat(homedir,'Path/to/anat'))

% Define your image.  Use regular expressions if the name isnt predictably one thing or another.

if exist('sdns01-0005-00001-000001-01.img','file'); tone = 'sdns01-0005-00001-000001-01.img';
elseif exist('sDNS01-0005-00001-000001-01.img','file'); tone = ('sDNS01-0005-00001-000001-01.img'); end;

% Only run if the variable tone exists, meaning that the T1 image was found.
if exist('tone','var')
   spm('defaults','fmri'); spm_jobman('initcfg');    
   matlabbatch{1}.spm.util.disp.data = { 'SUB_MOUNT_SUBPathtoanat' tone }; 
    spm_jobman('run_nogui',matlabbatch); spm_print; clear matlabbatch; 
end
</code>


##### FINISH UP MATLAB TEMPLATE

Again, don't forget to exit at the end!  Once you have your matlab script template, you will likely want to give it a good identifying name, and put it in some experiment scripts folder that can be accessed on the cluster and found by the bash script.  You will next need to make your python and bash scripts for actually populating this template with actual subject specific variables, saving a copy of the subject specific template to the single subject directory, and then launching matlab and running it in the cluster environment.


#### BASH SCRIPT TEMPLATE
The bash and python script templates are to be stored on your head node, which is where you log in and would submit jobs to the cluster.  You can think of the bash and python script as a team that work together with the matlab template to run a pipeline.  Since you might have many teams of this sort, it is useful to have different folders/subfolders in your home folder to best organize scripts.  It is also wise to have regular backups of your scripts, in the case that anything explodes.  

**Creating the bash script**
**1)** Log into your home folder on the cluster, likely with ssh.  You can make directories with "mkdir name" and then use a text editor such as nedit, emacs, or nano to start with a blank script.  You will want to save your script as a shell script, with the extension .sh.  The following code is an example of what the header / top of your script should contain.  The first line is important to identify it as a bash script, and the next section should give good documentation of what the script does.  It is also helpful to have some description of return codes, and a change log of updates.

<code bash>
#!/bin/sh

# -------------- YOUR SCRIPT NAME TEMPLATE ----------------
#
# This script takes anatomical and functional data located under
# Data/fund and Data/anat and performs all preprocessing
# by creating and utilizing two matlab scripts, and running spm
# After this script is run, output should be visually checked
#
# ----------------------------------------------------

# Return Codes
#     Successful completion: return 0
#     If you need to set another return code, set the RETURNCODE
#     variable in this section. To avoid conflict with system return
#     codes, set a RETURNCODE higher than 100.
#     eg: RETURNCODE=110

# Change Log
# 12/15/2010: Added automatic generation of reg check .ps files
# 12/20/2010: Added Results report for task1 and task2 to 2nd .m, and conversion/relocation of .ps
</code>

The next part, the global and user directive, are important for setting up the EXPERIMENT variable on the cluster at Duke.  This section and these variables would be specific to whatever cluster environment the job is being submit on.

<code bash>
# --- BEGIN GLOBAL DIRECTIVE --
#$ -S /bin/sh
#$ -o $HOME/$JOB_NAME.$JOB_ID.out
#$ -e $HOME/$JOB_NAME.$JOB_ID.out
#$ -m ea
# -- END GLOBAL DIRECTIVE --

# -- BEGIN PRE-USER --
#Name of experiment whose data you want to access
EXPERIMENT=${EXPERIMENT:?"Experiment not provided"}

source /etc/biac_sge.sh

EXPERIMENT=`biacmount $EXPERIMENT`
EXPERIMENT=${EXPERIMENT:?"Returned NULL Experiment"}

if [ $EXPERIMENT = "ERROR" ]
then
exit 32
else
#Timestamp
echo "----JOB [$JOB_NAME.$JOB_ID] START [`date`] on HOST [$HOSTNAME]----"
# -- END PRE-USER --
# **********************************************************

# -- BEGIN USER DIRECTIVE --
# Send notifications to the following address
#$ -M SUB_USEREMAIL_SUB

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# Your Script goes here!
</code>

#### Variables and Path Preparation

Firstly, documentation is king (or queen).  You should assume that someone might look at your script in the future that has no idea about how anything should be done. He or she should be able to follow along and understand your code.  

Keep in mind that this bash script is used as a template by a python script, so it has text substitutions for variables.  VERY IMPORTANT:  Since the python has text substitutions for the bash, and the bash has text substitutions or the matlab script (for the same variables) you MUST have different SUB_SOMETHING_SUB names for each, or else the python will ALSO fill in the variable for the SUB_SOMETHING_SUB text that is used to find the substitutions in the matlab template.  For example, we might have a subject ID variable in the python script that is fed into the bash with the text identifier SUB_SUBJ_SUB.  If the section of the bash script that specifies the identifier for the matlab template also uses SUB_SUBJ_SUB, then it will get overwritten with the subject ID, and fail to pass the ID into the matlab template.  What you want to do is put the SUB_SUBJ_SUB into a variable, perhaps $SUBJ, and then in the section that feeds the $SUBJ variable into the matlab script template, use a slightly different substiution like SUB_SUBJECT_SUB.  It doesn't matter what standard you adopt, as long as you can keep track of the passing of all of your variables.  

To step back, we are writing the first section that is going to take the variables from the python script and pass them into the bash script.  We might do something like the following: 

<code bash>
# ------------------------------------------------------------------------------
#  Variables and Path Preparation
# ------------------------------------------------------------------------------

# Initialize input variables (fed in via python script)
SUBJ=SUB_SUBNUM_SUB          # This is the full subject folder name under Data
RUN=SUB_RUNNUM_SUB           # This is a run number, if applicable
ANATFOLDER=SUB_ANATFOL_SUB   # This is the name of the anatomical folder
TFOLD=SUB_TONEFOLD_SUB       # This is the name of the highres folder
TASKFOLD=SUB_TASKFOLD_SUB    # This is the name of the task functional folder
TASKRUN=SUB_TASKRUN_SUB      # yes runs, no skips processing task
JUSTFUNC=SUB_JUSTFUNC_SUB    # yes skips anatomical processing, to be used if you have manually

# set the origins of anatomical and need to re-run faces, cards, rest
PREONLY=SUB_PREONLY_SUB      # yes only prepares the images / folder for AC-PC realign
TASKORDER=SUB_ORDERNO_SUB   # this is the task order that determines the matlab script template to use
</code>


Note that each variable has a description, so when you look at this script in 6 months it will still make sense!  To provide more detail about the substitutions, if your python is coded to look for every instance of SUB_SUBNUM_SUB and replace it with the subject ID, for example, when the template is used to make the iteration of the bash script to be run, the first line might instead be changed to:

<code bash>
SUBJ=123456_1234
</code>

where 123456_1234 is the subject ID.  Remember that a bash script is basically a compilation of commands that could be typed into the terminal window, so if you ever need to test any sort of scripting, you can just do so on the command line.  When you create a variable you can just type MYVAR=1 however when you reference the variable, you would want to call $MYVAR

Next it might be a good idea to create folders and do any file manipulation that is required for your job.  For example, you might want to create a series of output folders in the bash script and then add the top folder to the path in the matlab template, and since the subfolders are already created, they all get added to the path.

<code bash>
#Make the subject specific output directories
mkdir -p $EXPERIMENT/My/Path/$SUBJ
mkdir -p $EXPERIMENT/Other/Path/$SUBJ
mkdir -p $EXPERIMENT/Other/Path/$SUBJ/Scripts
</code>

Then I usually like to create some global variables for various directories, so they can be easily referenced.

<code bash>
# Initialize other variables to pass on to matlab template script
ANATDIRECTORY=$EXPERIMENT/Data/Anat/$SUBJ/$ANATFOLDER # This is the location of the anatomical data
T1DIRECTORY=$EXPERIMENT/Data/Anat/$SUBJ/$TFOLD        # This is the location of the anatomical data
OUTDIR=$EXPERIMENT/Path/to/output/$SUBJ               # This is the subject output directory top
SCRIPTDIR=$EXPERIMENT/Scripts/SPM                     # This is the location of our MATLAB script templates
BIACROOT=/usr/local/packages/MATLAB/BIAC              # This is where matlab is installed on the custer
</code>

If you remember from the matlab template, we had a script directory and a BIAC root variable that were to be fed in from the bash script.  The last two llines above are setting the path to these two variables!


##### Conditional Statements
Many times, you will only want a copy to happen, or a template to be created and run given the value of a particular variable.  Here is an example of an if statement that checks if a string variable is equal to something else:

<code bash>
if [ $JUSTFUNC == 'no' ]; then
	# insert code here of what you want to do!
fi
</code>

You could just as easily check for another string:

<code bash>
if [ $ANATFOLDER == 'series002' ]; then
	# do something awesome
fi
</code>

Note that if loops end in fi, and the "then" portion must be on a separate line (in this example the ; also indicates the end of  line)

##### Changing Directory
Just like any other command line environment, cd is the command to change directory.

<code bash>
cd $ANATDIRECTORY
</code>


##### Selecting Files
The * can be used as an infinite identifier, if you wanted to select a file that doesn't have a constant name:

<code bash>
ANATFILE=*01.dcm
</code>

Another thing you might want to do is extract a particular sequence of letters from a file name and put it into a variable.  The way to do that is to echo the variable (which would print it o the command line) and cut out a particular index of values ( cut -c1-26 ) and put that into a new variable.

<code bash>
ANATPRE=$(echo $ANATFILE | cut -c1-26)
</code>

##### Deleting Files
The rm command can be used to delete a file, or rmdir to delete a directory.  Be VERY careful with these commands!  You will likely want to check that the file or directory exists where you are first with an if statement before doing anything:

<code bash>
if [ -e "path/to/file/file.img" ]; then
	rm path/to/file/file.img
fi
</code>

The -e tag specifies "exist," while you can use the -d tag to look for a directory.

**Create and submit your MATLAB script from the template** 
When all your files are copied and directories made, it is time to create a subject specific instance of your matlab template, save it to the single subject directory, and then submit it to run in matlab.  The example below does exactly that, using the sed command, which I think is bash's equivalent of regular expressions.  The sed command looks through your template file (template.m) and finds all the indicated text instances (SUB_SOMETHING_SUB) and replaces them with the indicated variable ($VAR) and then lastly, saves the subject specific template to the output directory (<$i> $OUTDIR/subject_template.m).

<code bash>
# Change into directory where template exists, save subject specific script
cd $SCRIPTDIR

# Loop through template script replacing keywords
for i in 'template.m'; do
sed -e 's@SUB_BIACROOT_SUB@'$BIACROOT'@g' 
-e 's@SUB_SCRIPTDIR_SUB@'$SCRIPTDIR'@g' 
-e 's@SUB_SUBJECT_SUB@'$SUBJ'@g' 
-e 's@SUB_ONLYDOPRE_SUB@'$PREONLY'@g' 
-e 's@SUB_TASKFOLDER_SUB@'$TASKFOLD'@g' 
-e 's@SUB_RUNTASK_SUB@'$TASKRUN'@g' 
-e 's@SUB_MOUNT_SUB@'$EXPERIMENT'@g' 
-e 's@SUB_ANATFOLDER_SUB@'$ANATFOLDER'@g' 
-e 's@SUB_TFOLDER_SUB@'$TFOLD'@g' <$i> $OUTDIR/subject_template.m
done
</code>

The next step, if your matlab template running spm doesn't require a display to function, would be to navigate to the directory where you just saved the subject_template.m script, and submit it to run.

<code bash>
# Change to output directory and run matlab on input script
cd $OUTDIR

/usr/local/bin/matlab -nodisplay < subject_template.m
</code>

This command is launching matlab (/usr/local/bin/matlab is where it is installed on the cluster) with the "nodisplay" option, and giving it the script as input.  This will launch matlab, run the script, and then with the "exit" command in your matlab template, it will shoot back to the bash script.  It's good to put something after this line so you can be sure this is happening when you check the output file:

<code bash>
echo "Done running subject_template.m in matlabn"
</code>


##### Setting up a Graphical Environment
In the case that we have a matlab template that needs to send graphical output to a display, we can use xvfb (the x virtual frame buffer) to allocate a spot in memory to use, and send the actual output to some temporary folder.  To best do this we should generate a random integer, and then check if the spot is being used (represented by the existence of a "lock" file at this location), and in the case it is open, initialize xvfb at this spot, and then launch matlab to run the script with the display allocated to this spot, and after we finish, delete the lock file that we created.  The script below is an example of how to do that, and then launch matlab to run the script, this time with the -display= option instead of -nodisplay.

<code bash>
# ------------------------------------------------------------------------------
#  Step 2.1: Preparing Virtual Display
# ------------------------------------------------------------------------------

#First we choose an int at random from 100-500, which will be the location in
#memory to allocate the display
RANDINT=$[( $RANDOM % ($[500 - 100] + 1)) + 100 ]
echo "the random integer for Xvfb is ${RANDINT}";

#Now we need to see if this number is already being used for Xvfb on the node.  We can
#tell because when it is active, it will have a "lock file"

while [ -e "/tmp/.X11-unix/X${RANDINT}" ]; do
	echo "lock file was already created for $RANDINT";
	echo "Trying a new number...";
	RANDINT=$[( $RANDOM % ($[500 - 100] + 1)) + 100 ]
	echo "the random integer for Xvfb is ${RANDINT}";
done

#Initialize Xvfb, put buffer output in TEMP directory
# The & is very important so the script moves on to the next line!
Xvfb :$RANDINT -fbdir $TMPDIR &

/usr/local/bin/matlab -display :$RANDINT < subject_template.m;;

echo "Done running subject_template.m in matlab"

#If the lock was created, delete it
if [ -e "/tmp/.X11-unix/X${RANDINT}" ]; then
	echo "lock file was created";
	echo "cleaning up my lock file";
	rm /tmp/.X${RANDINT}-lock;
	rm /tmp/.X11-unix/X${RANDINT};
	echo "lock file was deleted";
fi
</code>


##### Additional Functionality
A "switch" statement can be used to run different commands depending on the value of a variable.  Here is an example that shows doing different things depending on if the variable $MYFAR is 1, 2, or 3.

<code bash>
case $MYVAR in
1)      echo 'MTVAR is 1.';;
2)      echo 'Faces task order is 2'
	  echo 'Yep it's still 2!;;
3)      $MYVAR=4;;
*)      echo '$MYVAR is not 1, 2, or 3.';;
esac
</code>

The * is what will happen if none of the cases match (the default) and the letters esac close the switch statement.

##### Converting .ps to .pdf
SPM produces .ps files that can be converted to .pdf with Adobe Distiller when you double click them on your local machine.  However this is slow and painful, so it's much better to have your script do it, and then move the file to wherever you want it.  The example below goes to the output directory of a first level analysis, finds the .ps file that SPM has named with the format of the date, puts the name into a variable called PSFILE, and then checks if the PSFILE exists, and if it does, uses he ps2pdf command to convert it to pdf.

<code bash>
# If we have done single subject analysis and checked reg, convert .ps file to PDF
cd $OUTDIR
NOW=$(date +"%Y%b%d")
PSFILE=spm_$NOW.ps
if [ -e "$PSFILE" ]; then
	ps2pdf $PSFILE
fi
</code>

Then we can copy this file to wherever we want to find it, and delete the old ones.  This example puts the subject ID into the name, since all of these files for many subjets are residing in the same place. 

<code bash>
cp $PSFILE.pdf $EXPERIMENT/Path/where/I/want/$SUBJ"_"$NOW".pdf"
	rm $PSFILE.pdf
	rm $PSFILE.ps
fi
</code>

##### Footer Section
The footer section example below basically closes the output script with some job information, and then moves the job output file to wherever the user has specified.  It then returns a code of 0 (meaning the job was successful) and exits.  In the case of the cluster at Duke, the output file is stored temporarily on the user's home node while the script is running, and then moved to the output directory specified in the footer upon completion.  If a script fails to finish, the output file can be found on the head node in the home folder for troubleshooting!

<code bash>
# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER --
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----"
OUTDIR=${OUTDIR:-$EXPERIMENT/Path/to/subject/output/$SUBJ}
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER--
</code>

If you didn't want to use a snazzy submission method, you could easily set up some sort of for loop in a bash script to submit different instances of your bash script.  For example:

<code bash>
# Set up job specific variables
TASKFOLDER='name'
RUNTHIS='yes'
ORDER=3

# For a list of subjects, submit a job to run on the cluster

for i in 123 234 345 324; do
	qsub -v EXPERIMENT=NAME.01 my_template.sh $i $TASKFOLDER $RUNTHIS $ORDER
fi
</code>

Instead of having SUB_SOMETHING_SUBs in the bash template, you would want the script to expect to be called with three input arguments, which are referenced in the bash script as $1,$2,and $3.  So you could do:

<code bash>
SUBJECT=$1
TASKFOLDER=$2
RUNTHIS=$3
ORDER=$4
</code>

Please note that for most clusters with many users, it is much better etiquette to use a smart submission method (like a python script) that takes into account the number of nodes available, busy-ness and size of the cluster, time of day, etc.  A for loop in a bash script will simply throw the jobs out there without taking anything or anyone else into account, which can upset other users.


##### PYTHON SCRIPT TEMPLATE
Lastly, we need to use a python script (ends with .py) to submit our bash template to run on the cluster.  This is the script that you will open up and define variables in the header each time you want to submit new subjects to go through your pipeline.  Since this script largely doesn't change, I will only talk about the sections that do need to be modified based on your experiment variables.  The first section that needs to be modified is the header, where all your variables are set.  For this script, it is easiest to copy the entire thing from the lab wiki, and then tweak the header and one middle section where the substitution takes place.  An example of the header section is below:

<code python>
#!/usr/bin/env python
import sys,os,time,re,datetime,smtplib

#------MY_BATCH.py---------------------------
#
# This script is used for preprocessing of anatomical and functional data
# in SPM.  It runs single subject analysis, checks registration, performs
# Artifact Detection (Art), and then a second analysis with Art Outliers.
# 

#########user section#########################
#user specific constants
username = "abc1"                               #your cluster login name (use what shows up in qstatall)
useremail = "myemail@site.com"                  #email to send job notices to
template_f = file("my_template.sh")             #job template location (on head node)
experiment = "NAME.01"                          #experiment name for qsub
nodes = 400                                     #number of nodes on cluster
maintain_n_jobs = 100                           #leave one in q to keep them moving through
min_jobs = 5                                    #minimum number of jobs to keep in q even when crowded
n_fake_jobs = 50                                #during business hours, pretend there are extra jobs to try and leave a few spots open
sleep_time = 20                                 #pause time (sec) between job count checks
max_run_time = 720                              #maximum time any job is allowed to run in minutes
max_run_hours=24	                        	#maximum number of hours submission script can run
warning_time=18                                 #send out a warning after this many hours informing you that the deamon is still running
                                                #make job files  these are the lists to be traversed
                                                #all iterated items must be in "[ ]" separated by commas.
#experiment variables 
subnums = ["123456_11111","123456_22222"] 	#should be entered in quotes, separated by commas, to be used as strings
runs = [1]               				#[ run01 ] range cuts the last number off any single runs should still be in [ ] or can be runs=range(1,2)
anatfolder = "anat"     				#folder under Data/Anat that includes the anatomical dicom images
tone = "series_name"             			#t1 folder (series005) if it doesn't exist, leave blank
taskfolder = "task_folder_name"    			#folder with the faces functional data (in V00*.img/.hdr format)
orderno = "1"                				#This is the group of subjects order number (must submit 1 python / order number)

# processing choices
taskrun = "yes"              #"yes" runs preprocessing and single subject analysis for faces, "no" skips
justfunc = "yes"             #"yes" skips anatomical processing.  To be used if you have manually set origin of anatomicals
                             # and then copied the anatomical into each functional folder
imageprep = "no"             # yes ONLY copies over images and imports dicoms to allow for manual AC PC realign and segmentation
####!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!###############################################
</code>

Note that the cluster at Duke requires your username as well as your useremail to send a job output email too.  If you have gmail it's helpful to create a filter that puts messages from root into a specific folder and skips the inbox, otherwise you will be bobarded with emails.  I commonly have a couple of thousand emails in my root folder before cleaning it out!

Note that you also need to specify the name of your bash template (my_template.sh) - which can be set without a longer path since it is located in the same folder.  The next variable is the experiment name, and the remaining 8 variables in the first section are cluster specific, and would only need to be changed if the cluster itself changes in structure/nodes etc.

The next section is the #experiment variables section, and this is where you would need to create a variable for each thing (number or string or list) that you want fed into your bash template.  Strings should be put in quotes, while a list should be set up in the format of the subnums varible, for example.  Later in the script, a loop will cycle through the subnums variable, create an instance of the template script for each subject, and then use the same qsub command to submit it.  This is the second section that will need to be tweaked based on your variables, and the start looks like this:

<code python>
#define substitutions, make them in template 
		runstr = "%05d" %(run)  
		tmp_job_file = template.replace( "SUB_USEREMAIL_SUB", useremail )
		tmp_job_file = tmp_job_file.replace( "SUB_SUBNUM_SUB", str(subnum) )
		tmp_job_file = tmp_job_file.replace( "SUB_ANATFOL_SUB", str(anatfolder) )
 		tmp_job_file = tmp_job_file.replace( "SUB_TASKFOLD_SUB", str(taskfolder) )
		tmp_job_file = tmp_job_file.replace( "SUB_RUNNUM_SUB", str(run) )
		tmp_job_file = tmp_job_file.replace( "SUB_TONEFOLD_SUB", str(tone) )
		tmp_job_file = tmp_job_file.replace( "SUB_TASKRUN_SUB", str(taskrun) )
		tmp_job_file = tmp_job_file.replace( "SUB_JUSTFUNC_SUB", str(justfunc) )
		tmp_job_file = tmp_job_file.replace( "SUB_PREONLY_SUB", str(imageprep) )
		tmp_job_file = tmp_job_file.replace( "SUB_ORDERNO_SUB", str(orderno) )
</code>

So the python is using the .sh script as a template, and finding all places where it says SUB_ANATFOL_SUB, for example, and filling it with a string of the anatfolder variable.  The subject ID is fed from the subnum variable, because we are actually inside of a loop that cycles through subnums, and puts each subject ID into a separate variable called subnum.  Note that in the case that you reference a variable that does not exist, you might run your python, and not see any job submissions.

In the line below, you will want to change the RUN_NAME to whatever you want the job to be called.  When you type "qstat" on your head node it will show the status and information for all of your running jobs, and "qstatall" will show everyone's jobs.

<code python>
tmp_job_fname = "_".join( ["RUN_NAME", subnum, runstr ] )
</code>

Lastly, to show how the new template gets submit, you can find the qsub line.  It's helpful to trace each variable from the python --> bash --> matlab template to make sure that everything is there and correct!

##### Submitting your scripts
When everything is finished, you need to make both your scripts executable on command line, which can be done with the following commandsL

<code python>
chmod u+x my_template.sh
chmod u+x batch_script.py
</code>

Then to submit the actual python, you would type:

<code bash>
python batch_script.py
</code>

and hold your breath! 

##### Troubleshooting
No matter how good of a coder you are (I'm not very good), or how meticulous (I tend to be more meticulous about things), there are likely to be errors.  Troubleshooting errors is a job within itself, and it can actually be quite fun, because you are essentially a detective trying to solve a problem.  The best that you can do is know the resources available to you, and over time build up a good knowledge base of error messages, and possible problems.  You definitely get better over time!  You will very likely not have a perfect functioning pipeline the first time you submit it!  The first place to go is either the .out file from the bash script (which is on your head node if the script didn't finish running, or in the output folder if it did), or if there were errors in the python, the deamon.log which is located in the same folder the script runs from.  The .out file will have both errors from the bash script, and any errors that came up while running your matlab script.  The creation of these output logs/files is of course are set up in both the bash and python scripts themselves, so if you are new to scripting you shouldn't expect them to magically appear anytime a bash or python script is run!

The best advice I can give for troubleshooting is that, the beauty of computers is that there is always a logical reason for things.  And 99% of the time the problem is a path error.  Good Luck!
