# generate synthetic data
x1 = c()
x2 = c()
x3 = c()
x4 = c()
y = c()
for (i in 1:1000)
{
  x1[i] = rnorm(1, mean = 2, sd = 1)
  x2[i] = rnorm(1, mean = -1, sd = 2)
  x3[i] = rnorm(1, mean = 3.5, sd = 2.2)
  x4[i] = rnorm(1, mean = 1, sd = 4)
  y[i] = 3*x1[i] + 2*x2[i] + 0*x3[i] + 0*x4[i] + 10 + rnorm(1, mean = 0, sd = 4)
}
plot(x1,y)
plot(x2,y)
plot(x3,y)
plot(x4,y)

# scale features
x1_scaled = (x1 - mean(x1))/sd(x1)
x2_scaled = (x2 - mean(x2))/sd(x2)
x3_scaled = (x3 - mean(x3))/sd(x3)
x4_scaled = (x4 - mean(x4))/sd(x4)

# build candidate models
full_model                    = lm(y ~ x1 + x2 + x3 + x4)
full_model_scaled             = lm(y ~ x1_scaled + x2_scaled + x3_scaled + x4_scaled)

good_model                    = lm(y ~ x1 + x2)
good_model_scaled             = lm(y ~ x1_scaled + x2_scaled)

bad_model                     = lm(y ~ x3 + x4)
bad_model_scaled              = lm(y ~ x3_scaled + x4_scaled)

noisy_model_1                 = lm(y ~ x1 + x2 + x3)
noisy_model_scaled_1          = lm(y ~ x1_scaled + x2_scaled + x3_scaled)

noisy_model_2                 = lm(y ~ x1 + x2 + x4)
noisy_model_scaled_2          = lm(y ~ x1_scaled + x2_scaled + x4_scaled)

partial_good_model_1          = lm(y ~ x1 + x3)
partial_good_model_scaled_1   = lm(y ~ x1_scaled + x3_scaled)

partial_good_model_2          = lm(y ~ x2 + x3)
partial_good_model_scaled_2   = lm(y ~ x2_scaled + x3_scaled)

# compute penalty terms
full_model_penalty            = mean(exp(-abs(full_model_scaled$coefficients[-1])))

good_model_penalty            = mean(exp(-abs(good_model_scaled$coefficients[-1])))

bad_model_penalty             = mean(exp(-abs(bad_model_scaled$coefficients[-1])))

noisy_model_1_penalty         = mean(exp(-abs(noisy_model_scaled_1$coefficients[-1])))

noisy_model_2_penalty         = mean(exp(-abs(noisy_model_scaled_2$coefficients[-1])))

partial_good_model_1_penalty  = mean(exp(-abs(partial_good_model_scaled_1$coefficients[-1])))

partial_good_model_2_penalty  = mean(exp(-abs(partial_good_model_scaled_2$coefficients[-1])))

# compute entropy
full_model_entropy            = -mean(log2(dnorm(y, mean = predict.lm(full_model_scaled), sd = sd(residuals(full_model_scaled)))))

good_model_entropy            = -mean(log2(dnorm(y, mean = predict.lm(good_model_scaled), sd = sd(residuals(good_model_scaled)))))

bad_model_entropy             = -mean(log2(dnorm(y, mean = predict.lm(bad_model_scaled), sd = sd(residuals(bad_model_scaled)))))

noisy_model_1_entropy         = -mean(log2(dnorm(y, mean = predict.lm(noisy_model_scaled_1), sd = sd(residuals(noisy_model_scaled_1)))))

noisy_model_2_entropy         = -mean(log2(dnorm(y, mean = predict.lm(noisy_model_scaled_2), sd = sd(residuals(noisy_model_scaled_2)))))

partial_good_model_1_entropy  = -mean(log2(dnorm(y, mean = predict.lm(partial_good_model_scaled_1), sd = sd(residuals(partial_good_model_scaled_1)))))

