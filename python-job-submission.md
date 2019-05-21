# Python Job Submission

Here is a little bit about the basic python script that we use to submit multiple jobs (thanks to McKell in Huettel lab!)

The python script takes in all the variables, and uses the bash script (.sh) as a template.  It basically fills in variables that you specify at the beginning of the python script, and submits the jobs in the most appropriate fashion depending on cluster use, space, etc.

To submit a python script, at the prompt type: 

```bash
python scriptname.py.
```

When using a python script with a template, you should basically change the first section to include the correct names of your data / files, create any new variables that you might want to include, and then go through your template script and write SUB_VARIABLENAME_SUB wherever you want the variable from your python script to appear.  For example, if I have a few subjects , 0455 and 0456, and I input them in the first section:

```python
subnums = ["0455", "0456"]
```

This means that the variable "subnums" will cycle through these names, putting each one into the subnum variable, and creating and running a script for each one.  I need to make sure the subject number gets passed from the python script to the template.  Here is where that happens:

```python
#define substitutions, make them in template 
runstr = "%05d" %(run)  
tmp_job_file = template.replace( "SUB_USEREMAIL_SUB", useremail )
tmp_job_file = tmp_job_file.replace( "SUB_SUBNUM_SUB", str(subnum) )
tmp_job_file = tmp_job_file.replace( "SUB_OUTPUT_SUB", str(output) )
```

We see that "subnum" gets filled with whatever appears as SUB_SUBNUM_SUB in the template file - so somewhere in my bash script I would want something like:

```bash
SUBJECT=SUB_SUBNUM_SUB
```

instead of

```bash
SUBJECT=$1
```

which would take the first argument on the command line.

I like to transfer the variables with a one shot deal like with the above fashion, but you could also go through your bash script and write SUB_SUBNUM_SUB wherever you want the substitution to take place, sans variable.
