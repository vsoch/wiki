## Instructions for Fixing DNS Cards Data

  - Open the DNS excel, look at the Batches tab, and select the next subject from the list on the right.
  - Obtain subject onsets and durations for Cards from "Cards Timing Calculations Excel Vanessa"
  - Find the exam number associated with the DNS number in the DNS excel.  You will also log that processing is complete for each subject here.
  - Navigate to this subject's Analysis folder under Analysis/SPM/Analyzed.  Make sure that the "cards" folder is completely empty, and under "cards_pfl" delete everthing EXCEPT the files that were created when art was run. (Under Processed we don't touch anything since the SWU images are still good to use - nothing to do with timing/design.)  The ART calculation is also OK to keep since we will be keeping all 171 of the images.  The design was not relevant to successfully running art.
  - Open up MATLAB and navigate to the subject's Analyzed directory / cards
  - Start SPM, and click on "Specify First Level"
  - A sample design is set up for you to load and start from to do the level 1 analysis. Open up Scripts/SPM/Saved Batches/cards_redo.mat to start.
  - Under "Directory" --> Change it to the subject's Cards folder 
  - Under "Data & Design" --> Scans, Navigate to the subjects Processed/cards folder and select the 171 swu* images.
  - Under each condition (Reward, Loss, Control) you need to add the correct onsets AND durations for each one from the Cards Timing Excel sheet.  If there are TRs eliminated from the analysis due to the timing being way off, add a "Dummy" condition to the end, and specify the onset as the subjects ending TR, and the length 171 minus that number.  All of these values are in the Cards Timing excel, which should  calculate the durations once you input the correct onsets from the subject's tab.  If there are no extra timepoints, make sure to delete the dummy condition.
  - Then select the SPM art regression file under "Multiple Regression" - it is located in the cards folder under Processed.  This matrix must have the same dimensions as the design, which is we we add the "Dummy" condition to ensure that we always have 171 timepoints.
  - Once you have checked that everything is correct, click the Green arrow to run the analysis.  Make sure that it runs through, check the output folder for all the files, and then write "YES" next to the subject number in the DNS excel to indicate that you have finished.  Move on to the next subject!