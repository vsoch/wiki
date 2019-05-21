# Unsupervised Learning

**Clustering Algorithms**
In an unsupervised learning problem, we have a dataset with "no right answers" - and we are looking for interesting structures in the data (for example, clustering).  

* We might look at gene data and try to group people into clusters based on how genes respond to particular experiments. \\
* We might use an unsupervised learning algorithm to group pixels together from images that are similar.  A clustering algorithm is very useful in applications of computer vision.  We can apply a clustering algorithm and group a picture into similar regions.

[Clustering Algorithms](clustering-algorithms.md)

**Cocktail Party Problem**

An usupervised learning problem.  Imagine lots of people at a cocktail party, and it's hard to hear people around you.  The problem is, if here are many people talking, can we separate out the voice of the person we are talking with?  For example - there are two microphones in the room, recording the voices of two people.  Can we separate them?  Yes!  With independent component analysis.  MATLAB can do it in one line of code! \\

```
[W,s,v] = svd(repmat(sum,x,*x,1)size(x,1),1).*x)*x');
```
