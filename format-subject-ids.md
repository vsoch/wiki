# Format Subject IDS

This script was created to format a list of subject IDs to be used in a python script.  Currently, the user has to copy paste the IDs from excel into a text document, and then from the text document into nedit, and then spend an inordinate amount of time formatting each ID to be surrounded by parenthesis, and separated by commas.  I used to do this manually, every time, until I realized that I could probably accomplish the same thing in five seconds with a script... ah!

## How Does it Work?
This script takes in a text file, either specified at command line (if you run Format_ID('mytextfile.txt')) or input via a GUI (if you run Format_ID with no arguments).  The text file should be a list of subject IDs, one per line, to be used in the python script.  These IDs will be formatted to be surrounded by quotes, and separated by commas.  For example, if the text file has the following IDs:

<code batch>
12345_11111
12345_22222
12345_33333
```

the output will be:

```python
subnums = ["12345_11111","12345_22222","12345_33333"]
```

You can view the script [here](scripts/format_ID.m)
