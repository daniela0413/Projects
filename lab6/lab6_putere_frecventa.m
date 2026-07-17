%% LABORATOR NR. 6 - Simularea sistemelor de reglare a marimilor electrice
%%                   aferente unei termocentrale
%%
%% PARTEA a) - Sistemul de reglare a puterii active si a frecventei
%%
%% Schema bloc: fig. 6.2
%% Semnal referinta frecventa: u*f = 10V (corespunde f_nom = 50 Hz)
%% Semnal referinta putere:    u*P = 10V (corespunde P_nom = 360 MW)
%% Perturbatia in frecventa:   pf  [Hz] - treapta -5 Hz la t=150s
clear; clc; close all;

%% =========================================================
%% PARAMETRI SISTEM (din lucrare, ec. 6.1-6.8)
%% =========================================================
% Servomotor hidraulic (SMH): H_SMH = K_SMH + 1/(T_SMH*s)
K_SMH  = 0.01;   % [m/V]
T_SMH  = 20;     % [s]
% Ventil (V): proportional
K_V    = 10667.51; % [to/(m*h)]
% Turbina + Generator (T+G): ordinul I
K_TG   = 0.337;  % [MW*h/to]
T_TG   = 10;     % [s]
% Sistem energetic (S): ordinul II
K_S    = 0.139;  % [Hz/MW]
T1S    = 1;      % [s]
T2S    = 2;      % [s]
% Traductor putere activa: proportional
K_Pup  = 0.027;  % [V/MW]
% Traductor frecventa: proportional
K_fuf  = 0.2;    % [V/Hz]
% Regulator putere activa (RP): PD cu filtru
K_R    = 10;     % adimensional
T_D    = 10;     % [s]
T_f    = 0.2;    % [s] - filtru derivativ
% Statism
K_ST   = 125;    % adimensional
% Semnale de referinta (tensiune unificata)
u_P_ref  = 10;   % [V] - corespunde P = 360 MW
u_f_ref  = 10;   % [V] - corespunde f = 50 Hz

fprintf('=== SISTEM a) PUTERE ACTIVA SI FRECVENTA ===\n\n');
fprintf('Semnale de referinta:\n');
fprintf('  u*P = %.0fV -> P_nom = 360 MW\n', u_P_ref);
fprintf('  u*f = %.0fV -> f_nom = 50 Hz\n\n', u_f_ref);

%% =========================================================
%% CONSTRUCTIE FUNCTII DE TRANSFER
%% =========================================================
s = tf('s');
% SMH: integrator + proportional = (K_SMH*T_SMH*s + 1) / (T_SMH*s)
H_SMH  = tf([K_SMH*T_SMH, 1], [T_SMH, 0]);
% Ventil
H_V    = tf(K_V, 1);
% Turbina + Generator
H_TG   = tf(K_TG, [T_TG, 1]);
% Sistem energetic
H_S    = tf(K_S, conv([T1S, 1], [T2S, 1]));
% Traductoare (proportionale)
H_Pup  = tf(K_Pup, 1);
H_fuf  = tf(K_fuf, 1);
% Regulator RP (PD cu filtru)
H_RP   = tf(K_R * [T_D, 1], [T_f, 1]);
% Statism
H_ST   = tf(K_ST, 1);

%% =========================================================
%% SCHEMA IN BUCLA INCHISA SOLIDA (FARA IMPROPREIETATI)
%% =========================================================
% Definim blocurile inainte de S (calea comuna de comanda/putere)
H_Fwd_to_P = H_RP * H_SMH * H_V * H_TG; 

% 1. De la u*P la f (Frecventa)
H_CL_f_ref = feedback(H_Fwd_to_P * H_S, H_Pup + K_ST * H_fuf * H_S);

% 2. De la perturbatie pf la f (Frecventa)
H_CL_f_pert = feedback(1, H_Fwd_to_P * H_S * (H_Pup + K_ST * H_fuf * H_S));

