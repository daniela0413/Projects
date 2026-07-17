%% LABORATOR NR. 5 - Simulare sisteme de reglare in cascada
%% Comparatie schema monocontur vs schema in cascada
%% Perturbatii: treapta, rampa, sinusoidala (p2 pe bucla interioara)
%% Criterii: modulului si simetriei pentru R2
clear; clc; close all;

if ~exist('lab5_params.mat','file')
    error('Rulati mai intai lab5_identificare.m!');
end
load('lab5_params.mat');
s = tf('s');

%% =========================================================
%% FUNCTII DE TRANSFER
%% =========================================================
H_IT1  = tf(K_IT1,  [T1    1]);   % subproces lent  (debit -> presiune)
H_IT2  = tf(K_IT2,  [T2    1]);   % subproces rapid (pompa -> debit)
H_EE   = tf(K_EE,   [T_EE  1]);   % element executie
H_TM1  = tf(K_TM1,  [T_TM1 1]);   % traductor masura presiune
H_TM2  = tf(K_TM2,  [T_TM2 1]);   % traductor masura variabila intermediara

% Proces global
H_IT = H_IT1 * H_IT2;

%% =========================================================
%% REGULATOARE
%% =========================================================
% R2 - criteriul modulului
H_R2_mod = K_R2 * (1 + 1/(T_I2 * s));
% R2 - criteriul simetriei
H_R2_sim = K_R2_sim * (1 + 1/(T_I2_sim * s));
% R1 - criteriul modulului
H_R1_mod = K_R1 * (1 + 1/(T_I1 * s));
% Regulator monocontur
H_R_mono = K_R_mono * (1 + 1/(T_I_mono * s));

fprintf('Regulatoare:\n');
fprintf('  R2 modul:  K=%.4f, Ti=%.3fs\n', K_R2, T_I2);
fprintf('  R2 simetr: K=%.4f, Ti=%.3fs\n', K_R2_sim, T_I2_sim);
fprintf('  R1 modul:  K=%.4f, Ti=%.3fs\n', K_R1, T_I1);
fprintf('  Monocontur:K=%.4f, Ti=%.3fs\n\n', K_R_mono, T_I_mono);

%% =========================================================
%% SISTEME IN BUCLA INCHISA
%% =========================================================
% --- BUCLA INTERIOARA (R2 + IT2 + EE + TM2) ---
H_OL_int_mod = H_R2_mod * H_EE * H_IT2 * H_TM2;
H_OL_int_sim = H_R2_sim * H_EE * H_IT2 * H_TM2;

% Bucla interioara inchisa (referinta c1 -> y2)
H_CL_int_mod = feedback(H_OL_int_mod, 1);  % R2 modul
H_CL_int_sim = feedback(H_OL_int_sim, 1);  % R2 simetrie

% Raspuns bucla interioara la perturbatie p2 (pe iesirea IT2)
H_pert_int_mod = feedback(H_IT2, H_R2_mod * H_EE * H_TM2);
H_pert_int_sim = feedback(H_IT2, H_R2_sim * H_EE * H_TM2);

% --- BUCLA EXTERIOARA (R1 + EECH + IT1 + TM1) ---
% EECH = H_CL_int (bucla interioara echivalenta)
H_f1_eq_mod = H_CL_int_mod * H_IT1 * H_TM1;
H_f1_eq_sim = H_CL_int_sim * H_IT1 * H_TM1;
H_OL_ext_mod = H_R1_mod * H_f1_eq_mod;
H_OL_ext_sim = H_R1_mod * H_f1_eq_sim;

% Bucla exterioara inchisa (referinta w -> y)
H_CL_casc_mod = feedback(H_OL_ext_mod, 1);   % cascada cu R2 modul
H_CL_casc_sim = feedback(H_OL_ext_sim, 1);   % cascada cu R2 simetrie

