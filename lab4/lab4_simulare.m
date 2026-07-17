%% LABORATOR NR. 4 - Simulare sisteme de reglare
%% Comparatie schema monocontur vs schema feedforward (fig. 4.2/4.3)
%% cu diferite tipuri de perturbatii (treapta, rampa, sinusoidala)


if ~exist('lab4_params.mat','file')
    error('Rulati mai intai lab4_identificare.m!');
end
load('lab4_params.mat');
s = tf('s');

%% =========================================================
%% FUNCTII DE TRANSFER
%% =========================================================
% Procesul (IT)
H_IT  = tf(K_IT,  [T    1]);
% Elementul de executie (EE)
H_EE  = tf(1,     [T_EE 1]);
% Traductorul masura nivel (TM1)
H_TM1 = tf(1,     [T_TM1 1]);
% Traductorul masura perturbatie (TM2)
H_TM2 = tf(1,     [T_TM2 1]);

% Parte fixata
H_f = H_EE * H_IT * H_TM1;
fprintf('H_f(s) verificare: K=%.4f\n\n', dcgain(H_f));

% Regulator PI principal (R1) - criteriul modulului
H_R1 = K_R_modul * (1 + 1/(T_I_modul * s));
fprintf('Regulator PI (R1):\n');
fprintf('  K_R = %.4f, T_I = %.3f s\n\n', K_R_modul, T_I_modul);

% Bloc de compensare realizabil (H_BC) - forma cu filtrare (ec. 4.15)
num_BC_real = conv(conv([T 1], [T_EE 1]), [T_TM2 1]);
den_BC_real = K_IT * conv(conv([Tf 1], [Tf 1]), [Tf 1]);
H_BC_real   = tf(num_BC_real, den_BC_real);

% Forma simplificata a compensatorului (ec. 4.16)
num_BC_simpl = conv([T 1], [T_EE 1]);
den_BC_simpl = K_IT * conv([Tf 1], [Tf 1]);
H_BC_simpl   = tf(num_BC_simpl, den_BC_simpl);

% Forma proportionala
H_BC_prop = tf(K_BC_prop, 1);

fprintf('Bloc compensare realizabil: grad num=%d, grad den=%d\n', ...
    length(num_BC_real)-1, length(den_BC_real)-1);
fprintf('Bloc compensare simplificat: grad num=%d, grad den=%d\n\n', ...
    length(num_BC_simpl)-1, length(den_BC_simpl)-1);

%% =========================================================
%% SISTEME IN BUCLA INCHISA
%% =========================================================
% 1. Schema MONOCONTUR (fig. 4.8 echivalent)
H_OL_mono    = H_R1 * H_f;
H_CL_ref_mono = feedback(H_OL_mono, 1);       
H_CL_pert_mono = feedback(H_IT, H_R1*H_EE*H_TM1); 

% 2. Schema FEEDFORWARD (fig. 4.2 / 4.3 - varianta 1)
H_pert_ff_real  = feedback(H_IT - H_EE * H_BC_real  * H_TM2, H_R1*H_EE*H_TM1);
H_pert_ff_simpl = feedback(H_IT - H_EE * H_BC_simpl * H_TM2, H_R1*H_EE*H_TM1);
H_pert_ff_prop  = feedback(H_IT - H_EE * H_BC_prop  * H_TM2, H_R1*H_EE*H_TM1);

% Raspuns la referinta identic pentru toate
H_CL_ref_ff = H_CL_ref_mono;
t_sim = 0:0.1:80;

%% =========================================================
%% PERTURBATIE TREAPTA (p = 1 la t=0)
%% =========================================================
fprintf('=== PERTURBATIE TREAPTA ===\n');
[y_mono_tr,  t_out] = step(H_CL_pert_mono,   t_sim);
[y_ff_real,  ~]     = step(H_pert_ff_real,   t_sim);
[y_ff_simpl, ~]     = step(H_pert_ff_simpl,  t_sim);
[y_ff_prop,  ~]     = step(H_pert_ff_prop,   t_sim);

% Performante treapta folosind functia mutata la final
[a_mono, ym_mono]   = pert_perf(y_mono_tr);
[a_ff_r, ym_ff_r]   = pert_perf(y_ff_real);
[a_ff_s, ym_ff_s]   = pert_perf(y_ff_simpl);
[a_ff_p, ym_ff_p]   = pert_perf(y_ff_prop);