partial_good_model_2_entropy  = -mean(log2(dnorm(y, mean = predict.lm(partial_good_model_scaled_2), sd = sd(residuals(partial_good_model_scaled_2)))))

# model selection metric
full_model_info           = full_model_penalty * full_model_entropy

good_model_info           = good_model_penalty * good_model_entropy

bad_model_info            = bad_model_penalty * bad_model_entropy

noisy_model_1_info        = noisy_model_1_penalty * noisy_model_1_entropy

noisy_model_2_info        = noisy_model_2_penalty * noisy_model_2_entropy

partial_good_model_1_info = partial_good_model_1_penalty * partial_good_model_1_entropy

partial_good_model_2_info = partial_good_model_2_penalty * partial_good_model_2_entropy

# comparing custom metric with AIC
metric_vs_AIC = as.data.frame(cbind(
  c(full_model_info, good_model_info, bad_model_info, noisy_model_1_info, noisy_model_2_info, partial_good_model_1_info, partial_good_model_2_info),
  c(AIC(full_model_scaled), AIC(good_model_scaled), AIC(bad_model_scaled), AIC(noisy_model_scaled_1), AIC(noisy_model_scaled_2), AIC(partial_good_model_scaled_1), AIC(partial_good_model_scaled_2))
))
names(metric_vs_AIC) = c("custom_metric", "AIC")
metric_vs_AIC

# generate unseen data
# NOTE: overriding the old x1, ..., x4 so the predict() function works properly
x1 = c()
x2 = c()
x3 = c()
x4 = c()
y = c()
for (i in 1:1000)
{
  x1[i] = rnorm(1, mean = 2, sd = 1)
  x2[i] = rnorm(1, mean = -1, sd = 2)
  x3[i] = rnorm(1, mean = 3.5, sd = 2.2)
  x4[i] = rnorm(1, mean = 1, sd = 4)
  y[i] = 3*x1[i] + 2*x2[i] + 0*x3[i] + 0*x4[i] + 10 + rnorm(1, mean = 0, sd = 4)
}
unseen_data = as.data.frame(cbind(x1, x2, x3, x4))

# evaluate RMSE of models on unseen data
full_model_rmse           = sqrt(mean((y - predict.lm(full_model, newdata = unseen_data))^2))

good_model_rmse           = sqrt(mean((y - predict.lm(good_model, newdata = unseen_data))^2))

bad_model_rmse            = sqrt(mean((y - predict.lm(bad_model, newdata = unseen_data))^2))

noisy_model_1_rmse        = sqrt(mean((y - predict.lm(noisy_model_1, newdata = unseen_data))^2))

noisy_model_2_rmse        = sqrt(mean((y - predict.lm(noisy_model_2, newdata = unseen_data))^2))

partial_good_model_1_rmse = sqrt(mean((y - predict.lm(partial_good_model_1, newdata = unseen_data))^2))

partial_good_model_2_rmse = sqrt(mean((y - predict.lm(partial_good_model_2, newdata = unseen_data))^2))


# compare custom metric to RMSE values on unseen data
metric_vs_RMSE = as.data.frame(cbind(
  c(full_model_info, good_model_info, bad_model_info, noisy_model_1_info, noisy_model_2_info, partial_good_model_1_info, partial_good_model_2_info),
  c(AIC(full_model_scaled), AIC(good_model_scaled), AIC(bad_model_scaled), AIC(noisy_model_scaled_1), AIC(noisy_model_scaled_2), AIC(partial_good_model_scaled_1), AIC(partial_good_model_scaled_2)),
  c(full_model_rmse, good_model_rmse, bad_model_rmse, noisy_model_1_rmse, noisy_model_2_rmse, partial_good_model_1_rmse, partial_good_model_2_rmse)
))
names(metric_vs_RMSE) = c("custom_metric", "AIC", "RMSE")
metric_vs_RMSE
