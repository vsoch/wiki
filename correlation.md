# Correlation

## Pearson Correlation

This is that r value that is always reported on charts, or the correlation coefficient.  If we want to ask the question "how well does my model fit my data? r would give us that answer.  R is a measure of the degree of linear relationship between two variables.  The reason that we need an r value for a correlation is because in a correlation, there is no direction, as there is in a regression.  In a regression, you have one variable that predicts another one.  In a correlation, you know there might be a relationship between two variables, but you don't know if a --> b, or b --> a, or something else!  So r is a measure of how well a model describes the relationship between two variables, whatever the direction of that relationship may be.  So r is always a value between -1 and +1.
  * A positive r means that as one variable increases, the other increases.  As one variable decreases, the other decreases.
  * A negative r means that as one variable increases, the other decreases, and vice versa, called an inverse relationship.

If we want just a measure of the strength of the relationship, we can take the absolute value of r.  When we convert our data to z scores and plot it, r is also the slope of the regression line.  As a reminder, converting raw X and Y values to Z scores means subtracting each value from the mean, and then dividing by the standard deviation: 
{{http://www.psychstat.missouristate.edu/introbook/sbgraph/corr21.gif}}

And even though it's much nicer to use software or a calculator for this, as a reminder, we can measure the variance by:
  - calculating the mean of an entire dataset
  - Finding how far each data point is from this mean, so subtracting each point from the mean
  - squaring each of these subtracted values to get an "absolute value" (getting rid of + or - direction)
  - summing these squared differences
  - dividing by N-1

![http://www.psychstat.missouristate.edu/introbook/sbgraph/stat4.gif](http://www.psychstat.missouristate.edu/introbook/sbgraph/stat4.gif)

Then if we take the square root of this variance (s2) to get s, this s is the standard deviation for the dataset. 

## Squared Correlation Coefficient
Of course, no one ever talks about r, it is always r squared!  This is the squared correlation coefficient, which represents the proportion of the variance of Y that can be explained by X.  So this value is a percentage, between 0 and 1.  A higher r squared value means that more of the variance of Y can be explained by X, so the correlation / relationship between the two is stronger.  An r squared of 1 would mean that 100% of the variance of Y is explained by X, and a r squared of 0 would mean that none of it is.
