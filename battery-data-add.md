## Import Behavioral Battery Data to Raw Data File

This can be applied to any sort of problem where you have many tiny text files that need to be read and added to some master file. This particular example was used for a task in our study that spit out a bunch of single line text files, one per subject, with values that needed to be scored in a master excel sheet.  I used to use a free application to manually select the files, go through a bunch of painful GUIs, and finally produce a concatenated text file to open in excel and THEN format how I liked it.  I decided that wasn't easy enough, and wrote this script!  This particular script will spit the results for each subject into a master file that is used as a master log for the raw data, and a record of when/if the data has been scored.  Instructions for this particular script are as follows:
  - Open MATLAB, and make sure that you have the Scripts path added.  Type addpath('N:/Name.01/Path/to/Scripts/') 
  - Type battdata_add 
  - Enter the IDs at the prompt, with a space between each one 
  - The script will tell you if the subjects are added successfully 
  - The script expects the raw data to be on a particular drive in a folder with the subject ID, and for the file extension of the data to be a particular type.
  - See [[http://www.vsoch.com/LONG/Vanessa/MATLAB/Battery/battdata_add.m|Behavioral Data Add]] for the script!
