%% LABORATOR NR. 6 - PARTEA b)
%% Sistemul de reglare a tensiunii la bornele generatorului
%%
%% Schema bloc: fig. 6.11 / 6.12
%% 3 bucle de reglare in cascada:
%%   Bucla 1 (interioara):  curent de excitatie IE  -> regulator R_IE (PID)
%%   Bucla 2 (mijlocie):    tensiune de excitatie UE -> regulator R_UE (PI)
%%   Bucla 3 (exterioara):  tensiune generator UG   -> regulator R_UG (PID)
%%
%% Perturbatia: pU (tensiune) - treapta -1000V la t=70s
%% Referinta:   u*G = 9.5V (tensiune unificata) -> UG_nom = 25000V

clear; clc; close all;

%% =========================================================
%% PARAMETRI SISTEM (din lucrare, ec. 6.9-6.21)
%% =========================================================

% H_EE = 1.388/(1+0.1s)  - element excitatie (PC+CCG)
K_EE  = 1.388; T_EE_b = 0.1;   % [s]

% H_E = 3.6/(1+0.5s)  - subproces excitatie (EX1+EX2)
K_E   = 3.6;   T_E    = 0.5;   % [s]

% H_EG = 13.888  - curent excitatie -> tensiune generator
K_EG  = 13.888;

% H_G = 0.403/(1+4s)  - Generator (sarcina)
K_G   = 0.403; T_G    = 4;     % [s]

% H_CCG+PC = 45  - complex comanda grila + punte redresoare
K_CCG_PC = 45;

% Traductoare (proportionale/ordinul I)
K_TUE    = 0.02;               % traductor tensiune excitatie
K_TIE    = 0.0055;             % traductor curent excitatie [V/A]
K_TUG    = 0.4e-3;             % traductor tensiune generator [V/V] = 4e-4
K_TIG    = 4.96e-5;            % traductor curent sarcina [V/A]

% Coeficienti de ponderare reactie compundare
K_UG     = K_TUG;              % ponderare dupa tensiunea generator
K_IG     = K_TIG;              % ponderare dupa curentul de sarcina (5%)

% Suma constante de timp mici pentru calculul regulatoarelor
T_Sigma_UE = 0.01;             % [s] - pentru bucla UE
T_Sigma_UG = 0.01;             % [s] - pentru bucla UG

%% =========================================================
%% REGULATOARE CALCULATE (ec. 6.18-6.21)
%% =========================================================

% R_UE (PI) - bucla tensiune excitatie (ec. 6.18)
K_RUE    = 4;
T_I_RUE  = 0.1;                % [s]

% R_IE (PID realizabil) - bucla curent excitatie (ec. 6.20)
K_RIE    = 26;
T_I_RIE  = 0.52;               % [s]
T_D_RIE  = 0.019;              % [s]
T_f2     = 0.05;               % [s] - filtru derivativ R_IE

% R_UG (PID cu filtru) - bucla tensiune generator (ec. 6.21)
K_RUG    = 212;
T_I_RUG  = 4.02;               % [s]
T_D_RUG  = 0.198;              % [s]
T_f3     = 4.2;                % [s] - filtru R_UG

% Referinta si perturbatie
u_G_ref  = 9.5;                % [V] tensiune unificata referinta
pU_val   = -1000;              % [V] perturbatie tensiune (treapta negativa)
t_pert_U = 70;                 % [s] momentul perturbatiei

fprintf('=== SISTEM b) TENSIUNEA LA BORNELE GENERATORULUI ===\n\n');
fprintf('Regulatoare:\n');
fprintf('  R_UE (PI):  K_RUE=%.0f,  T_I=%.2fs\n', K_RUE, T_I_RUE);
fprintf('  R_IE (PID): K_RIE=%.0f,  T_I=%.2fs, T_D=%.3fs, Tf2=%.2fs\n', K_RIE, T_I_RIE, T_D_RIE, T_f2);
fprintf('  R_UG (PID): K_RUG=%.0f, T_I=%.2fs, T_D=%.3fs, Tf3=%.1fs\n\n', K_RUG, T_I_RUG, T_D_RUG, T_f3);

%% =========================================================
%% CONSTRUCTIE FUNCTII DE TRANSFER
%% =========================================================
s = tf('s');

