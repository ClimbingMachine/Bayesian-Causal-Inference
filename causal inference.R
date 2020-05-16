setwd("C:/Users/test_/Desktop/Bayesian Structural Time Series")
san_data <- read.csv("test.csv")
new_york <- read.csv("newyork.csv")
sf1 <- read.csv("sf1.csv")
sf2 <- read.csv("sf2.csv")
indy <- read.csv("indy.csv")
seatle <- read.csv("seatle.csv")
longbeach <-  read.csv("longbeach.csv")
charlotte <- read.csv("charlotte.csv")

# visualization of the time series data.
plot(san_data$total[1500:2033], type = "l", col = "gray", main ="COVID-19 on Ped Visits", xlab ="Days", ylab = "Visits")
abline(v=length(san_data$total[1500:2033]) - 100, col="blue", lty = 2, lwd = 3)

plot(sf1$total, type = "l", col = "red", main ="COVID-19 on Ped Visits", xlab ="Days", ylab = "Visits")
lines(sf2$total, col = "blue")
lines(san_data$total[(2003-135):2003], type = "l", col = "black")
lines(seatle$total, col = "coral")

# covid <- san_data[(2003-500):2003, ]
# dim(covid)

# temperature as covariates
covid <- longbeach
longbeach_weather <- read.csv("lbweather.csv")
PRCP <- longbeach_weather$PRCP
TMAX <- longbeach_weather$TMAX
TMIN <- longbeach_weather$TMIN

dim(covid)

hur_data <- list(
  T = length(covid$total) - 70,
  T_forecast = 70,
  L = length(covid$total),
  y = covid$total[1:(length(covid$total)-70)]/100,
  PRCP = PRCP,
  TMAX = TMAX,
  TMIN = TMIN
)

library('rstan')

fit_hur <- stan(
  file = "poi.stan",  # Stan program
  data = hur_data,    # named list of data
  chains = 1,             # number of Markov chains
  warmup = 1000,          # number of warmup iterations per chain
  iter = 2000,            # total number of iterations per chain
  cores = 2,              # number of cores (could use one per chain)
  refresh = 1,             # no progress shown
  control = list(adapt_delta = 0.95)
)


# extract parameters

y_rep <- summary(fit_hur, pars = "y_forecast", probs = c(0.025, 0.975))$summary
mu_rep <- summary(fit_hur, pars = "mu", probs = c(0.025, 0.975))$summary
tau_rep <- summary(fit_hur, pars = "tau", probs = c(0.025, 0.975))$summary
beta1_rep <- summary(fit_hur, pars = "beta1", probs = c(0.025, 0.975))$summary
beta2_rep <- summary(fit_hur, pars = "beta2", probs = c(0.025, 0.975))$summary
beta3_rep <- summary(fit_hur, pars = "beta3", probs = c(0.025, 0.975))$summary

# generate new parameters

y <- mu_rep[, 1] + tau_rep [, 1] + beta1_rep[, 1]*PRCP +  
  beta2_rep[, 1] * TMAX +  beta3_rep[, 1] * TMIN

par(mfrow = c(3,1))

y_replicate <- c(y, y_rep[,1])
plot(covid$total, type = "l", col = "red", lty = 1, lwd = 2)
lines(y_replicate*100, col = "blue", lty = 2, lwd = 2)
delta <- covid$total/100 - y_replicate
plot(delta * 100, type = "l", col = "red", lty = 1, lwd = 2)

cum <- numeric()

for(i in 1:length(y_replicate)){
  cum <- append(cum, sum(delta[1:i]))
}

plot(cum*100, type = "l", col = "red", lty = 1, lwd = 2,
     ylab = "Visits", xlab = "days", main = "Cumulative Loss of Tourists in Seattle")


abline(v=65, col="blue", lty = 2, lwd = 2)
