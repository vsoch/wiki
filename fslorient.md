```bash
fslorient -getorient (name)

Usage: fslorient <main option> <filename>
 
  where the main option is one of:
    -getorient             (prints FSL left-right orientation)
    -getsform              (prints the 16 elements of the sform matrix)
    -getqform              (prints the 16 elements of the qform matrix)
    -setsform <m11 m12 ... m44>  (sets the 16 elements of the sform matrix)
    -setqform <m11 m12 ... m44>  (sets the 16 elements of the qform matrix)
    -getsformcode          (prints the sform integer code)
    -getqformcode          (prints the qform integer code)
    -setsformcode <code>   (sets sform integer code)
    -setqformcode <code>   (sets qform integer code)
    -copysform2qform       (sets the qform equal to the sform - code and matrix)
    -copyqform2sform       (sets the sform equal to the qform - code and matrix)
    -deleteorient          (removes orient info from header)
    -forceradiological     (makes FSL radiological header)
    -forceneurological     (makes FSL neurological header - not Analyze)
    -swaporient            (swaps FSL radiological and FSL neurological)
 
 Note: ANALYZE files are NOT modified by any of the commands
         - they are for NIFTI files ONLY!
       For NIFTI: the stored data order is never changed here - only the header info.
       To change the data storage use fslswapdim.
 
  e.g.  fslorient -forceradiological myimage
        fslorient -copysform2qform myimage
        fslorient -setsform -2 0 0 90 0 2 0 -126 0 0 2 -72 0 0 0 1 myimage
```
