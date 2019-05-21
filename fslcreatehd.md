# FSL Create HD

```bash
# Usage:

fslcreatehd <xsize> <ysize> <zsize> <tsize> <xvoxsize> <yvoxsize> <zvoxsize> <tr> <xorigin> <yorigin> <zorigin> <datatype> <headername>

fslcreatehd <nifti_xml_file> <headername>
# In the second form, an XML-ish form of nifti header is read (as output by fslhd -x)
# Note that stdin is used if '-' is used in place of a filename
```
