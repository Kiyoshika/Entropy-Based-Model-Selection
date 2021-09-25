# Generate arbitrary regression model
y = c()
x1 = c()
x2 = c()
for (i in 1:200)
{
  x1[i] = rnorm(1, mean = 2, sd = 2)
  x2[i] = rnorm(1, mean = 4, sd = 3)
  y[i] = 3.3 * x1[i] + 4.8 * x2[i] + rnorm(1, mean = 0, sd = 5)
}

# Plot Data
full_data <- cbind(as.data.frame(x1), as.data.frame(x2), as.data.frame(y))
plot(x1,y, pch=19, lwd=3)
plot(x2,y, pch=19, lwd=3)


# Models
full_model <- lm(y ~ x1 + x2, data = full_data)
full_model$coefficients

x1_model <- lm(y ~ x1, data = full_data)
x1_model$coefficients

x2_model <- lm(y ~ x2, data = full_data)
x2_model$coefficients



# Evaluate Models
evaluate_full_model <- function(x1, x2)
{
  newdata = cbind(as.data.frame(x1), as.data.frame(x2))
  predict.lm(full_model, newdata)
}

evaluate_x1_model <- function(x1)
{
  newdata = as.data.frame(x1)
  predict.lm(x1_model, newdata)
}

evaluate_x2_model <- function(x2)
{
  newdata = as.data.frame(x2)
  predict.lm(x2_model, newdata)
}



# Compute Likelihoods
fit1 <- c()
for (i in 1:nrow(full_data))
{
  fit1[i] = dnorm(y[i], mean = evaluate_full_model(x1[i], x2[i]), sd = sd(residuals(full_model)))
}

fit2 <- c()
for (i in 1:nrow(full_data))
{
  fit2[i] = dnorm(y[i], mean = evaluate_x1_model(x1[i]), sd = sd(residuals(x1_model)))
}

fit3 <- c()
for (i in 1:nrow(full_data))
{
  fit3[i] = dnorm(y[i], mean = evaluate_x2_model(x2[i]), sd = sd(residuals(x2_model)))
}

fit4 <-c() # default model (mean of dependent variable)
for (i in 1:nrow(full_data))
{
  fit4[i] = dnorm(y[i], mean = mean(y), sd = sd(y - mean(y)))
}



# Compute Entropy (the lower the better)
# H(X) = -E[log f(x)], f(x) being the likelihood
# lower entropy corresponds to more predictability within a probabilistic system
-mean(log(fit1))
-mean(log(fit2))
-mean(log(fit3))
-mean(log(fit4))



# For comparison, we can display the AIC values
# don't have a model for default case (mean) so I'm ignoring it here, but 
# theoretically should be similar to x2_model
AIC(full_model)
AIC(x1_model)
AIC(x2_model)



# Information Gain - Relative Entropy
# "better" models will be > 0
# "worse" models will be < 0
# equivalent models will be 0
kl_div <- c()
for (i in 1:nrow(full_data))
{
  kl_div[i] = fit1[i]*log(fit1[i] / fit2[i])
}
-sum(kl_div)
