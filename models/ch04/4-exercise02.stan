data {
  int N1;
  int N2;
  real Y1[N1];
  real Y2[N2];
}

parameters {
  real mu_Y1;
  real mu_Y2;
  real<lower=0> sigma_Y1;
  real<lower=0> sigma_Y2;
  //real diff;
}

model {
  for (n in 1:N1) {
    Y1[n] ~ normal(mu_Y1, sigma_Y1);
  }
  for (n in 1:N2) {
    Y2[n] ~ normal(mu_Y2, sigma_Y2);
  }
}

