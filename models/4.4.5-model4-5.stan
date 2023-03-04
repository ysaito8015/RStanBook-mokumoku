data {
  int N;     // Number of the samples
  // Array of the observed value mapping by a random variable X
  real X[N]; // years- old
  // Array of the observed value mapping by a random variable Y
  real Y[N]; // salary
}

parameters { // parameters to estimate by model
  real<lower=0> sigma;
  real a;
  real b;
}

model { // probabilistic model to estimate parameters
  // e[n] : noise
  // y_base[n] : base salary
  // a : intercept
  // b : coefficient of X
  // Y[n] = y_base[n] + e[n]
  // y_base[n] = a + b * X[n]
  // e[n] ~ Normal(0, sigma)
  // snip the parametes ~ uni(-infty, infty)
  for (n in 1:N) {
    Y[n] ~ normal(a + b * X[n], sigma);
    // use a target variable
    // target += normal_lpdf(Y[n] | a + b * X[n], sigma);
  }
} // must have a blank line

