# generate synthetic data
x1 = c()
x2 = c()
x3 = c()
x4 = c()
y = c()
for (i in 1:1000)
{
  x1[i] = rnorm(1, mean = 2, sd = 1)
  x2[i] = rnorm(1, mean = 5, sd = 3.5)
  x3[i] = rnorm(1, mean = -1, sd = 2)
  x4[i] = rnorm(1, mean = 3, sd = 2)
  y[i] = 3*x1[i] + 1*x2[i] + 0*x3[i] + 0*x4[i] + 10 + rnorm(1, mean = 0, sd = 4)
}

# naive mean model (baseline)
mu_y = mean(y)

# scale the data for the penalizer term
x1_scaled = (x1 - mean(x1))/sd(x1)
x2_scaled = (x2 - mean(x2))/sd(x2)
x3_scaled = (x3 - mean(x3))/sd(x3)
x4_scaled = (x4 - mean(x4))/sd(x4)

# fit models and evaluate entropy

# NOTE: the scaled models are only used for evaluating penalty term; not predictions.

# NOTE 2: the "penalizer" takes the reciprocal of mean of the absolute value of the (scaled) coefficient estimates (excluding the intercept).
# This is because the larger the coefficients, the closer this metric will be to zero and vice versa, if the coefficients are
# close to zero then this metric grows large (and is infinity if any of the coefficients are exactly zero, which could be one
# potential complication).

# If you have a large model with a mot of redundant coefficients (near-zero), then this will drag the metric towards zero
# and thus increase penalty. If you have a large model with a lot of informative coefficients (away from zero) then this will
# drag the metric away from zero and thus decrease the penalty.
full_mod = lm(y ~ x1 + x2 + x3 + x4)
full_mod_scaled = lm(y ~ x1_scaled + x2_scaled + x3_scaled + x4_scaled)
full_mod_penalizer = (1 / mean(abs(full_mod_scaled$coefficients[-1]))) # ignore intercept
full_mod_entropy = full_mod_penalizer + -1*mean(log2(dnorm(y, mean = predict.lm(full_mod), sd = sd(residuals(full_mod)))))

x12_mod = lm(y ~ x1 + x2)
x12_mod_scaled = lm(y ~ x1_scaled + x2_scaled)
x12_mod_penalizer = (1 / mean(abs(x12_mod_scaled$coefficients[-1]))) # ignore intercept
x12_mod_entropy = x12_mod_penalizer + -1*mean(log2(dnorm(y, mean = predict.lm(x12_mod), sd = sd(residuals(x12_mod)))))

x123_mod = lm(y ~ x1 + x2 + x3)
x123_mod_scaled = lm(y ~ x1_scaled + x2_scaled + x3_scaled)
x123_mod_penalizer = (1 / mean(abs(x123_mod_scaled$coefficients[-1]))) # ignore intercept
x123_mod_entropy = x123_mod_penalizer + -1*mean(log2(dnorm(y, mean = predict.lm(x123_mod), sd = sd(residuals(x123_mod)))))

x13_mod = lm(y ~ x1 + x3)
x13_mod_scaled = lm(y ~ x1_scaled + x3_scaled)
x13_mod_penalizer = (1 / mean(abs(x13_mod_scaled$coefficients[-1]))) # ignore intercept
x13_mod_entropy = x13_mod_penalizer + -1*mean(log2(dnorm(y, mean = predict.lm(x13_mod), sd = sd(residuals(x13_mod)))))

x34_mod = lm(y ~ x3 + x4)
x34_mod_scaled = lm(y ~ x3_scaled + x4_scaled)
x34_mod_penalizer = (1 / mean(abs(x34_mod_scaled$coefficients[-1]))) # ignore intercept
x34_mod_entropy = x34_mod_penalizer + -1*mean(log2(dnorm(y, mean = predict.lm(x34_mod), sd = sd(residuals(x34_mod)))))

full_mod_entropy
x12_mod_entropy
x123_mod_entropy
x13_mod_entropy
x34_mod_entropy

# as a sanity check, we can compare against AIC
AIC(full_mod)
AIC(x12_mod)
AIC(x123_mod)
AIC(x13_mod)
AIC(x34_mod)

# generate "unseen" data
x1 = c()
x2 = c()
x3 = c()
x4 = c()
y = c()
for (i in 1:1000)
{
  x1[i] = rnorm(1, mean = 2, sd = 1)
  x2[i] = rnorm(1, mean = 5, sd = 3.5)
  x3[i] = rnorm(1, mean = -1, sd = 2)
  x4[i] = rnorm(1, mean = 3, sd = 2)
  y[i] = 3*x1[i] + 1*x2[i] + 0*x3[i] + 0*x4[i] + 10 + rnorm(1, mean = 0, sd = 4)
}

# evaluate root mean squared error
test_data = as.data.frame(cbind(x1, x2, x3, x4))

sqrt(mean((y - predict.lm(full_mod, newdata = test_data))^2))
sqrt(mean((y - predict.lm(x12_mod, newdata = test_data))^2))
sqrt(mean((y - predict.lm(x123_mod, newdata = test_data))^2))
sqrt(mean((y - predict.lm(x13_mod, newdata = test_data))^2))
sqrt(mean((y - predict.lm(x34_mod, newdata = test_data))^2))
sqrt(mean((y - mu_y)^2))