% Raspuns cascada la perturbatie p2 (actioneaza pe y2)
H_pert_casc_mod = feedback(H_IT1 * H_pert_int_mod, H_R1_mod * H_CL_int_mod * H_IT1 * H_TM1);
H_pert_casc_sim = feedback(H_IT1 * H_pert_int_sim, H_R1_mod * H_CL_int_sim * H_IT1 * H_TM1);

% --- MONOCONTUR ---
H_OL_mono   = H_R_mono * H_EE * H_IT * H_TM1;
H_CL_mono   = feedback(H_OL_mono, 1);

% Raspuns monocontur la perturbatie p2
H_pert_mono2 = feedback(H_IT, H_R_mono * H_EE * H_TM1);
t_sim = 0:0.1:300;

%% =========================================================
%% 1. RASPUNS LA REFERINTA (treapta w=1, p2=0)
%% =========================================================
fprintf('=== RASPUNS LA REFERINTA (p2=0) ===\n');
[y_ref_mono,    t_out] = step(H_CL_mono,     t_sim);
[y_ref_casc_mod, ~]    = step(H_CL_casc_mod, t_sim);
[y_ref_casc_sim, ~]    = step(H_CL_casc_sim, t_sim);

% Calcul performante folosind functia mutata la final
[sig_mono,    tr_mono,    a_mono]    = calc_perf(y_ref_mono,     t_out);
[sig_casc_mod,tr_casc_mod,a_casc_mod]= calc_perf(y_ref_casc_mod, t_out);
[sig_casc_sim,tr_casc_sim,a_casc_sim]= calc_perf(y_ref_casc_sim, t_out);

fprintf('%-30s sigma=%6.2f%%  tr=%7.2fs  astp=%.5f\n','Monocontur:',         sig_mono,    tr_mono,    a_mono);
fprintf('%-30s sigma=%6.2f%%  tr=%7.2fs  astp=%.5f\n','Cascada (R2 modul):',  sig_casc_mod,tr_casc_mod,a_casc_mod);
fprintf('%-30s sigma=%6.2f%%  tr=%7.2fs  astp=%.5f\n','Cascada (R2 simetrie):',sig_casc_sim,tr_casc_sim,a_casc_sim);

figure(1);
plot(t_out, y_ref_mono,     'b--', 'LineWidth',2, 'DisplayName', ...
    sprintf('Monocontur (\\sigma=%.1f%%, t_r=%.0fs)', sig_mono, tr_mono));
hold on;
plot(t_out, y_ref_casc_mod, 'r-',  'LineWidth',2, 'DisplayName', ...
    sprintf('Cascada R2-modul (\\sigma=%.1f%%, t_r=%.0fs)', sig_casc_mod, tr_casc_mod));
plot(t_out, y_ref_casc_sim, 'g-.', 'LineWidth',2, 'DisplayName', ...
    sprintf('Cascada R2-simetrie (\\sigma=%.1f%%, t_r=%.0fs)', sig_casc_sim, tr_casc_sim));
yline(1,'k:','LineWidth',1,'HandleVisibility','off');
yline(1.03,'g:','LineWidth',0.8,'HandleVisibility','off');
yline(0.97,'g:','LineWidth',0.8,'HandleVisibility','off');
grid on; xlabel('Timp [s]'); ylabel('y [u.r.]');
title('Fig. 5.6 echiv. - Raspuns la referinta treapta (p_2=0)');
legend('Location','southeast'); xlim([0 300]);

%% =========================================================
%% 2. PERTURBATIE TREAPTA p2=1 la t=80s (fig. 5.6)
%% =========================================================
fprintf('\n=== PERTURBATIE TREAPTA p2=1 (pornire t=80s) ===\n');
t_sim2 = 0:0.1:400;
t_pert = 80;

[y_ref_m,  ~]    = step(H_CL_mono,     t_sim2);
[y_ref_cm, ~]    = step(H_CL_casc_mod, t_sim2);
[y_ref_cs, ~]    = step(H_CL_casc_sim, t_sim2);

