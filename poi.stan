/*Stan file for POI data*/

data {
  int<lower=1> T;            // Time Index
  int<lower=1> T_forecast;   // Forecast Index
  int<lower=1> L;            // Total Length   
  real<lower=0> y[T];        // Response variable (Number of visits) Priscription as a covariate
  real<lower=0> PRCP[L];     // Priscription as a covariate
  real<lower=0> TMAX[L];     // Maximum Temperature as a covariate
  real<lower=0> TMIN[L];     // Minimum Temperature as a covariate
}


parameters {

  real<lower = 0> eta1;    // Standard deviation of random effect
  real<lower = 0> eta2;    // Standard deviation of the individual observations
  real<lower = 0> eta3;    // Standard deviation of the individual observations
  real<lower = 0> mu1;     // Standard deviation of the individual observations
  real tau_0;              // Standard deviation of the individual observations
  real mu_0;               // Standard deviation of the individual observations

  real beta1;               // Standard deviation of the individual observations
  real beta2;               // Standard deviation of the individual observations
  real beta3;               // Standard deviation of the individual observations

  real sigma_beta1;            // Standard deviation of the PRCP
  real sigma_beta2;            // Standard deviation of the TMAX
  real sigma_beta3;            // Standard deviation of the TMIN

  real mu_beta1;               // Mean of the PRCP
  real mu_beta2;               // Mean of the TMAX
  real mu_beta3;               // Mean of the TMIN
  
  real<lower = 0> sigma_y; // The error term
  vector[T] mu;            // Individual mean
  vector[T] tau;           // Tau
}

model {  
  // Priors
  eta1 ~ cauchy(0, 2.5);
  eta2 ~ cauchy(0, 2.5);
  eta3 ~ cauchy(0, 2.5);
  sigma_y ~ cauchy(0,2.5); // weakly informative prior
  
  // Local Trend Prior Block
  tau_0 ~ cauchy(0,2.5);
  mu_0 ~ cauchy(0,2.5);
  mu1 ~ cauchy(0, 2.5);
  
  // Covariate Prior Block
  mu_beta1 ~ normal(0, 10);
  mu_beta2 ~ normal(0, 10);
  mu_beta3 ~ normal(0, 10);

  sigma_beta1 ~ cauchy(0, 2.5);
  sigma_beta2 ~ cauchy(0, 2.5);
  sigma_beta3 ~ cauchy(0, 2.5);  
  
  beta1 ~  normal(mu_beta1, sigma_beta1);
  beta2 ~  normal(mu_beta1, sigma_beta2);
  beta3 ~  normal(mu_beta1, sigma_beta3);
  
  // Local Trend
  mu[1] ~ normal(mu_0, tau_0);                  //Initialization
 
  for(t in 2:T){
      mu[t] ~ normal(mu[t-1], mu1);
  }

  // Seasonality Trend

  for(t in 1:6){                                //Initialization
      tau[t] ~ normal(tau_0, eta2);
  }
 
  for(t in 7:T){
      tau[t] ~ normal(-(tau[t-6] + tau[t-5] + tau[t-4] + tau[t-3] + tau[t-2] + tau[t-1]), eta3);
  }
  
  for(t in 1:T){
      y[t] ~ normal(mu[t] + tau[t] + beta1 * PRCP[t] + beta2 * TMAX[t] + beta3 * TMIN[t], sigma_y); // Likelihood
  }
}



generated quantities {
  real y_forecast[T_forecast];
  real mu_forecast[T_forecast];
  real tau_forecast[T_forecast];

  mu_forecast[1] = normal_rng(mu[T], mu1);
  for (t in 2:T_forecast) {
    mu_forecast[t] = normal_rng(mu_forecast[t-1], mu1);
  }

  tau_forecast[1] = normal_rng(-(tau[T]+tau[T-1]+tau[T-2]+tau[T-3]+tau[T-4]+tau[T-5]), eta3);
  tau_forecast[2] = normal_rng(-(tau[T]+tau[T-1]+tau[T-2]+tau[T-3]+tau[T-4]+tau_forecast[1]), eta3);
  tau_forecast[3] = normal_rng(-(tau[T]+tau[T-1]+tau[T-2]+tau[T-3]+tau_forecast[2]+tau_forecast[1]), eta3);
  tau_forecast[4] = normal_rng(-(tau[T]+tau[T-1]+tau[T-2]+tau_forecast[3]+tau_forecast[2]+tau_forecast[1]), eta3);
  tau_forecast[5] = normal_rng(-(tau[T]+tau[T-1]+tau_forecast[4]+tau_forecast[3]+tau_forecast[2]+tau_forecast[1]), eta3);
  tau_forecast[6] = normal_rng(-(tau[T]+tau_forecast[5]+tau_forecast[4]+tau_forecast[3]+tau_forecast[2]+tau_forecast[1]), eta3);
  for (t in 7:T_forecast) {
    tau_forecast[t] = normal_rng(-(tau_forecast[t-1]+tau_forecast[t-2]+tau_forecast[t-3]+tau_forecast[t-4]+tau_forecast[t-5]+tau_forecast[t-6]), eta3);
  }

  for (t in 1:T_forecast) {
    y_forecast[t] = normal_rng(mu_forecast[t] + tau_forecast[t] +  beta1 * PRCP[T+t] + beta2 * TMAX[T+t] + beta3 * TMIN[T+t], sigma_y);
  }
}