fprintf('%-35s a_stp=%7.4f  |y|max=%7.4f\n', 'Monocontur:',              a_mono,  ym_mono);
fprintf('%-35s a_stp=%7.4f  |y|max=%7.4f\n', 'Feedforward real:',        a_ff_r,  ym_ff_r);
fprintf('%-35s a_stp=%7.4f  |y|max=%7.4f\n', 'Feedforward simplificat:', a_ff_s,  ym_ff_s);
fprintf('%-35s a_stp=%7.4f  |y|max=%7.4f\n', 'Feedforward proportional:',a_ff_p,  ym_ff_p);

figure(3);
plot(t_out, y_mono_tr,  'b-',  'LineWidth',2, 'DisplayName','Monocontur');
hold on;
plot(t_out, y_ff_real,  'r-',  'LineWidth',2, 'DisplayName','Feedforward (realizabil)');
plot(t_out, y_ff_simpl, 'g--', 'LineWidth',2, 'DisplayName','Feedforward (simplificat)');
plot(t_out, y_ff_prop,  'm:',  'LineWidth',2, 'DisplayName','Feedforward (proportional)');
yline(0,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [s]'); ylabel('\Delta y [cm]');
title('Perturbatie treapta (p=1) - Comparatie monocontur vs feedforward');
legend('Location','northeast'); xlim([0 80]);

%% =========================================================
%% PERTURBATIE RAMPA (p = t, pornita la t=30s)
%% =========================================================
fprintf('\n=== PERTURBATIE RAMPA ===\n');
t_rampa = 0:0.1:150;
t_pert_start = 30;

% Rampa: p(t) = max(0, t - t_start)
p_rampa = max(0, t_rampa - t_pert_start);
[y_mono_r,  ~] = lsim(H_CL_pert_mono,  p_rampa, t_rampa);
[y_ff_r_r,  ~] = lsim(H_pert_ff_real,  p_rampa, t_rampa);
[y_ff_s_r,  ~] = lsim(H_pert_ff_simpl, p_rampa, t_rampa);

fprintf('Monocontur - abatere stationara rampa (la t=150s): %.4f\n', y_mono_r(end));
fprintf('Feedforward real - abatere stationara rampa: %.4f\n', y_ff_r_r(end));

figure(4);
subplot(2,1,1);
plot(t_rampa, p_rampa, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Perturbatie p (rampa)');
grid on; ylabel('p'); title('Perturbatie de tip rampa (pornire t=30s)');
legend; xlim([0 150]);

subplot(2,1,2);
plot(t_rampa, y_mono_r,  'b-',  'LineWidth',2, 'DisplayName','Monocontur');
hold on;
plot(t_rampa, y_ff_r_r,  'r-',  'LineWidth',2, 'DisplayName','Feedforward (realizabil)');
plot(t_rampa, y_ff_s_r,  'g--', 'LineWidth',2, 'DisplayName','Feedforward (simplificat)');
yline(0,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [s]'); ylabel('\Delta y [cm]');
title('Raspuns la perturbatie rampa - Monocontur vs Feedforward');
legend('Location','northwest'); xlim([0 150]);

%% =========================================================
%% PERTURBATIE SINUSOIDALA (A=1, omega=0.05 rad/s)
%% =========================================================
fprintf('\n=== PERTURBATIE SINUSOIDALA ===\n');
t_sin = 0:0.1:300;
A_sin = 1;  omega_sin = 0.05;   % rad/s
p_sin = A_sin * sin(omega_sin * t_sin);

[y_mono_s,  ~] = lsim(H_CL_pert_mono,  p_sin, t_sin);
[y_ff_r_s,  ~] = lsim(H_pert_ff_real,  p_sin, t_sin);
[y_ff_s_s,  ~] = lsim(H_pert_ff_simpl, p_sin, t_sin);

% Amplitudine in regim stationar (ultimele 2 perioade)
T_sin = 2*pi/omega_sin;
last2T = t_sin >= (t_sin(end) - 2*T_sin);
A_mono_ss  = (max(y_mono_s(last2T)) - min(y_mono_s(last2T)))/2;
A_ff_r_ss  = (max(y_ff_r_s(last2T)) - min(y_ff_r_s(last2T)))/2;
A_ff_s_ss  = (max(y_ff_s_s(last2T)) - min(y_ff_s_s(last2T)))/2;

fprintf('Amplitudine raspuns sinusoidal (reg. stationar):\n');
fprintf('  Monocontur:              A = %.4f (atenuare: %.1fx)\n', A_mono_ss, A_sin/max(A_mono_ss,1e-6));
fprintf('  Feedforward realizabil:  A = %.4f (atenuare: %.1fx)\n', A_ff_r_ss,  A_sin/max(A_ff_r_ss,1e-6));
fprintf('  Feedforward simplificat: A = %.4f\n', A_ff_s_ss);

figure(5);
plot(t_sin, y_mono_s,  'b-',  'LineWidth',2, 'DisplayName', ...
    sprintf('Monocontur (A_{ss}=%.3f)', A_mono_ss));
hold on;
plot(t_sin, y_ff_r_s,  'r-',  'LineWidth',2, 'DisplayName', ...
    sprintf('Feedforward real (A_{ss}=%.3f)', A_ff_r_ss));
plot(t_sin, y_ff_s_s,  'g--', 'LineWidth',2, 'DisplayName', ...
    sprintf('Feedforward simplif. (A_{ss}=%.3f)', A_ff_s_ss));
yline(0,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [s]'); ylabel('\Delta y [cm]');
title(sprintf('Perturbatie sinusoidala (A=%.0f, \\omega=%.3f rad/s)\nMonocontur vs Feedforward', A_sin, omega_sin));
legend('Location','northeast'); xlim([0 300]);

%% =========================================================
%% RASPUNS LA REFERINTA (treapta w=1, p=0)
%% =========================================================
fprintf('\n=== RASPUNS LA REFERINTA (p=0) ===\n');
t_ref = 0:0.1:60;
[y_ref, t_ref_out] = step(H_CL_ref_mono, t_ref);
yst_ref = y_ref(end);
ymax_ref = max(y_ref);
sigma = (ymax_ref - yst_ref)/yst_ref * 100;
in_band = abs(y_ref - yst_ref) <= 0.03*yst_ref;
tr_idx = find(~in_band, 1, 'last');
tr = t_ref_out(tr_idx);
astp = 1 - yst_ref;

fprintf('Suprareglaj sigma = %.2f%%\n', sigma);
fprintf('Timp raspuns tr = %.2f s\n', tr);
fprintf('Abatere stationara a_stp = %.5f\n', astp);

figure(6);
plot(t_ref_out, y_ref, 'b-', 'LineWidth', 2, 'DisplayName', ...
    sprintf('PI (K_R=%.4f, T_I=%.3fs)', K_R_modul, T_I_modul));
hold on;
yline(1,'k:','LineWidth',1,'HandleVisibility','off');
yline(1.03,'g:','LineWidth',0.8,'HandleVisibility','off');
yline(0.97,'g:','LineWidth',0.8,'HandleVisibility','off');
grid on; xlabel('Timp [s]'); ylabel('y [u.r.]');
title(sprintf('Raspuns la referinta treapta (p=0)\n\\sigma=%.2f%%, t_r=%.2fs, a_{stp}=%.5f', sigma, tr, astp));
legend('Location','southeast'); xlim([0 60]);

%% =========================================================
%% TABEL CENTRALIZATOR PERFORMANTE
%% =========================================================
fprintf('\n=== TABEL CENTRALIZATOR (Tabel 4.1) ===\n');
fprintf('%-40s %10s %10s %10s %10s\n', 'Cazul tratat', 'a_stp', 'sigma[%]', 'tr[s]', '|y|_max');
fprintf('%s\n', repmat('-',1,75));
fprintf('%-40s %10.4f %10s %10.2f %10s\n', 'Monocontur - referinta treapta', astp, '-', tr, '-');
fprintf('%-40s %10.4f %10.2f %10s %10.4f\n', 'Monocontur - perturbatie treapta', a_mono, 0, '-', ym_mono);
fprintf('%-40s %10.4f %10s %10s %10.4f\n', 'Feedforward real - pert. treapta', a_ff_r, '-', '-', ym_ff_r);
fprintf('%-40s %10.4f %10s %10s %10.4f\n', 'Feedforward simplif. - pert. treapta', a_ff_s, '-', '-', ym_ff_s);
fprintf('%-40s %10.4f %10s %10s %10.4f\n', 'Feedforward prop. - pert. treapta', a_ff_p, '-', '-', ym_ff_p);
fprintf('Sinus - Monocontur: A_ss=%.4f  |  Feedforward real: A_ss=%.4f\n', A_mono_ss, A_ff_r_ss);

%% =========================================================
%% FUNCTII LOCALE (Trebuie sa fie strict la finalul scriptului)
%% =========================================================
function [astp, ymax] = pert_perf(y)
    astp = y(end);
    ymax = max(abs(y));
end