% Perturbatie treapta (delay 80s)
t_delay_idx = round(t_pert / 0.1) + 1;
p2_step = zeros(size(t_sim2)); p2_step(t_delay_idx:end) = 1;

[y_p2_mono,    ~] = lsim(H_pert_mono2,    p2_step, t_sim2);
[y_p2_casc_mod,~] = lsim(H_pert_casc_mod, p2_step, t_sim2);
[y_p2_casc_sim,~] = lsim(H_pert_casc_sim, p2_step, t_sim2);

y_tot_mono    = y_ref_m  + y_p2_mono;
y_tot_casc_mod= y_ref_cm + y_p2_casc_mod;
y_tot_casc_sim= y_ref_cs + y_p2_casc_sim;

% Performante post-perturbatie
a_p_mono    = y_tot_mono(end)    - 1;
a_p_casc_mod= y_tot_casc_mod(end)- 1;
a_p_casc_sim= y_tot_casc_sim(end)- 1;

fprintf('Abatere stationara dupa perturbatie:\n');
fprintf('  Monocontur:          a_stp = %.5f\n', a_p_mono);
fprintf('  Cascada (R2 modul):  a_stp = %.5f\n', a_p_casc_mod);
fprintf('  Cascada (R2 simetrie): a_stp = %.5f\n', a_p_casc_sim);

figure(2);
plot(t_sim2, y_tot_mono,     'b--', 'LineWidth',2, 'DisplayName', 'Monocontur');
hold on;
plot(t_sim2, y_tot_casc_mod, 'r-',  'LineWidth',2, 'DisplayName', 'Cascada (R2 modul)');
plot(t_sim2, y_tot_casc_sim, 'g-.', 'LineWidth',2, 'DisplayName', 'Cascada (R2 simetrie)');
yline(1,'k:','LineWidth',1,'HandleVisibility','off');
yline(1.03,'g:','LineWidth',0.8,'HandleVisibility','off');
yline(0.97,'g:','LineWidth',0.8,'HandleVisibility','off');
xline(t_pert,'m:','LineWidth',1,'HandleVisibility','off');
text(t_pert+2, 0.2, 'p_2 apare', 'Color','m');
grid on; xlabel('Timp [s]'); ylabel('y [u.r.]');
title('Fig. 5.6 echiv. - Raspuns la referinta + perturbatie treapta p_2 (t=80s)');
legend('Location','northeast'); xlim([0 400]);

%% =========================================================
%% 3. PERTURBATIE RAMPA p2=0.1*t (pornire t=80s) (fig. 5.8)
%% =========================================================
fprintf('\n=== PERTURBATIE RAMPA p2=0.1*t (pornire t=80s) ===\n');
p2_rampa = zeros(size(t_sim2));
idx_r = t_delay_idx:length(t_sim2);
p2_rampa(idx_r) = 0.1 * (t_sim2(idx_r) - t_pert);

[y_pr_mono,    ~] = lsim(H_pert_mono2,    p2_rampa, t_sim2);
[y_pr_casc_mod,~] = lsim(H_pert_casc_mod, p2_rampa, t_sim2);
[y_pr_casc_sim,~] = lsim(H_pert_casc_sim, p2_rampa, t_sim2);

y_r_mono    = y_ref_m  + y_pr_mono;
y_r_casc_mod= y_ref_cm + y_pr_casc_mod;
y_r_casc_sim= y_ref_cs + y_pr_casc_sim;

a_r_mono    = y_r_mono(end)    - 1;
a_r_casc_mod= y_r_casc_mod(end)- 1;
a_r_casc_sim= y_r_casc_sim(end)- 1;

fprintf('Abatere stationara la rampa (t=%.0fs):\n', t_sim2(end));
fprintf('  Monocontur:            a_stp = %.4f\n', a_r_mono);
fprintf('  Cascada (R2 modul):    a_stp = %.4f\n', a_r_casc_mod);
fprintf('  Cascada (R2 simetrie): a_stp = %.4f\n', a_r_casc_sim);