% Elemente fizice
H_EE_b     = tf(K_EE,     [T_EE_b, 1]);
H_E        = tf(K_E,      [T_E,    1]);
H_EG_b     = tf(K_EG,     1);
H_G        = tf(K_G,      [T_G,    1]);
H_CCG_PC   = tf(K_CCG_PC, 1);

% Traductoare
H_TUE      = tf(K_TUE,    1);
H_TIE      = tf(K_TIE,    1);
H_TUG_b    = tf(K_TUG,    1);
H_TIG      = tf(K_TIG,    1);

% Regulatoare
H_RUE      = tf(K_RUE * [T_I_RUE, 1], [T_I_RUE, 0]);

% R_IE (PID realizabil cu filtru de ordinul 1):
% K_RIE*(1 + 1/(T_I*s) + T_D*s) / (1 + Tf2*s)
num_RIE = K_RIE * [(T_I_RIE*T_f2 + T_I_RIE*T_D_RIE), (T_I_RIE + T_f2), 1];
den_RIE = [T_I_RIE*T_f2, T_I_RIE, 0];
H_RIE      = tf(num_RIE, den_RIE);

% R_UG (PID cu filtru):
num_RUG = K_RUG * [(T_I_RUG*T_f3 + T_I_RUG*T_D_RUG), (T_I_RUG + T_f3), 1];
den_RUG = [T_I_RUG*T_f3, T_I_RUG, 0];
H_RUG      = tf(num_RUG, den_RUG);

%% =========================================================
%% SISTEME IN BUCLA INCHISA (cascada 3 bucle)
%% =========================================================

% --- BUCLA 1: Curent excitatie (IE) ---
% Calea directa: H_CCG_PC -> H_EE_b -> H_E -> H_EG_b -> H_G... 
% Dar pentru bucla IE: procesul este CCG+PC -> EX1+EX2 -> IE
% H_proc_IE = H_CCG_PC * H_EE_b
H_proc_IE  = H_CCG_PC * H_EE_b;
H_OL_IE    = H_RIE * H_proc_IE * H_TIE;
H_CL_IE    = feedback(H_RIE * H_proc_IE, H_TIE);  % IE/c_IE

fprintf('Bucla IE inchisa: gain DC = %.4f\n', dcgain(H_CL_IE));

% --- BUCLA 2: Tensiune excitatie (UE) ---
% Procesul din perspectiva buclei UE:
% H_proc_UE = H_CL_IE * H_E * H_TUE  (bucla IE echivalenta + subproces excitatie)
H_proc_UE  = H_CL_IE * H_E;
H_OL_UE    = H_RUE * H_proc_UE * H_TUE;
H_CL_UE    = feedback(H_RUE * H_proc_UE, H_TUE);  % UE/c_UE

fprintf('Bucla UE inchisa: gain DC = %.4f\n', dcgain(H_CL_UE));

% --- BUCLA 3: Tensiune generator (UG) ---
% Procesul din perspectiva buclei UG:
% H_proc_UG = H_CL_UE * H_EG_b * H_G
H_proc_UG  = H_CL_UE * H_EG_b * H_G;

% Reactia compusa: -K_UG*UG + K_IG*IG (compundare)
% u_Gr = K_UG*u_G - K_IG*I_G
% u_G = K_TUG * UG,  u_IG = K_TIG * IG
% Reactia totala: H_TUG_b - K_TIG * H_G_curent
% Simplificat (IG neglijat in bucla):
H_react_UG = H_TUG_b;   % reactie principala
H_OL_UG    = H_RUG * H_proc_UG * H_react_UG;
H_CL_UG    = feedback(H_RUG * H_proc_UG, H_react_UG);  % UG/c_UG

% Cu reactia de compundare (5% din reactia de tensiune):
H_react_compund = H_TUG_b - 0.05 * H_TIG;
H_CL_UG_comp   = feedback(H_RUG * H_proc_UG, H_react_compund);

fprintf('Bucla UG inchisa (fara compundare): gain DC = %.4f\n', dcgain(H_CL_UG));
fprintf('Bucla UG inchisa (cu compundare):   gain DC = %.4f\n\n', dcgain(H_CL_UG_comp));

%% =========================================================
%% SIMULARE 1: Referinta treapta u*G si perturbatie pU (treapta)
%% =========================================================
t_sim = 0:0.1:100;
idx_pert_U = round(t_pert_U / 0.1) + 1;

