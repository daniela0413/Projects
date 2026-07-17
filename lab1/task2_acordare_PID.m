%% LABORATOR NR. 1 - Sarcina 2
%% Acordarea regulatoarelor PID prin criteriul modulului si simetriei
%% Verificare performante prin simulare (fara Simulink - folosim Control Toolbox)



%% =========================================================
%% FUNCTIILE DE TRANSFER ALE PARTII FIXATE (din laborator, sectiunea 1.4)
%% =========================================================
% Procesul tehnologic (IT) - ordinul I cu 2 constante de timp (rapid)
% H_IT(s) = 2 / ((1+0.1s)(1+6s))   (ec. 1.22 - forma simplificata)
% H_EE(s) = 5 / (1+0.2s)
% H_TM(s) = 0.01 / (1+0.1s)

% Functia de transfer a partii fixate (ec. 1.22)
% H_F(s) = K_P / ((1+Ty*s)*(1+T*s))
% K_P = 0.1, Ty = 0.4s, T = 6s
K_P  = 0.1;
Ty   = 0.4;   % suma constantelor mici de timp
T    = 6;     % constanta dominanta

s = tf('s');
H_F = K_P / ((1 + Ty*s)*(1 + T*s));
fprintf('Functia de transfer a partii fixate:\n');
fprintf('H_F(s) = %.3f / ((1+%.2fs)*(1+%.2fs))\n\n', K_P, Ty, T);

%% =========================================================
%% a) CRITERIUL MODULULUI - Varianta Kessler (ec. 1.23, 1.24)
%% =========================================================
fprintf('--- a) CRITERIUL MODULULUI (Kessler) ---\n');

% H_d_a(s) = 1 / (2*Ty*s*(1+Ty*s))  - functia impusa calea directa
% H_R_a(s) = H_d_a(s) / H_F(s)      - regulatorul (ec. 1.23)
%
% Din ec. 1.24:
% H_R_modul(s) = K_R*(1 + 1/(T_I*s))  => Regulator PI
% K_R = T / (2*K_P*Ty)
% T_I = T

K_R_modul = T / (2 * K_P * Ty);
T_I_modul = T;
fprintf('Regulator PI (criteriul modulului):\n');
fprintf('  K_R = T/(2*K_P*Ty) = %.2f / (2*%.3f*%.2f) = %.4f\n', T, K_P, Ty, K_R_modul);
fprintf('  T_I = T = %.2f s\n', T_I_modul);

% Functia de transfer regulatorul PI (criteriul modulului)
H_R_modul = K_R_modul * (1 + 1/(T_I_modul * s));
fprintf('  H_R_modul(s) = %.4f*(1 + 1/(%.2fs))\n\n', K_R_modul, T_I_modul);

% Sistem in bucla inchisa cu regulator modul
H_OL_modul  = H_R_modul * H_F;   % bucla deschisa
H_CL_modul  = feedback(H_OL_modul, 1);

% Raspuns indicial (semnal de referinta tip treapta)
t_sim = 0:0.1:100;
[y_step_modul, t_out] = step(H_CL_modul, t_sim);

% Calculul performantelor
yst_modul = y_step_modul(end);
ymax_modul = max(y_step_modul);
sigma_modul = (ymax_modul - yst_modul) / yst_modul * 100;

% Timp de raspuns: intrare in banda ±5% din yst
band = 0.05;
in_band = abs(y_step_modul - yst_modul) <= band * yst_modul;
% Ultimul moment cand iese din banda
out_idx = find(~in_band, 1, 'last');
if isempty(out_idx)
    tr_modul = t_out(1);
else
    tr_modul = t_out(out_idx);
end

% Abatere stationara la pozitie (treapa unitara w=1, y(inf))
a_stp_modul = 1 - yst_modul;

fprintf('Performante criteriul modulului (treapta):\n');
fprintf('  Suprareglaj sigma = %.2f %%\n', sigma_modul);
fprintf('  Timp raspuns tr = %.2f s\n', tr_modul);
fprintf('  Abatere stationara la pozitie a_stp = %.4f\n', a_stp_modul);