figure(3);
plot(t_sim2, y_r_mono,     'b--', 'LineWidth',2, 'DisplayName', ...
    sprintf('Monocontur (a_{stp}=%.2f)', a_r_mono));
hold on;
plot(t_sim2, y_r_casc_mod, 'r-',  'LineWidth',2, 'DisplayName', ...
    sprintf('Cascada R2-modul (a_{stp}=%.4f)', a_r_casc_mod));
plot(t_sim2, y_r_casc_sim, 'g-.', 'LineWidth',2, 'DisplayName', ...
    sprintf('Cascada R2-simetrie (a_{stp}=%.4f)', a_r_casc_sim));
yline(1,'k:','LineWidth',1,'HandleVisibility','off');
xline(t_pert,'m:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [s]'); ylabel('y [u.r.]');
title('Fig. 5.8 echiv. - Perturbatie rampa p_2=0.1*t (t_{start}=80s)');
legend('Location','southwest'); xlim([0 400]);

%% =========================================================
%% 4. PERTURBATIE SINUSOIDALA p2=sin(0.1*t) (fig. 5.9)
%% =========================================================
fprintf('\n=== PERTURBATIE SINUSOIDALA (A=1, omega=0.1 rad/s) ===\n');
omega_sin = 0.1;
p2_sin = sin(omega_sin * t_sim2);

[y_ps_mono,    ~] = lsim(H_pert_mono2,    p2_sin, t_sim2);
[y_ps_casc_mod,~] = lsim(H_pert_casc_mod, p2_sin, t_sim2);
[y_ps_casc_sim,~] = lsim(H_pert_casc_sim, p2_sin, t_sim2);

y_s_mono    = y_ref_m  + y_ps_mono;
y_s_casc_mod= y_ref_cm + y_ps_casc_mod;
y_s_casc_sim= y_ref_cs + y_ps_casc_sim;

% Amplitudine in regim stationar (ultimele 2 perioade)
T_sin = 2*pi/omega_sin;
last2T = t_sim2 >= (t_sim2(end) - 2*T_sin);
A_mono_ss    = (max(y_s_mono(last2T))    - min(y_s_mono(last2T)))/2;
A_casc_mod_ss= (max(y_s_casc_mod(last2T))- min(y_s_casc_mod(last2T)))/2;
A_casc_sim_ss= (max(y_s_casc_sim(last2T))- min(y_s_casc_sim(last2T)))/2;

fprintf('Amplitudine raspuns sinusoidal (reg. stationar):\n');
fprintf('  Monocontur:            A = %.4f\n', A_mono_ss);
fprintf('  Cascada (R2 modul):    A = %.4f\n', A_casc_mod_ss);
fprintf('  Cascada (R2 simetrie): A = %.4f\n', A_casc_sim_ss);

figure(4);
plot(t_sim2, y_s_mono,     'b--', 'LineWidth',2, 'DisplayName', ...
    sprintf('Monocontur (A_{ss}=%.4f)', A_mono_ss));
hold on;
plot(t_sim2, y_s_casc_mod, 'r-',  'LineWidth',2, 'DisplayName', ...
    sprintf('Cascada R2-modul (A_{ss}=%.4f)', A_casc_mod_ss));
plot(t_sim2, y_s_casc_sim, 'g-.', 'LineWidth',2, 'DisplayName', ...
    sprintf('Cascada R2-simetrie (A_{ss}=%.4f)', A_casc_sim_ss));
yline(1,'k:','LineWidth',1,'HandleVisibility','off');
yline(1.03,'g:','LineWidth',0.8,'HandleVisibility','off');
yline(0.97,'g:','LineWidth',0.8,'HandleVisibility','off');
grid on; xlabel('Timp [s]'); ylabel('y [u.r.]');
title(sprintf('Fig. 5.9 echiv. - Perturbatie sinusoidala p_2 (A=1, \\omega=%.1f rad/s)', omega_sin));
legend('Location','northeast'); xlim([0 400]);

