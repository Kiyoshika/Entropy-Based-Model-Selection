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
plot(x1, y, pch=19, lwd=3)
plot(x2, y, pch=19, lwd=3)



# Generate test data
y_t = c()
x1_t = c()
x2_t = c()
for (i in 1:1000)
{
  x1_t[i] = rnorm(1, mean = 2, sd = 2)
  x2_t[i] = rnorm(1, mean = 4, sd = 3)
  y_t[i] = 3.3 * x1_t[i] + 4.8 * x2_t[i] + rnorm(1, mean = 0, sd = 5)
}



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



library(dplyr)
# Evaluate models against test data
full_test_data <- cbind(as.data.frame(x1_t), as.data.frame(x2_t), as.data.frame(y_t))
names(full_test_data) <- c("x1","x2","y")

x1_test_data = full_test_data %>% select(x1)
x2_test_data = full_test_data %>% select(x2)
y_test_data = full_test_data %>% select(y)

full_model_preds = predict.lm(full_model, newdata = full_test_data)
x1_model_preds = predict.lm(x1_model, newdata = x1_test_data)
x2_model_preds = predict.lm(x2_model, newdata = x2_test_data)

# Mean absolute error
mean(unlist(abs(full_model_preds - y_test_data)))
mean(unlist(abs(x1_model_preds - y_test_data)))
mean(unlist(abs(x2_model_preds - y_test_data)))
mean(unlist(abs(mean(y) - y_test_data)))
