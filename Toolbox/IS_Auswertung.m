clc
clear
close all

% units
% rho_al, rho_pb = g/cm^3
% t_al, t_pb = s
% tau_0 = mu s
% x_al, x_pb = mm
% n_mess_al, n_korr_al, n1, n_mess_pb, n_korr_pb = 1/s
% d_betamax = mm
% n_gamma_max, n_ges, n_beta_max = 1/s
% mu_al, mu_pb = 1/cm
% mu_rho = cm^2/g
% d_half_pb = mm

% pre allocation
data = struct;

% pre definition
x_al = [0.1, 0.3, 0.5, 0.8, 1.0, 2.0, 3.0, 4.0, 8.0, 16.0]; % in mm
x_pb = [1.0, 2.0, 3.0, 4.0, 6.0, 8.0, 10.0, 15.0, 20.0, 30.0];  % in mm
t_al = ones(size(x_al));
t_pb = ones(size(x_pb));
t_al(:) = 60;    % in s
t_pb(:) = 120;  % in s
tau_0 = 230;    % in µs
y = log(1/50);
rho_al = 2.7;   % in g/cm^3
rho_pb = 11.34; % in g/cm^3

% insert their values here
N_al = [15276, 5905, 2584, 627, 534, 500, 464, 491, 444, 348];
N_pb = [1218, 999, 831, 888, 682, 534, 484, 333, 268, 109];

% 1a) n_mess & n_korr Aluminium
n_mess_al = zeros(size(N_al));
n_korr_al = zeros(size(N_al));
for N = 1:size(N_al, 2)
    n_mess_al(N) = N_al(N) / t_al(N);
    n_korr_al(N) = (N_al(N) / t_al(N)) / (1 - ((N_al(N) / t_al(N)) * tau_0 * 10^(-6)));
end

% ln(n_i/n_1) Aluminium
ln_nin1_al = zeros(size(N_al));
for N = 1:size(N_al, 2)
    ln_nin1_al(N) = log(n_korr_al(N) / n_korr_al(1));
end

n1 = n_korr_al(1);

% 1b) plot 
fig_al = figure(1);
hold on


% Regressionsgerade
x1 = x_al(1:4);
x2 = x_al(5:end);
y1 = ln_nin1_al(1:4);
y2 = ln_nin1_al(5:end);

p1 = polyfit(x1, y1, 1);
f1 = polyval(p1, x1);
p2 = polyfit(x2, y2, 1);
f2 = polyval(p2, x2);


al_1 = plot(x1, y1);
al_1.Marker = "o";
al_1.MarkerEdgeColor = "blue";
al_1.MarkerFaceColor = "blue";
al_1.LineStyle = "none";
al_1_reg = plot(x1, f1);
al_1_reg.Color = "blue";
al_2 = plot(x2, y2);
al_2.Marker = "o";
al_2.MarkerEdgeColor = "red";
al_2.MarkerFaceColor = "red";
al_2.LineStyle = "none";
al_2_reg = plot(x2, f2);
al_2_reg.Color = "red";

xlabel("x [mm]")
ylabel("ln(ni/n1)")
hold off

m1 = p1(1);     % in 1/mm
y0_1 = p1(2);
m2 = p2(1);     % in 1/mm
y0_2 = p2(2);

% 1c) Interpolation to find d_beta,max
d_betamax = (y - y0_1) / m1;

% 1d) mu/rho
mu_al = -m2 * 10;   % in 1/cm
mu_rho = mu_al/rho_al;  % in cm^2/g

% 2 Nachweiswahrscheinlichkeit
n_gamma_max = exp(y0_2) * n1;
n_ges = exp(y0_1) * n1;
n_beta_max = n_ges - n_gamma_max;

p_nachweis = n_gamma_max / n_beta_max;

data.x_al = x_al;
data.t_al = t_al;
data.N_al = N_al;
data.n_mess_al = n_mess_al;
data.n_korr_al = n_korr_al;
data.ln_nin1_al = ln_nin1_al;
data.n1_al = n1;
data.reg1_al = [m1, y0_1];
data.reg2_al = [m2, y0_2];
data.n_gamma_max_al = n_gamma_max;
data.n_beta_max_al = n_beta_max;
data.d_betamax_al = d_betamax;
data.Massenschwaechungskoeffizient_al = mu_rho;
data.Schwaechungskoeffizient_al = mu_al;
data.p_nachweis = p_nachweis;
data.tau_0 = tau_0;

% 3) Pb
% 3a) 
y = log(1/2);

n_mess_pb = zeros(size(N_pb));
n_korr_pb = zeros(size(N_pb));
for N = 1:size(N_pb, 2)
    n_mess_pb(N) = N_pb(N) / t_pb(N);
    n_korr_pb(N) = (N_pb(N) / t_pb(N)) / (1 - ((N_pb(N) / t_pb(N)) * tau_0 * 10^(-6)));
end

% ln(n_i/n_1) Aluminium
ln_nin1_pb = zeros(size(N_pb));
for N = 1:size(N_pb, 2)
    ln_nin1_pb(N) = log(n_mess_pb(N) / n_mess_pb(1));
end

n1 = n_mess_pb(1);

% plot 
fig_pb = figure(2);
hold on

p_pb = polyfit(x_pb, ln_nin1_pb, 1);
f_pb = polyval(p_pb, x_pb);


% Regressionsgerade
pb_plot = plot(x_pb, ln_nin1_pb);
pb_plot.Marker = "o";
pb_plot.MarkerEdgeColor = "blue";
pb_plot.MarkerFaceColor = "blue";
pb_plot.LineStyle = "none";

pb_plot_reg = plot(x_pb, f_pb);
pb_plot_reg.Color = "blue";

xlabel("x [mm]")
ylabel("ln(ni/n1)")

m1 = p_pb(1);     % in 1/mm
y0_1 = p_pb(2);

% 3 b) Halbwertsdicke
d_half_pb = (y - y0_1) / m1;

% 3c) Schwächungskoeffizient
mu_pb = -m1 * 10;     % in 1/cm
mu_rho = mu_pb/rho_pb;  % in cm^2/g

data.x_pb = x_pb;
data.t_pb = t_pb;
data.N_pb = N_pb;
data.n_mess_pb = n_mess_pb;
data.n_korr_pb = n_korr_pb;
data.ln_nin1_pb = ln_nin1_pb;
data.n1_pb = n1;
data.reg1_pb = [m1, y0_1];
data.d_half_pb = d_half_pb;
data.Massenschwaechungskoeffizient_pb = mu_rho;
data.Schwaechungskoeffizient_pb = mu_pb;


to_save = true;
if to_save
    prompt = ("Insert Filename: ");
    savename = input(prompt);
    save(strcat(char('G:\Meine Ablage\Master\Physik\Abgegebene Protokolle\Blockpraktikum SoSe 25\'), ...
                        char(savename), '.mat'), '-struct', 'data')
end