%% =========================================================
%% 5. SEMNALE DE COMANDA c2 - comparatie (fig. 5.7)
%% =========================================================
% Semnalul de comanda la intrarea EE in cascada vs monocontur
H_cmd_mono    = H_R_mono * feedback(1, H_EE * H_IT * H_TM1);
H_cmd_casc_c2 = H_R2_mod * feedback(H_CL_int_mod, H_R1_mod * H_f1_eq_mod);

% Corectat aici: am adaugat t_sim2 ca al doilea argument pentru a asigura vectori egali
[c_mono,    ~] = step(H_cmd_mono,    t_sim2);
[c_casc_c2, ~] = step(H_cmd_casc_c2,  t_sim2);

figure(5);
plot(t_sim2, c_mono,    'b--', 'LineWidth',2, 'DisplayName','c (monocontur)');
hold on;
plot(t_sim2, c_casc_c2, 'r-',  'LineWidth',2, 'DisplayName','c_2 (cascada)');
grid on; xlabel('Timp [s]'); ylabel('Comanda [u.r.]');
title('Fig. 5.7 echiv. - Semnalele de comanda (referinta treapta, p_2=0)');
legend; xlim([0 400]);

%% =========================================================
%% TABEL CENTRALIZATOR (Tabel 5.1)
%% =========================================================
fprintf('\n=== TABEL 5.1 - CENTRALIZATOR REZULTATE ===\n');
fprintf('%-45s %8s %10s %10s %20s\n', 'Cazul tratat', 'a_stp', 'sigma[%]', 'tr[s]', '[c_min;c_max]');
fprintf('%s\n', repmat('-',1,100));
fprintf('%-45s %8.4f %10.2f %10.2f\n', '1. Monocontur - ref.treapta, p2=0', a_mono, sig_mono, tr_mono);
fprintf('%-45s %8.4f %10.2f %10.2f\n', '2. Cascada R2-modul - ref.treapta, p2=0', a_casc_mod, sig_casc_mod, tr_casc_mod);
fprintf('%-45s %8.4f %10.2f %10.2f\n', '3. Cascada R2-simetrie - ref.treapta, p2=0', a_casc_sim, sig_casc_sim, tr_casc_sim);
fprintf('%-45s %8.4f %10s %10s\n', '4. Monocontur - pert.treapta (t=80s)', a_p_mono, '-', '-');
fprintf('%-45s %8.4f %10s %10s\n', '5. Cascada R2-modul - pert.treapta', a_p_casc_mod, '-', '-');
fprintf('%-45s %8.4f %10s %10s\n', '6. Cascada R2-simetrie - pert.treapta', a_p_casc_sim, '-', '-');
fprintf('%-45s %8.4f %10s %10s\n', '7. Monocontur - pert.rampa', a_r_mono, '-', '-');
fprintf('%-45s %8.4f %10s %10s\n', '8. Cascada R2-modul - pert.rampa', a_r_casc_mod, '-', '-');
fprintf('Amplitudine sinusoidal: Mono=%.4f  Casc-mod=%.4f  Casc-sim=%.4f\n', ...
    A_mono_ss, A_casc_mod_ss, A_casc_sim_ss);

fprintf('\nConcluzie: Cascada cu R2 simetrie rejecteaza mai bine perturbatiile cu variatie rapida.\n');
fprintf('           Monocontur nu poate rejecta perturbatia rampa (a_stp != 0).\n');

%% =========================================================
%% FUNCTII LOCALE (Strict la finalul fișierului)
%% =========================================================
function [sigma, tr, astp] = calc_perf(y, t)
    yst = y(end); 
    ymax = max(y);
    if yst > 0.001
        sigma = (ymax-yst)/yst*100;
        astp  = 1 - yst;
    else
        sigma = 0; 
        astp = 1;
    end
    in_b = abs(y-yst) <= 0.03*max(yst,0.001);
    oi   = find(~in_b,1,'last');
    if isempty(oi)
        tr=0; 
    else
        tr=t(oi); 
    end
end