% Referinta u*G = 9.5V la t=0
[UG_ref, t_out] = step(H_CL_UG_comp * u_G_ref, t_sim);

% Perturbatie tensiune pU = -1000V la t=70s (actioneaza direct pe UG)
H_CL_UG_pert = feedback(H_proc_UG, H_react_compund * H_RUG);
pU_input = zeros(size(t_sim));
pU_input(idx_pert_U:end) = pU_val;
[UG_pert_resp, ~] = lsim(H_CL_UG_pert, pU_input, t_sim);

UG_total = UG_ref + UG_pert_resp;
UG_kV = UG_total / K_TUG / 1000;  % [kV]

% Semnalul de comanda c (din R_UG) -> intrare CCG+PC [0;8]V
H_cmd_UG = H_RUG * feedback(1, H_proc_UG * H_react_compund);
[c_ref, ~]   = step(H_cmd_UG * u_G_ref, t_sim);
[c_pert, ~]  = lsim(-H_cmd_UG * H_proc_UG / H_proc_UG, pU_input, t_sim);
c_total = c_ref;  % simplificat

fprintf('=== SIMULARE 1: Treapta ref. + pert. tensiune treapta ===\n');
fprintf('UG stationara = %.2f kV (nom: 25kV)\n', UG_ref(end)/K_TUG/1000);
fprintf('Abatere stationara dupa perturbatie: %.6f V\n', UG_total(end));

% Figura 6.13 echivalent
figure(5);
subplot(2,1,1);
plot(t_out, UG_total/K_TUG/1000, 'b-', 'LineWidth', 2);
yline(u_G_ref/K_TUG/1000, 'r--', 'LineWidth', 1);
xline(t_pert_U, 'm:', 'LineWidth', 1);
text(t_pert_U+1, UG_ref(end)/K_TUG/1000*0.5, sprintf('p_U=%.0fV', pU_val),'Color','m');
grid on; xlabel('Timp [s]'); ylabel('U_G [kV]');
title('Fig. 6.13 echiv. - Tensiunea la bornele generatorului (pert. treapta)');
xlim([0 100]);

subplot(2,1,2);
plot(t_out, c_ref, 'b-', 'LineWidth', 2);
yline(0,'k:','LineWidth',1);
yline(8,'r:','LineWidth',1,'DisplayName','Limita sup. 8V');
grid on; xlabel('Timp [s]'); ylabel('c [V]');
title('Fig. 6.14 echiv. - Semnalul de comanda al R_{UE}');
xlim([0 100]);

%% =========================================================
%% SIMULARE 2: Cu "intarziere" semnale (fig. 6.15)
%% =========================================================
% Filtre intarziere ordinul 2
H_REF2  = tf(1, conv([5,1],[8,1]));
H_PERT2 = tf(1, conv([1,1],[1,1]));

[UG_ref_filt,  ~] = step(H_CL_UG_comp * H_REF2 * u_G_ref, t_sim);
[UG_pert_filt, ~] = lsim(H_CL_UG_pert * H_PERT2, pU_input, t_sim);
UG_filt = UG_ref_filt + UG_pert_filt;

H_cUE_filt = H_RUE * feedback(1, H_proc_UE * H_TUE);
[cUE_filt, ~]    = step(H_cUE_filt * H_REF2 * u_G_ref, t_sim);

fprintf('\n=== SIMULARE 2: Semnale filtrate (intarziate) ===\n');
fprintf('UG stationara (filtrat): %.4f kV\n', UG_filt(end)/K_TUG/1000);
fprintf('Abatere stationara dupa perturbatie: %.6f\n', UG_filt(end));

figure(6);
subplot(3,1,1);
plot(t_out, UG_filt/K_TUG/1000, 'b-', 'LineWidth',2);
yline(u_G_ref/K_TUG/1000, 'r--', 'LineWidth',1);
xline(t_pert_U, 'm:', 'LineWidth',1);
grid on; xlabel('Timp [s]'); ylabel('U_G [kV]');
title('Fig. 6.15 echiv. - Tensiunea la bornele generatorului (semnale intarziate)');
xlim([0 100]);

subplot(3,1,2);
plot(t_out, cUE_filt, 'b-', 'LineWidth',2);
yline(8,'r:','LineWidth',1); yline(0,'k:','LineWidth',1);
grid on; xlabel('Timp [s]'); ylabel('c_{UE} [V]');
title('Fig. 6.16 echiv. - Comanda R_{UE}'); xlim([0 100]);

