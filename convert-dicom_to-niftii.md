# Convert Dicom to NIFTII for FSL

The data comes off of the scanner in the format DICOM (.dcm), and FSL likes it to be in NIFTII (.nii).  You can do this manually, OR use these scripts to convert one or many subject(s) dicom files into niftis.  These scripts / instructions utilize the [BIAC XCEDE Tools](http://www-calit2.nbirn.net/tools/bxh_tools/index.shtm)!

## Manual Conversion
First, [Connect to Your Cluster](connect-to-your-cluster.md), or wherever your cluster/data is located (the unix environment).  At Duke this involved starting win-32 to handle the display, connecting to the VPN, and opening up the F-Secure Shell.  Full instructions for that entire process are available if you click the link above.  If you have everything installed, click "Quick Connect" and navigate to wherever your anatomical and functional data is located.

  * First, we need to change the orientation from LPS (output from the scanner) into LAS (radiological, required by FSL).  To do this, use the following command:

<code bash>
bxhreorient --orientation=LAS input.bxh Outpre.bxh
</code>

  * input.bxh is whatever bxh file is the header for the dicom images, and outpre.bxh is the name you want for your resulting, new bxh header.
  * Next we need to take this correctly oriented header, and make our nifti file for FSL.

<code bash>
bxh2analyze --nii -b input.bxh Outpre
</code>

  * The -nii specifies the output be in the nifti 4D format, and the -b suppresses the output of a new bxh file. --niftihdr makes a 3D nifti file.  For complete documentation, see the BXH XCEDE tools website, or just type the command into the terminal window with nothing else (aka, use it incorrectly) and it will spit out all the options.
  * the input.bxh should be the new bxh header that you just made with the command above.

You must then run the BET Brain Extraction on the anatomical that will be the "Main Structural Image" in the FEAT FMRI analysis (under the Registration tab), and the functional nifti will be specified under "4D data," also under FEAT FMRI, the Data tab.

To get an explanation of what everything means (or all options), just type "bxh2analyze" or "bxhabsorb" or "bxhreorient" followed by -help into the terminal, and it spits it out.

## Script Conversion

 - [Dicom2nifti Single Subject](dicom2nifti-single-subject.md)
 - [Dicom2nifti Multiple Subjects](dicom2nifti-multiple-subjects.md)
