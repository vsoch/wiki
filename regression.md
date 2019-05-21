# Regression

## The Least Squares Criteria for Goodness of Fit
  * The goal of the regression procedure is to come up with a model that gets the predicted Y values as close to the actual as possible! 
    * How do we measure how well the models predictions fit the actual data values?  With least squares criteria for goodness of fit!
    * **Residuals:** difference (distance) between each actual and each predicted score.  We can sum the residuals to get a sum of scores
    * we could easily take the absolute value of each difference (so they don't cancel each other out) but instead we just square each difference, and then sum those squares, to get a value that represents how well the predictions fit the actual data.  Minimizing this sum of squared scores = closer actual and predicted values = a better model
    * ![http://www.psychstat.missouristate.edu/introbook/sbgraph/regres~2.gif](http://www.psychstat.missouristate.edu/introbook/sbgraph/regres~2.gif)
    * The model that minimizes this sum is said to meet the least-squares criterion!

## Regression Models

  * The goal of regression is to select parameters (a and b in a linear equation, for example) that minimize the sum of squares (detailed above) - meaning that the equation minimizes the distance between predicted and actual values, meaning that it is an equation that does a good job of representing / predicting the real life situation!  Since this is a minimization problem, we can actually simplify the sum of squares equation:

![http://www.psychstat.missouristate.edu/introbook/sbgraph/regres~5.gif](http://www.psychstat.missouristate.edu/introbook/sbgraph/regres~5.gif)

  * ...take the first order partial derivative of this equation...

![http://www.psychstat.missouristate.edu/introbook/sbgraph/regres~6.gif](http://www.psychstat.missouristate.edu/introbook/sbgraph/regres~6.gif)

  * ...figure out those lovely numbers...

![http://www.psychstat.missouristate.edu/introbook/sbgraph/regres~8.gif](http://www.psychstat.missouristate.edu/introbook/sbgraph/regres~8.gif)

  * ...fill them into the equation to solve for b

![http://www.psychstat.missouristate.edu/introbook/sbgraph/regres~9.gif](http://www.psychstat.missouristate.edu/introbook/sbgraph/regres~9.gif)

  * ...and finally put b with the mean for Y and X into the linear equation to solve a.

![http://www.psychstat.missouristate.edu/introbook/sbgraph/regre~10.gif](http://www.psychstat.missouristate.edu/introbook/sbgraph/regre~10.gif)

  * These would be the optimal values, a and b, that will make the equation best fit the actual data.

Lastly, the **standard error of estimate** gives you a value that represents how well the regression model fits the data.  Lower value = better fit!

![http://www.psychstat.missouristate.edu/introbook/sbgraph/regre~14.gif](http://www.psychstat.missouristate.edu/introbook/sbgraph/regre~14.gif)
