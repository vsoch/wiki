# Fslswapdim

```bash
# Change Orientation 

fslswapdim <input> x y z (output) 
fslswapdim <input> RL AP SI orient_new

Usage: fslswapdim <input> <a> <b> <c> [output]
 
  where a,b,c represent the new x,y,z axes in terms of the
  old axes.  They can take values of -x,x,y,-y,z,-z
  e.g.  fslswapdim invol y x -z outvol
```
