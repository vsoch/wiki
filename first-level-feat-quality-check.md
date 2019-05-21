# First Level Feat Quality Check

Running FEAT Analysis, like the Brain Extractions, is done with a script, and errors are bound to happen.  Since the Group FEAT requires all of the single subject analysis to be run, and run correctly, it's good to check for the completeness and quality of each FEAT analysis.

1) **First, check subject's.**  The FEAT script creates a new subject folder under "Analysis" for each run.  Check these folder names against your master list in the EXPERIMENT.xls file (or your log file equivalent), and/or against the list in your script running log.  If you forgot anyone, run those subjects before continuing. I like to check the runs against the master list of subjects, and then I am able to open a bunch at a time and focus on looking for error as opposed to double checking subject IDs. 

2) **Then, open the reports.**  The easiest way to check the report.html files is by opening them up via a Windows search.  Go to Start --> Search, select "All Files and Folders" and seach for "report_reg" within your Analysis/First_level directory.  It will bring up paths to all of the subject's registration outputs.  Again, are there the correct number based on the number of subjects that should have been run?

3) **Check those registrations!**  Open one at a time in a browser window.  For the registrations... 
  * Are all of the images there?  Seeing the functional and anatomical scans is indication that they were found correctly!
  * Are they oriented correctly?
  * Sometimes using the T2 as an intermediate registration can completely mess up the registration orientation.  If you see a registration that is whack and have troubleshooted everything logical, try running the FEAT without using any intermediate image.

4) **Check the Log.** Then go to the top and click on "Log"  This is the harder part of the check, you have to look through the output for errors.  Here are some examples of what you might see:
  * File path errors:  if a header image isn't found, it's probably a path error
  * EV file errors: A lot of times, EV files get incorrectly opened and messed up, or saved with extra characters.  If there is an error reading an EV, create the EV again, and also check to make sure the path to the EV is correct
  * Empty mask images: are OK.  This means that there simply wasn't any significant activation found for that particular EV.

5) **Was there a script error?** If your script had errors, the email from "root" is going to have an exit status that isn't "0" (32 and 2 means errors!)  If you find that FEAT didn't run correctly because of script errors, navigate to the directory from where the FEAT was run, and look at the .out file.  This, combined with looking at the FEAT Log, should give you insight to why the FEAT didn't run.

6) **Check the design** Many times, some 0s and 1s were entered incorrectly or saved incorrectly in the EV files.  If you have one master design for all subjects, you can just look at the "Stats" tab within report.html and make sure the contrasts are correct.  If you have an individualized design (many EVs) for each subject, then an easy way of checking all of the designs at once is to do a search in the subject analysis folder for "design.png" - which is the graphic in the report.html that shows the design and contrasts.  You can look at these in a filmstrip view on your computer and look for errors in design.

7) **Check the motion parameters** The first level FEAT calculates the absolute translational and rotational motion under the Stats.  You will want to record the absolute value in your QA log for each subject, and omit any subjects with greater than 2mm of translational or rotational motion.

8) **Check the zstats** Give the Z-stat timeseries plots a quick glance over for any sudden drops to zero.  Also look for reports of missing bytes in the log, which would calculate a section of the z-stat as "nan" - not a number.  If you miss this error, your group feat report will have the error "dof cannot be less than zero!" and you will have to go back and find the offending subject.  See [[FSL Common Errors]] for how to do this.
