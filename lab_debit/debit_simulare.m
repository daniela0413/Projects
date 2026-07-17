%% REGLARE DEBIT LICHID - Simulare si comparatie regulatoare
%% Comparatie P / PI / PID pe toate segmentele de referinta
%% Tabel centralizator performante
clear; clc; close all;
if ~exist('debit_params.mat','file')
    error('Rulati mai intai debit_identificare.m!');
end
load('debit_params.mat');
s = tf('s');
%% =========================================================
%% FUNCTII DE TRANSFER
%% =========================================================
H_proc = tf(K_proc, [T_dom 1]);
H_EE   = tf(1, [T_EE 1]);
H_TM   = tf(1, [T_TM 1]);
H_f    = H_EE * H_proc * H_TM;   % parte fixata
% Regulatoare
H_RP   = tf(K_R_P, 1);
H_RPI  = K_R_modul * (1 + 1/(T_I_modul * s));
Tf_d   = 0.1 * T_D_sim;
H_RPID = K_R_sim * (1 + 1/(T_I_sim*s) + (T_D_sim*s)/(1+Tf_d*s));
fprintf('Regulatoare:\n');
fprintf('  P:   K_R=%.4f\n', K_R_P);
fprintf('  PI:  K_R=%.4f, T_I=%.3fs\n', K_R_modul, T_I_modul);
fprintf('  PID: K_R=%.4f, T_I=%.3fs, T_D=%.5fs\n\n', K_R_sim, T_I_sim, T_D_sim);
%% =========================================================
%% SISTEME IN BUCLA INCHISA
%% =========================================================
H_CL_P   = feedback(H_RP   * H_f, 1);
H_CL_PI  = feedback(H_RPI  * H_f, 1);
H_CL_PID = feedback(H_RPID * H_f, 1);
% Comanda in bucla inchisa
H_cmd_P   = H_RP   * feedback(1, H_f * H_RP);
H_cmd_PI  = H_RPI  * feedback(1, H_f * H_RPI);
H_cmd_PID = H_RPID * feedback(1, H_f * H_RPID);
%% =========================================================
%% SIMULARE 1: Referinta treapta w=1 (normalizata)
%% =========================================================
t_sim = 0:0.01:30;
[y_P,   t_out] = step(H_CL_P,   t_sim);
[y_PI,  ~]     = step(H_CL_PI,  t_sim);
[y_PID, ~]     = step(H_CL_PID, t_sim);
[c_P,   ~]     = step(H_cmd_P,   t_sim);
[c_PI,  ~]     = step(H_cmd_PI,  t_sim);
[c_PID, ~]     = step(H_cmd_PID, t_sim);
[sig_P,  tr_P,  a_P,  cmin_P,  cmax_P]  = perf(y_P,  t_out, c_P,  3);
[sig_PI, tr_PI, a_PI, cmin_PI, cmax_PI] = perf(y_PI, t_out, c_PI, 3);
[sig_PID,tr_PID,a_PID,cmin_PID,cmax_PID]= perf(y_PID,t_out, c_PID,3);
fprintf('=== TABEL PERFORMANTE (referinta treapta) ===\n');
fprintf('%-8s %8s %10s %10s %12s\n','Reg.','a_stp','sigma[%]','tr[s]','[cmin;cmax]');
fprintf('%s\n', repmat('-',1,55));
fprintf('%-8s %8.4f %10.2f %10.3f %6.3f;%6.3f\n','P',  a_P,  sig_P,  tr_P,  cmin_P,  cmax_P);
fprintf('%-8s %8.4f %10.2f %10.3f %6.3f;%6.3f\n','PI', a_PI, sig_PI, tr_PI, cmin_PI, cmax_PI);
fprintf('%-8s %8.4f %10.2f %10.3f %6.3f;%6.3f\n','PID',a_PID,sig_PID,tr_PID,cmin_PID,cmax_PID);
%% =========================================================
%% SIMULARE 2: Secventa referinte reale din experiment
%% 0->100->20->70->100->150->200 L/h (normalizat fata de 200 L/h max)
%% =========================================================
fprintf('\n=== SIMULARE CU REFERINTE DIN EXPERIMENT ===\n');
w_nom = 200;   % [L/h] valoare de normalizare
t_sec = 0:0.1:600;
N_s   = length(t_sec);
% Referinte (normalizate la [0;1])
w_seq = zeros(N_s, 1);
w_seq(t_sec >= 0   & t_sec < 80)  = 100/w_nom;
w_seq(t_sec >= 80  & t_sec < 160) = 20/w_nom;
w_seq(t_sec >= 160 & t_sec < 300) = 70/w_nom;
w_seq(t_sec >= 300 & t_sec < 400) = 100/w_nom;
w_seq(t_sec >= 400 & t_sec < 500) = 150/w_nom;
w_seq(t_sec >= 500)               = 200/w_nom;
% Simulare cu lsim
[y_P_s,   ~] = lsim(H_CL_P,   w_seq, t_sec);
[y_PI_s,  ~] = lsim(H_CL_PI,  w_seq, t_sec);
[y_PID_s, ~] = lsim(H_CL_PID, w_seq, t_sec);
[c_PI_s,  ~] = lsim(H_cmd_PI, w_seq, t_sec);
% Conversie in L/h
y_P_lh   = y_P_s   * w_nom;
y_PI_lh  = y_PI_s  * w_nom;
y_PID_lh = y_PID_s * w_nom;
w_lh     = w_seq   * w_nom;
c_PI_pct = c_PI_s  * 100;  % comanda in %
%% =========================================================
%% COMPARATIE EXPERIMENTAL vs SIMULAT (PI)
%% =========================================================
figure(1);
subplot(3,1,1);
plot(t_exp, y_exp, 'k-', 'LineWidth',1, 'DisplayName','Experimental (bucla inchisa)');
hold on;
plot(t_sec, y_PI_lh, 'r--', 'LineWidth',2, 'DisplayName','PI simulat');
plot(t_exp, w_exp, 'b:', 'LineWidth',1.5, 'DisplayName','Referinta');
grid on; xlabel('Timp [s]'); ylabel('Debit [L/h]');
title('Comparatie experimental vs simulat (Regulator PI)');
legend('Location','northwest'); xlim([0 min(t_exp(end), 600)]);
subplot(3,1,2);
plot(t_exp, m_exp, 'k-', 'LineWidth',1, 'DisplayName','Comanda experimentala');
hold on;
plot(t_sec, c_PI_pct, 'r--', 'LineWidth',2, 'DisplayName','Comanda PI simulat');
grid on; xlabel('Timp [s]'); ylabel('Comanda [%]');
title('Comparatie comanda experimentala vs simulata');
legend('Location','northwest'); xlim([0 min(t_exp(end), 600)]);
subplot(3,1,3);
plot(t_exp, y_exp - w_exp, 'k-', 'LineWidth',1.5, 'DisplayName','Eroare experimentala');
hold on;
plot(t_sec, y_PI_lh - w_lh, 'r--', 'LineWidth',2, 'DisplayName','Eroare PI simulata');
yline(0,'b:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [s]'); ylabel('Eroare [L/h]');
title('Eroarea de reglare (y - w)');
legend('Location','northwest'); xlim([0 min(t_exp(end), 600)]);
%% =========================================================
%% COMPARATIE P vs PI vs PID
%% =========================================================
figure(2);
subplot(2,1,1);
plot(t_sec, y_P_lh,   'b-',  'LineWidth',2, 'DisplayName', ...
    sprintf('P (a_{stp}=%.3f, \\sigma=%.1f%%, t_r=%.2fs)', a_P, sig_P, tr_P));