%% =========================================================
%% SIMULARE 3: Studiu influenta Tf2 (cerinta 6.4 pct. 5)
%%   Tf2 din intervalul [0.01s - 2s]
%% =========================================================
fprintf('\n=== SIMULARE 3: Influenta Tf2 asupra sistemului ===\n');
Tf2_vals = [0.01, 0.05, 0.1, 0.5, 1.0, 2.0];
colors_Tf = {'b-','r--','g-.','m:','c-','k--'};

figure(7);
subplot(2,1,1);
for k = 1:length(Tf2_vals)
    Tf2_k = Tf2_vals(k);
    num_RIE_k = K_RIE * [(T_I_RIE*Tf2_k + T_I_RIE*T_D_RIE), (T_I_RIE + Tf2_k), 1];
    den_RIE_k = [T_I_RIE*Tf2_k, T_I_RIE, 0];
    H_RIE_k   = tf(num_RIE_k, den_RIE_k);
    H_CL_IE_k = feedback(H_RIE_k * H_proc_IE, H_TIE);
    H_CL_UE_k = feedback(H_RUE * H_CL_IE_k * H_E, H_TUE);
    H_proc_UG_k = H_CL_UE_k * H_EG_b * H_G;
    H_CL_UG_k   = feedback(H_RUG * H_proc_UG_k, H_react_compund);
    try
        [UG_k, ~] = step(H_CL_UG_k * H_REF2 * u_G_ref, t_sim);
        plot(t_out, UG_k/K_TUG/1000, colors_Tf{k}, 'LineWidth', 1.5, ...
            'DisplayName', sprintf('T_{f2}=%.2fs', Tf2_k));
        hold on;
    catch
        fprintf('  Tf2=%.2f: sistem instabil\n', Tf2_k);
    end
end
yline(u_G_ref/K_TUG/1000,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [s]'); ylabel('U_G [kV]');
title('Studiu Tf2 - Influenta constantei de timp a filtrului R_{IE}');
legend('Location','southeast'); xlim([0 100]);

subplot(2,1,2);
% Afisam UG in tensiune unificata pentru comparatie
for k = 1:length(Tf2_vals)
    Tf2_k = Tf2_vals(k);
    num_RIE_k = K_RIE * [(T_I_RIE*Tf2_k + T_I_RIE*T_D_RIE), (T_I_RIE + Tf2_k), 1];
    den_RIE_k = [T_I_RIE*Tf2_k, T_I_RIE, 0];
    H_RIE_k   = tf(num_RIE_k, den_RIE_k);
    H_CL_IE_k = feedback(H_RIE_k * H_proc_IE, H_TIE);
    H_CL_UE_k = feedback(H_RUE * H_CL_IE_k * H_E, H_TUE);
    H_proc_UG_k = H_CL_UE_k * H_EG_b * H_G;
    H_CL_UG_k   = feedback(H_RUG * H_proc_UG_k, H_react_compund);
    H_CL_UG_pert_k = feedback(H_proc_UG_k, H_react_compund * H_RUG);
    try
        [UG_ref_k, ~]  = step(H_CL_UG_k * H_REF2 * u_G_ref, t_sim);
        [UG_pert_k, ~] = lsim(H_CL_UG_pert_k * H_PERT2, pU_input, t_sim);
        UG_tot_k = UG_ref_k + UG_pert_k;
        sigma_k = (max(UG_tot_k) - UG_tot_k(end)) / UG_tot_k(end) * 100;
        fprintf('  Tf2=%.2fs: UG_st=%.4fkV, sigma=%.2f%%\n', Tf2_k, UG_tot_k(end)/K_TUG/1000, sigma_k);
        plot(t_out, UG_tot_k/K_TUG/1000, colors_Tf{k}, 'LineWidth',1.5, ...
            'DisplayName', sprintf('T_{f2}=%.2fs', Tf2_k));
        hold on;
    catch; end
end
xline(t_pert_U,'m:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [s]'); ylabel('U_G [kV]');
title('Studiu Tf2 - Raspuns la referinta + pert. tensiune');
legend('Location','southeast'); xlim([0 100]);

fprintf('\nFigurile 5-7 genereaza echivalentele fig. 6.12-6.18 din lucrare.\n');
fprintf('Sistemul b) utilizeaza 3 bucle de cascada: IE -> UE -> UG\n');
