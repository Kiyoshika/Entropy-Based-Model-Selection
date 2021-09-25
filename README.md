# Entropy-Based Model Selection
Researching entropy-based model selection, this is an example of how to use information theory to select regression models.

# How to perform model selection using entropy
* First, L(y | M) is computed, which is the likelihood of y given a model M
* We iterate over our y_i data and evaluate L(y_i | M) and store it in a vector
* Then we compute entropy, which is the expected value of negative log likelihood: -mean(log(L(y | M)))

The lower this entropy value is, the better "fit" the model is for predictability. This is because entropy itself is
a quantification of how much "randomness" exists within a probabilistic system. The lower entropy a model has, the
"more predictable" it is (i.e, higher quality predictions)

My entropy-based values are compared against AIC and they appear to be equivalent. This is no surprise since AIC
is derived from relative entropy.

At the end of the script, we use 1,000 generated test data points to evaluate the errors for each model. The errors
line up pretty well with our entropy values.