%% =========================================================
%% b) CRITERIUL SIMETRIEI (ec. 1.25, 1.26, 1.27)
%% =========================================================
fprintf('\n--- b) CRITERIUL SIMETRIEI ---\n');

% H_d_b(s) = (1+4*Ty*s) / (8*Ty^2*s^2*(1+Ty*s))  - functia impusa
% H_R_simetrie(s) = H_d_b(s) / H_F(s)
%
% Din ec. 1.27 (forma PID serie cu integrator):
% K_R = (1+4*Ty*s)*(1+T*s) / (8*K_P*Ty^2*s^2)
% Parametri PID (din ec. 1.27):
% K_R_sim = (T*(1+4*Ty)) / (8*K_P*Ty^2)  -- aproximatie pentru s mic
%
% Din relatia (1.26)/(1.27):
K_R_sim = (1 + 4*Ty*1) * T / (8 * K_P * Ty^2);  % aproximare simbolica
% Forma corecta din ec. 1.27:
% H_R(s) = (1+7.6s+9.6s^2)/(0.128s^2) = 59.375*(1 + 1/(7.6s) + 1.263s)/s
% Valorile din lucrare pentru exemplul numeric:
K_R_sim_num   = 59.375;
T_I_sim_num   = 7.6;
T_D_sim_num   = 1.263;
fprintf('Regulator PID (criteriul simetriei) - valori din exemplul din lucrare:\n');
fprintf('  K_R = %.4f\n', K_R_sim_num);
fprintf("  T_I = %.4f s\n", T_I_sim_num);
fprintf('  T_D = %.4f s\n', T_D_sim_num);

% Regulator PID ideal (ec. 1.6):
% H_R_PID(s) = K_R*(1 + 1/(T_I*s) + T_D*s)
H_R_sim = K_R_sim_num * (1 + 1/(T_I_sim_num * s) + T_D_sim_num * s);

% Sistem in bucla inchisa cu regulator simetrie
H_OL_sim  = H_R_sim * H_F;
H_CL_sim  = feedback(H_OL_sim, 1);

% Raspuns indicial
[y_step_sim, t_out_sim] = step(H_CL_sim, t_sim);

yst_sim  = y_step_sim(end);
ymax_sim = max(y_step_sim);
sigma_sim = (ymax_sim - yst_sim) / yst_sim * 100;

in_band_sim = abs(y_step_sim - yst_sim) <= 0.05 * yst_sim;
out_idx_sim = find(~in_band_sim, 1, 'last');
if isempty(out_idx_sim)
    tr_sim = t_out_sim(1);
else
    tr_sim = t_out_sim(out_idx_sim);
end
a_stp_sim = 1 - yst_sim;

fprintf('\nPerformante criteriul simetriei (treapta):\n');
fprintf('  Suprareglaj sigma = %.2f %%\n', sigma_sim);
fprintf('  Timp raspuns tr = %.2f s\n', tr_sim);
fprintf('  Abatere stationara la pozitie a_stp = %.6f\n', a_stp_sim);

%% =========================================================
%% CRITERIUL SIMETRIEI - Raspuns la RAMPA (abatere stationara la viteza)
%% =========================================================
fprintf('\n--- Criteriul simetriei - Semnal de referinta tip rampa ---\n');

% Semnal rampa: w(t) = t, W(s) = 1/s^2
% Eroarea in stare stationara la viteza: e_ss = lim s->0 [s * E(s)]
% E(s) = W(s) - Y(s) = W(s)*(1/(1+H_OL(s)))
% e_ss_viteza = lim s->0 [s * (1/s^2) * (1/(1+H_OL(s)))]
% Daca H_OL contine un integrator (regulator PI/PID), e_ss_viteza poate fi nula

