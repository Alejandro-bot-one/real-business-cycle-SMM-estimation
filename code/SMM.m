%% Dynare Code

%rmdir("RBC_smm", "s")
rmdir("simulations", "s")
dynare simulations.mod

%% Plotting: Real vs. Simulated Cycles
% Prerequisite: Run dynare RBC_smm.mod first so 'oo_' and 'M_' exist in workspace.

% 1. Load Real Data
% Ensure us_data.csv exists and has columns: y_obs, c_obs, i_obs, n_obs
try
    data_table = readtable('us_data.csv'); 
catch
    error('Could not find us_data.csv. Please ensure the file is in the current folder.');
end

% 2. Get Simulation Indices for Theoretical Variables
% Note: Your mod file only has 'y_obs'. For C, I, N we must use the theoretical levels.
id_y_obs = strmatch('y_obs', M_.endo_names, 'exact'); % Defined in mod
id_c     = strmatch('C', M_.endo_names, 'exact');     % Theoretical Level
id_i     = strmatch('I', M_.endo_names, 'exact');     % Theoretical Level
id_n     = strmatch('N', M_.endo_names, 'exact');     % Theoretical Level

% 3. Process Real Data (Assuming CSV is already in % deviations or log-diff)
% If your CSV data is raw levels, you must detrend/log it here first.
% We assume here the CSV columns match the model units (percentage deviations).
T_data = height(data_table);
y_real_full = data_table.y_obs * 100; % Scaling to Percentage if data is decimal
c_real_full = data_table.c_obs * 100;
i_real_full = data_table.i_obs * 100;
n_real_full = data_table.n_obs * 100;

% 4. Process Simulated Data
% Determine length of simulation (defined by 'periods' in stoch_simul)
T_sim = size(oo_.endo_simul, 2);
T = min(T_data, T_sim); % Plot the overlapping duration

fprintf('Plotting %d quarters.\n', T);

% Slice Real Data
y_real = y_real_full(1:T);
c_real = c_real_full(1:T);
i_real = i_real_full(1:T);
n_real = n_real_full(1:T);

% Extract and Transform Simulated Data
% A. Output is easy (y_obs is already a deviation in the mod file)
y_sim = oo_.endo_simul(id_y_obs, 1:T)' * 100; 

% B. For C, I, N: Convert Levels to Log-Deviations from Steady State
% Formula: (log(Variable_t) - log(SteadyState)) * 100
c_ss = oo_.steady_state(id_c);
i_ss = oo_.steady_state(id_i);
n_ss = oo_.steady_state(id_n);

c_sim = (log(oo_.endo_simul(id_c, 1:T)) - log(c_ss))' * 100;
i_sim = (log(oo_.endo_simul(id_i, 1:T)) - log(i_ss))' * 100;
n_sim = (log(oo_.endo_simul(id_n, 1:T)) - log(n_ss))' * 100;

% Define Purple Color
purple = [0.4940 0.1840 0.5560];

%% ---------------------------------------------------------
% Figure 1: OUTPUT (GDP)
% ---------------------------------------------------------
figure('Name', 'Output Cycle: Data vs. Model', 'Color', 'w');
plot(y_real, 'Color', purple, 'LineWidth', 2); hold on;
plot(y_sim,  'r--', 'LineWidth', 1.5);
yline(0, 'k-', 'Alpha', 0.2); 
title('Business Cycle: Output (Y)');
legend('Observed Data', 'Simulated Model', 'Location', 'Best');
ylabel('% Deviation'); xlabel('Quarters');
grid on; axis tight; ylim([-6 6]);

%% ---------------------------------------------------------
% Figure 2: CONSUMPTION
% ---------------------------------------------------------
figure('Name', 'Consumption Cycle: Data vs. Model', 'Color', 'w');
plot(c_real, 'Color', purple, 'LineWidth', 2); hold on;
plot(c_sim,  'r--', 'LineWidth', 1.5);
yline(0, 'k-', 'Alpha', 0.2);
title('Business Cycle: Consumption (C)');
legend('Observed Data', 'Simulated Model', 'Location', 'Best');
ylabel('% Deviation'); xlabel('Quarters');
grid on; axis tight; ylim([-6 6]);

%% ---------------------------------------------------------
% Figure 3: INVESTMENT
% ---------------------------------------------------------
figure('Name', 'Investment Cycle: Data vs. Model', 'Color', 'w');
plot(i_real, 'Color', purple, 'LineWidth', 2); hold on;
plot(i_sim,  'r--', 'LineWidth', 1.5);
yline(0, 'k-', 'Alpha', 0.2);
title('Business Cycle: Investment (I)');
legend('Observed Data', 'Simulated Model', 'Location', 'Best');
ylabel('% Deviation'); xlabel('Quarters');
grid on; axis tight; 
% Investment is volatile, widen limits
ylim([-25 25]); 

%% ---------------------------------------------------------
% Figure 4: HOURS WORKED
% ---------------------------------------------------------
figure('Name', 'Labor Cycle: Data vs. Model', 'Color', 'w');
plot(n_real, 'Color', purple, 'LineWidth', 2); hold on;
plot(n_sim,  'r--', 'LineWidth', 1.5);
yline(0, 'k-', 'Alpha', 0.2);
title('Business Cycle: Hours Worked (N)');
legend('Observed Data', 'Simulated Model', 'Location', 'Best');
ylabel('% Deviation'); xlabel('Quarters');
grid on; axis tight; ylim([-6 6]);