data {
    int N;
    real Y[N];
}

parameter {
    real mu;
}

model {
    for (n in  1:N) {
        Y[n] ~ normal(mu, 1);
    }
    mu ~ normal(0, 100);
}
