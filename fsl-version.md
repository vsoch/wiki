# FSL Version

This is the code that goes in the user section of the script to specify the FSL version:

```bash
# Specify FSL 4.1                 

FSLDIR=/usr/local/fsl-4.1.0-centos4_64
export FSLDIR
source $FSLDIR/etc/fslconf/fsl.sh 
```

You can also make changes to your profile.  Do nedit ~/.bash_profile to find the following:

```bash
.bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin
export PATH
```

Then we need to make sure to specify the path when we call the function like

```bash
"$FSLDIR/bin/feat" rather than just "feat".
```