% 3. De la u*P la P (Putere) -> Sistem propriu
H_CL_P_from_uP = feedback(H_Fwd_to_P, H_S * (H_Pup + K_ST * H_fuf * H_S));

% 4. De la perturbatie pf la P (Putere) -> Sistem propriu
% Daca apare pf pe frecventa, bucla reactioneaza negativ prin traductoare
H_CL_P_from_pf = feedback(-H_Fwd_to_P * K_ST * H_fuf, H_S * H_Pup);

% 5. Functii de transfer pentru semnale de comanda c (iesire RP)
H_cmd_from_uP = feedback(H_RP, H_SMH * H_V * H_TG * H_S * (H_Pup + K_ST * H_fuf * H_S));
H_cmd_from_pf = feedback(-H_RP * K_ST * H_fuf, H_S * H_Pup * H_SMH * H_V * H_TG);

fprintf('Functii de transfer in bucla inchisa determinate (corectate structural).\n\n');

%% =========================================================
%% SIMULARE 1: Pornire sistem + Perturbatie frecventa
%% =========================================================
fprintf('=== SIMULARE 1: Treapta referinta + perturbatie frecventa ===\n');
t_sim = 0:0.5:300;
t_pert_f = 150;   
pf_val   = -5;    

% Intrari perturbatie
idx_pert = round(t_pert_f / 0.5) + 1;
u_pert = zeros(size(t_sim));
u_pert(idx_pert:end) = pf_val;

% Calcul Frecventa
[f_ref, t_out] = step(H_CL_f_ref * u_P_ref, t_sim);
[f_pert_resp, ~] = lsim(H_CL_f_pert, u_pert, t_sim);
f_total = f_ref + f_pert_resp;

% Calcul Putere Activa (Folosind functiile corectate)
[P_ref, ~]   = step(H_CL_P_from_uP * u_P_ref, t_sim);
[P_pert, ~]  = lsim(H_CL_P_from_pf, u_pert, t_sim);
P_total = P_ref + P_pert;
P_MW = P_total; % Deoarece H_Fwd_to_P genereaza direct MW la iesirea H_TG

% Calcul Comanda c_qabv (Folosind functiile corectate)
[c_ref, ~]  = step(H_cmd_from_uP * u_P_ref, t_sim);
[c_pert, ~] = lsim(H_cmd_from_pf, u_pert, t_sim);
c_total = c_ref + c_pert;

fprintf('Valoare stationara frecventa: %.4f V\n', f_ref(end));
fprintf('Valoare stationara putere: %.2f MW\n', P_ref(end));
fprintf('Abatere stationara frecventa dupa perturbatie: %.6f V\n', f_total(end));

%% FIGURA 1 - Evolutia frecventei si puterii
figure(1);
subplot(2,1,1);
plot(t_out, f_total, 'b-', 'LineWidth', 2);
yline(0, 'k--', 'LineWidth', 1);
yline(u_f_ref*K_fuf, 'r:', 'LineWidth', 1);
xline(t_pert_f, 'm:', 'LineWidth', 1);
grid on; xlabel('Timp [s]'); ylabel('f [V]');
title('Fig. 6.4 echiv. - Evolutia frecventei (treapta ref. + pert.)');
xlim([0 300]);

subplot(2,1,2);
plot(t_out, P_MW, 'r-', 'LineWidth', 2);
yline(360, 'k--', 'LineWidth', 1);
xline(t_pert_f, 'm:', 'LineWidth', 1);
grid on; xlabel('Timp [s]'); ylabel('P [MW]');
title('Puterea activa livrata in sistem [MW]');
xlim([0 300]);

%% =========================================================
%% SIMULARE 2: Cu "intarziere" semnale (Filtrare)
%% =========================================================
fprintf('\n=== SIMULARE 2: Semnale filtrate ("intarziate") ===\n');
H_REF1 = tf(1, conv([5,1],[8,1]));   
H_PERT1= tf(1, conv([1,1],[1,1]));   