hold on;
plot(t_sec, y_PI_lh,  'r--', 'LineWidth',2, 'DisplayName', ...
    sprintf('PI (a_{stp}=%.4f, \\sigma=%.1f%%, t_r=%.2fs)', a_PI, sig_PI, tr_PI));
plot(t_sec, y_PID_lh, 'g-.', 'LineWidth',2, 'DisplayName', ...
    sprintf('PID (a_{stp}=%.4f, \\sigma=%.1f%%, t_r=%.2fs)', a_PID, sig_PID, tr_PID));
plot(t_sec, w_lh, 'k:', 'LineWidth',1.5, 'DisplayName','Referinta');
grid on; xlabel('Timp [s]'); ylabel('Debit [L/h]');
title('Comparatie P / PI / PID - Raspuns la secventa de referinte');
legend('Location','northwest'); xlim([0 600]);
subplot(2,1,2);
[c_P_s,  ~] = lsim(H_cmd_P,   w_seq, t_sec);
[c_PID_s,~] = lsim(H_cmd_PID, w_seq, t_sec);
plot(t_sec, c_P_s*100,   'b-',  'LineWidth',2, 'DisplayName','c (P)');
hold on;
plot(t_sec, c_PI_pct,    'r--', 'LineWidth',2, 'DisplayName','c (PI)');
plot(t_sec, c_PID_s*100, 'g-.', 'LineWidth',2, 'DisplayName','c (PID)');
yline(100,'k:','LineWidth',1,'HandleVisibility','off');
yline(0,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [s]'); ylabel('Comanda [%]');
title('Semnalele de comanda'); legend; xlim([0 600]);
%% =========================================================
%% GRAFIC ZOOM: Raspuns la prima treapta (0->100 L/h)
%% =========================================================
figure(3);
idx_zoom = t_sec <= 80;
plot(t_sec(idx_zoom), y_P_lh(idx_zoom),   'b-',  'LineWidth',2,'DisplayName','P');
hold on;
plot(t_sec(idx_zoom), y_PI_lh(idx_zoom),  'r--', 'LineWidth',2,'DisplayName','PI');
plot(t_sec(idx_zoom), y_PID_lh(idx_zoom), 'g-.', 'LineWidth',2,'DisplayName','PID');
plot(t_sec(idx_zoom), w_lh(idx_zoom),     'k:',  'LineWidth',1.5,'DisplayName','Referinta');
yline(97,'m:','LineWidth',0.8,'HandleVisibility','off');
yline(103,'m:','LineWidth',0.8,'HandleVisibility','off');
grid on; xlabel('Timp [s]'); ylabel('Debit [L/h]');
title('Zoom - Raspuns la prima treapta (0->100 L/h)');
legend('Location','southeast');
%% =========================================================
%% TABEL CENTRALIZATOR COMPLET
%% =========================================================
fprintf('\n=== TABEL CENTRALIZATOR COMPLET ===\n');
fprintf('Identificare proces:\n');
fprintf('  H(s) = %.4f / (1+%.3fs)  [K=%.4f (L/h)/%%, T=%.3fs]\n', K_proc, T_dom, K_proc, T_dom);
fprintf('  Timp mort estimat: Tm=%.3fs\n\n', Tm_id);
fprintf('%-8s %10s %12s %10s %20s\n','Reg.','a_stp','sigma[%]','tr[s]','[cmin;cmax]');
fprintf('%s\n',repmat('-',1,62));
fprintf('%-8s %10.4f %12.2f %10.3f   [%.3f; %.3f]\n','P',  a_P,  sig_P,  tr_P,  cmin_P,  cmax_P);
fprintf('%-8s %10.4f %12.2f %10.3f   [%.3f; %.3f]\n','PI', a_PI, sig_PI, tr_PI, cmin_PI, cmax_PI);
fprintf('%-8s %10.4f %12.2f %10.3f   [%.3f; %.3f]\n','PID',a_PID,sig_PID,tr_PID,cmin_PID,cmax_PID);
fprintf('\nConcluzie:\n');
fprintf('  - P: a_stp ≠ 0 (abatere stationara la pozitie)\n');
fprintf('  - PI/PID: a_stp = 0 (component integrativ)\n');
fprintf('  - PID: timp raspuns mai mic decat PI, dar domeniu comanda mai mare\n');

%% =========================================================
%% HELPER: calcul performante (MUTAT LA FINALUL FISIERULUI)
%% =========================================================
function [sigma, tr, astp, cmin, cmax] = perf(y, t, c, band_pct)
    yst = y(end); ymax = max(y);
    if yst > 0.001
        sigma = (ymax-yst)/yst*100; astp = 1-yst;
    else
        sigma = 0; astp = 1;
    end
    band = band_pct/100 * max(yst,0.001);
    in_b = abs(y-yst) <= band;
    oi   = find(~in_b,1,'last');
    if isempty(oi); tr=0; else; tr=t(oi); end
    cmin = min(c); cmax = max(c);
end