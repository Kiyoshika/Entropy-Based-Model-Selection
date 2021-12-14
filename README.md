# Entropy-Based Model Selection
Researching entropy-based model selection, this is an example of how to use information theory to select regression models.

# How This Method Works
Keep in mind that this is my experimental approach to deriving an entropy-based metric for model selection and is only somewhat tested.

This derivation begins with the notion of entropy, which is the (negative) expected value of the log likelihood of a model. In the code example, I'm using a linear model with normally distributed residuals (although they don't have to be.)

All independent variables are standard scaled for the purpose of creating a "penalty" metric. This is to keep a level playing field for all coefficients and not be influenced by vastly different scales. After all independent variables are scaled, a typical regression model is fit.

After this model is fit, we then define a **penalty score** which is equal to the reciprocal of the mean of the absolute values of the coefficients. The intuition behind this is, the closer your coefficients are to zero, the larger the reciprocal (i.e penalty is) and vice versa, the larger your coefficients are, the smaller the reciprocal and thus the smaller the penalty.

Then the standard deviation is computed from the residuals. We now take every pair {y_i, (x_1i, x_2i, ..., x_ki)} and take the expected value (mean) of the log likelihood of the model. In this case, the residuals are normally distributed so the likelihood is then

`L(y_i | (x_1i, x_2i, ..., x_ki)) = N(b0 + b1*x_1i + b2*x_2i + ... + bk*x_ki, sd_resid)` 

where sd_resid stands for the standard deviation of the residuals computed earlier.

Then the entropy is the negative of the mean over all values of the log likelihood computed for each y_i.

The final metric is just the sum of this penalty term with the entropy: `penalty + -E[log(L_Y | X)]`