% Aplicam filtrele direct pe intrarile sistemelor sigure
[f_ref_filt,  ~] = step(H_CL_f_ref * H_REF1 * u_P_ref, t_sim);
[f_pert_filt, ~] = lsim(H_CL_f_pert * H_PERT1, u_pert, t_sim);
f_total_filt = f_ref_filt + f_pert_filt;

figure(2);
subplot(2,1,1);
plot(t_out, f_total,      'b--', 'LineWidth',2, 'DisplayName','Fara filtrare');
hold on;
plot(t_out, f_total_filt, 'r-',  'LineWidth',2, 'DisplayName','Cu filtrare');
yline(0,'k:','LineWidth',1,'HandleVisibility','off');
xline(t_pert_f,'m:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [s]'); ylabel('f [V]');
title('Fig. 6.6 echiv. - Frecventa cu/fara filtrarea semnalelor');
legend('Location','southeast'); xlim([0 300]);

subplot(2,1,2);
plot(t_out, c_total, 'b--', 'LineWidth',2);
grid on; xlabel('Timp [s]'); ylabel('c_{qabv} [V]');
title('Fig. 6.7 echiv. - Semnalul de comanda c_{qabv}');
xlim([0 300]);

%% =========================================================
%% SIMULARE 3: Tf ajustat (Tf1 = 0.09s)
%% =========================================================
T_f_adj = 0.09;  
H_RP_adj = tf(K_R * [T_D, 1], [T_f_adj, 1]);
H_Fwd_to_P_adj = H_RP_adj * H_SMH * H_V * H_TG;

H_CL_f_adj  = feedback(H_Fwd_to_P_adj * H_S, H_Pup + K_ST * H_fuf * H_S);
H_CL_fp_adj = feedback(1, H_Fwd_to_P_adj * H_S * (H_Pup + K_ST * H_fuf * H_S));

[f_ref_adj,  ~] = step(H_CL_f_adj * H_REF1 * u_P_ref, t_sim);
[f_pert_adj, ~] = lsim(H_CL_fp_adj * H_PERT1, u_pert, t_sim);
f_adj = f_ref_adj + f_pert_adj;

figure(3);
plot(t_out, f_total_filt, 'b--', 'LineWidth',2, 'DisplayName',sprintf('T_f=%.2fs', T_f));
hold on;
plot(t_out, f_adj,        'r-',  'LineWidth',2, 'DisplayName',sprintf('T_f=%.3fs (ajustat)', T_f_adj));
yline(0,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [s]'); ylabel('f [V]');
title('Fig. 6.8 echiv. - Efectul ajustarii filtrului din regulator');
legend('Location','southeast'); xlim([0 300]);

%% =========================================================
%% SIMULARE 4: Putere debitata 300MW
%% =========================================================
fprintf('\n=== SIMULARE 4: Putere debitata 300 MW ===\n');
u_P_300 = 300 * K_Pup;   % [V] referinta scalata

[f_300, ~] = step(H_CL_f_ref * H_REF1 * u_P_300, t_sim);
[P_300, ~] = step(H_CL_P_from_uP * H_REF1 * u_P_300, t_sim);

figure(4);
subplot(2,1,1);
plot(t_out, f_300/K_fuf + 50, 'b-', 'LineWidth',2);
yline(50,'r--','LineWidth',1);
grid on; xlabel('Timp [s]'); ylabel('f [Hz]');
title('Frecventa [Hz] - Pornire la P=300MW (cu filtrare)');
xlim([0 300]);

subplot(2,1,2);
plot(t_out, P_300, 'r-', 'LineWidth',2);
yline(300,'k--','LineWidth',1);
grid on; xlabel('Timp [s]'); ylabel('P [MW]');
title('Puterea activa la P=300MW');
xlim([0 300]);