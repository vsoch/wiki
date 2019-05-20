# Matlab

It's quite hard to not love MATLAB, the "Matrix Laboratory."  It can pretty much do anything that you can dream up.  Most of the scripts/tools that I have documented on here have something to do with MATLAB!  I am the proud owner of a MATLAB Community hat, am not embarrassed to admit that I attend the online learning seminars for fun, and never think twice about embarking on any new project that involves MATLAB!  For help writing scripts or finding functionality, it's best to look at the MATLAB Function Reference:  http://www.mathworks.com/help/techdoc/ref/f16-6011.html 

## Data Manipulation and Tools

### Imaging

 - [View Images](view-images.md) 
 - [Coverage Checking](coverage-checking.md) (a MATLAB based tool for checking voxel coverage for neuro data) 
 - [conn](conn.md) A toolbox for resting connectivity analysis based in MATLAB 

### Genetics

 - [Plink_View](plink-view.md) Create formatted output from Plink list file, and optional look up tables 

### Miscellaneous

 - [Print Structural Variable as M Script](print-structural-variable-as-m-script.md) 
 - [Write SQL Insert Statements from Excel File](write-sql-insert-statements-from-excel-file.md) 
 - [Reminder Email And Text Messages](reminder-email-and-text-messages.md) 
 - [Send Brain Images](send-brain-images.md) automatically create and send a 3 plane orthogonal view and slice view of an anatomical 
 - [Format Subject IDs](format-subject-ids.md) Useful for spitting out a formatted list of subject IDs for input in a python script from a single column text file of the IDs 
 - [Format MATLAB ID](format-matlab-id.md) Useful for spitting out a formatted list of subject IDs for use in MATLAB.
 - [Battery Data Add](battery-data-add.md) An example of using a script to read a bunch of little text files and format into one master excel file 

## Resources

 - [Matlab Overview](http://fourier.biac.duke.edu/wiki/doku.php/biac:matlab:help) 
 - [Function Reference](http://www.nacs.uci.edu/dcslib/matlab/matlab-v53/help/techdoc/ref/sprintf.html) 

## MATLAB TOOLS (for your Desktop)

  - Download the tools  - [here](http://fourier.biac.duke.edu/wiki/doku.php/biac:tools)
  - Save the tools to MyDocuments/MATLAB/BIAC
  - Create a desktop shortcut for MATLAB and under "start in" put this address "C:Documents and SettingsVanessa SochatMy DocumentsMATLABBIAC"
  - TO IMPORT TOOLS for use in SSH (running matlab via SSH):  run /usr/local/packages/MATLAB/BIAC/startup.m

**The Tools and Various Commands**
 
  * readmr: gives you basic information about file size, etc for an image
  * readtsv: does the same for a time series of volumes
  * [showsrs2](http://fourier.biac.duke.edu/wiki/doku.php/biac:matlab:showsrs2): allows you to open and view image files
  * which: the which command shows which directory a program is stored under
  * pwd: prints the working directory
  * whos: list the current variables loaded
  * clear variable_name: clears the variable specified, or type "clear" to clear all variables
  * help readmr:  By typing "help" before a command, MATLAB will spit out relevant info about the command

**TOOLS for Nifti and Analyze** 

  * There is a set of tools you can download  - [here](http://www.rotman-baycrest.on.ca/~jimmy/NIfTI/) for use with nifti files in matlab.  I would extract the files to the MATLAB folder that you created in "My Documents," perhaps under a new folder called nifti, if you choose.
  *  - [Tools for ROI for FSL](http://wiki.poldracklab.org/index.php/FSL-ROI)


```matlab
addpath('/usr/local/packages/MATLAB/fslroi');
addpath('/usr/local/packages/MATLAB/NIFTI');
```

## Error Troubleshooting

 - [MATLAB Out of Memory](matlab-out-of-memory.md)