% Verificare prin simulare cu rampa
t_ramp = 0:0.1:200;
w_ramp = t_ramp;  % rampa unitara

% Simulare sistem criteriul modulului cu rampa
% Folosim lsim
[y_ramp_modul, ~] = lsim(H_CL_modul, w_ramp, t_ramp);
e_ramp_modul = w_ramp - y_ramp_modul';
fprintf('Criteriul modulului (PI) - eroare la rampa in stare stationara (aprox): %.4f\n', e_ramp_modul(end));

[y_ramp_sim, ~] = lsim(H_CL_sim, w_ramp, t_ramp);
e_ramp_sim = w_ramp - y_ramp_sim';
fprintf('Criteriul simetriei (PID) - eroare la rampa in stare stationara (aprox): %.4f\n', e_ramp_sim(end));

%% =========================================================
%% PLOT - Comparatie performante
%% =========================================================

% Plot 1: Raspuns la treapta - comparatie
figure(4);
subplot(2,1,1);
plot(t_sim, y_step_modul, 'b-', 'LineWidth', 2, 'DisplayName', ...
    sprintf('Criteriul modulului (PI): \\sigma=%.1f%%, t_r=%.1fs', sigma_modul, tr_modul));
hold on;
plot(t_sim, y_step_sim, 'r--', 'LineWidth', 2, 'DisplayName', ...
    sprintf('Criteriul simetriei (PID): \\sigma=%.1f%%, t_r=%.1fs', sigma_sim, tr_sim));
yline(1, 'k:', 'LineWidth', 1, 'DisplayName', 'Referinta w=1');
yline(1.05, 'g:', 'LineWidth', 0.8, 'HandleVisibility', 'off');
yline(0.95, 'g:', 'LineWidth', 0.8, 'HandleVisibility', 'off');
grid on;
xlabel('Timp [s]'); ylabel('y');
title('Raspuns la treapta - Comparatie criterii de acordare');
legend('Location', 'northeast');
xlim([0 100]);

% Plot 2: Raspuns la rampa - comparatie
subplot(2,1,2);
t_ramp_short = 0:0.1:80;
w_ramp_short = t_ramp_short;
[y_rm, ~] = lsim(H_CL_modul, w_ramp_short, t_ramp_short);
[y_rs, ~] = lsim(H_CL_sim,   w_ramp_short, t_ramp_short);
plot(t_ramp_short, w_ramp_short, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Referinta (rampa)');
hold on;
plot(t_ramp_short, y_rm, 'b-', 'LineWidth', 2, 'DisplayName', 'Criteriul modulului (PI)');
plot(t_ramp_short, y_rs, 'r--', 'LineWidth', 2, 'DisplayName', 'Criteriul simetriei (PID)');
grid on;
xlabel('Timp [s]'); ylabel('y, w');
title('Raspuns la rampa - Comparatie criterii de acordare');
legend('Location', 'northwest');
xlim([0 80]);

%% =========================================================
%% SUMAR FINAL
%% =========================================================
fprintf('\n========== SUMAR SARCINA 2 ==========\n');
fprintf('Functia de transfer parte fixata:\n');
fprintf('  H_F(s) = %.3f / ((1+%.2fs)*(1+%.2fs))\n', K_P, Ty, T);
fprintf('\nCriteriul modulului -> Regulator PI:\n');
fprintf('  K_R = %.4f,  T_I = %.4f s\n', K_R_modul, T_I_modul);
fprintf('  Sigma = %.2f%%,  tr = %.2f s,  a_stp = %.4f\n', sigma_modul, tr_modul, a_stp_modul);
fprintf('\nCriteriul simetriei -> Regulator PID:\n');
fprintf('  K_R = %.4f,  T_I = %.4f s,  T_D = %.4f s\n', K_R_sim_num, T_I_sim_num, T_D_sim_num);
fprintf('  Sigma = %.2f%%,  tr = %.2f s,  a_stp = %.6f\n', sigma_sim, tr_sim, a_stp_sim);
