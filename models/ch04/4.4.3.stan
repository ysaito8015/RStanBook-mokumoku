data {
  int N;
  real e[N];
  real X[N];
  real Y_base[N];
  real Y[N];
}

parameter {
  real sigma;
  real a;
  real b;
}

model {
  for (n in 1:N) {
    e[n] ~ normal(0, sigma);
    Y_base[n] = a + b * X[n];
    Y[n] = Y_base[n] + e[n];
  }
}
