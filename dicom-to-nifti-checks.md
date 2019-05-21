# DICOM to NIFTI Checking

Unlike a lot of the checking (for QA or BET, for example) the dicom --> nifti conversions can be checked as you do them.  With this along-the-way checking and careful documentation, you shouldn't have to go back and do anything!
  * It's helpful to check the name of the output nifti when the GUI spits it out to make sure you have identified the data correctly
  * Also check that the number of images is consistent with what you've seen. Sometimes a scan that should have 195 images may have fewer, in which case something is wrong.
  * If a subject is missing a folder or a folder won't process, flag the subject by highlighting them with red, and this data will be given another look over at the end of processing.
