# Entropy-Based Model Selection
Researching entropy-based model selection, this is an example of how to use information theory to select regression models.

# Example Output
This is an example output from the code (note it may vary slightly due to randomness):

NOTE: the custom_metric and AIC were computed on initial "train" data and RMSE was computed on re-generated unseen data (i.e "test" data)
```
custom_metric      AIC     RMSE
1     1.7108248 5633.448 4.033701
2     0.1403739 5635.140 4.023682
3     4.0908554 6522.419 6.480122
4     1.1477487 5633.358 4.030056
5     1.2284070 5635.240 4.027000
6     2.3743707 6314.575 5.706451
7     1.8209936 6068.103 5.023744
```
Some observations:
* For the most part, the custom_metric is pretty inline with AIC
* In some cases, the custom_metric is more informative than AIC. Row 2 contains only the informative variables and Row 1 contains two informative and two noisy variables. The custom_metric shows that Row 2 has much less penalty & entropy than Row 1 and we were able to maintain the RMSE while dropping the two noisy features.

# How This Method Works
Keep in mind that this is my experimental approach to deriving an entropy-based metric for model selection and is only somewhat tested.

This derivation begins with the notion of entropy, which is the (negative) expected value of the log likelihood of a model. In the code example, I'm using a linear model with normally distributed residuals (although they don't have to be.) I am also using a base 2 logarithm to keep my units in "bits", although I don't think it will be a significant impact if a different base is used (needs to be tested).

All independent variables are standard scaled for the purpose of creating a "penalty" metric. This is to keep a level playing field for all coefficients and not be influenced by vastly different scales. After all independent variables are scaled, a typical regression model is fit.

After this model is fit, we then define a **penalty score** which is equal to the mean of `exp(-|b_k|)` where `b_k` is the coefficient for feature k (THIS DOES NOT INCLUDE THE INTERCEPT TERM as it is a "garbage collector"). The intuition behind this is, as your coefficients close to zero, the penalty for that feature will be (close to) 1, and the farther your coefficients are from zero then penalty will be (close to) zero. The mean is taken to capture information about the "average penalty" for the model and is used to scale the entropy.

Then the standard deviation is computed from the residuals. We now take every pair {y_i, (x_1i, x_2i, ..., x_ki)} and take the expected value (mean) of the log likelihood of the model. In this case, the residuals are normally distributed so the likelihood is then

`L(y_i | (x_1i, x_2i, ..., x_ki)) = N(b0 + b1*x_1i + b2*x_2i + ... + bk*x_ki, sd_resid)` 

where sd_resid stands for the standard deviation of the residuals computed earlier.

Then the entropy is the negative of the mean over all values of the log likelihood computed for each y_i.

The final metric is the product of the penalty and entropy, i.e the entropy is scaled by the penalty: `penalty * -E[log2(L(Y | X))]`
