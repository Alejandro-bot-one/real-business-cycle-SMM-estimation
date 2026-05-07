/*
 * RBC Model SMM Estimation
 */

var Y, C, I, K, N, w, r, A, y_obs;

varobs y_obs;

varexo eps_a;

parameters beta, alpha, delta, theta, rho_a, A_bar, sigma_a;

beta    = 0.985;
alpha   = 1/3;
delta   = 0.025;
A_bar   = 1;
rho_a   = 0.979;   
sigma_a = 0.007;          
theta   = 0.88;

model;
    Y = C + I;
    C(+1)/C = beta * (r(+1) + 1 - delta);
    I = K - (1-delta)*K(-1);
    N = (w - theta * C) / w; 
    r = alpha * Y / K(-1);
    w = (1-alpha) * Y / N;
    Y = A * K(-1)^alpha * N^(1-alpha);
    
    log(A) = rho_a * log(A(-1)) + eps_a;


    // Measurment Eq.
    y_obs = log(Y) - log(steady_state(Y));

end;


steady;
check;

estimated_params;
    rho_a,           0.2,   0.1,    0.99; 
    stderr eps_a,    0.002,  0.001,    0.2;      
end;

matched_moments;
    y_obs*y_obs;
    y_obs*y_obs(-1);                
end;

method_of_moments(datafile='us_data.csv', order=1, mom_method=SMM);


