/*
 * RBC Model - Simulation Only
 * Parameters fixed at SMM estimation values: rho_a = 0.8088, sigma_a = 0.0009
 */

var Y, C, I, K, N, w, r, A, y_obs;
varobs y_obs;
varexo eps_a;

parameters beta, alpha, delta, theta, rho_a, A_bar, sigma_a;

% -------------------------------------------------------------------------
% 1. CALIBRATION & ESTIMATED VALUES
% -------------------------------------------------------------------------
beta    = 0.985;
alpha   = 1/3;
delta   = 0.025;
A_bar   = 1;
theta   = 0.88;

% Set the estimated parameters here:
rho_a   = 0.808;   
sigma_a = 0.0009;  % This is the standard deviation of the shock

% -------------------------------------------------------------------------
% 2. MODEL EQUATIONS
% -------------------------------------------------------------------------
model;
    Y = C + I;
    C(+1)/C = beta * (r(+1) + 1 - delta);
    I = K - (1-delta)*K(-1);
    N = (w - theta * C) / w; 
    r = alpha * Y / K(-1);
    w = (1-alpha) * Y / N;
    Y = A * K(-1)^alpha * N^(1-alpha);
    
    % Technology Process
    log(A) = rho_a * log(A(-1)) + eps_a;
    
    % Measurement Equation
    y_obs = log(Y) - log(steady_state(Y));
end;

% -------------------------------------------------------------------------
% 3. STEADY STATE & CHECKS
% -------------------------------------------------------------------------
steady;
check;

% -------------------------------------------------------------------------
% 4. SHOCKS
% -------------------------------------------------------------------------
shocks;
    var eps_a;
    stderr sigma_a;
end;

% -------------------------------------------------------------------------
% 5. SIMULATION
% -------------------------------------------------------------------------
% periods=200 generates the time series for your Matlab plots.
% irf=40 generates the Impulse Response Functions.
stoch_simul(order = 1, periods = 200) Y C I K N w r A;