%% LABORATOR NR. 2 - Acordarea regulatoarelor pentru procese cu timp mort
%% Sarcina 1: Identificare experimentala + calcul regulatoare (Tabelele 2.1 si 2.2)
%%
%% Functia de transfer a partii fixate:
%% H_F(s) = 4.25 / ((1+0.3s)*(1+22.5s)*(1+40s))
%% Timp exprimat in minute.



%% =========================================================
%% PASUL 1: Simulare raspuns indicial al procesului de ordin superior
%%          (pentru a obtine datele experimentale)
%% =========================================================
s = tf('s');
H_process = 4.25 / ((1 + 0.3*s)*(1 + 22.5*s)*(1 + 40*s));

t_exp = 0:0.5:300;
y_exp = step(H_process, t_exp);

yst = y_exp(end);
y0  = y_exp(1);
m0  = 0;  mst = 1;

fprintf('=== IDENTIFICARE EXPERIMENTALA ===\n');
fprintf('y0 = %.4f,  yst = %.4f\n', y0, yst);
K_f = (yst - y0) / (mst - m0);
fprintf('K_f = (yst-y0)/(mst-m0) = %.4f\n\n', K_f);

%% =========================================================
%% METODA TANGENTEI - punct de inflexiune
%% =========================================================
fprintf('--- METODA TANGENTEI ---\n');

% Fortam t_exp sa fie vector coloana prin t_exp(:) pentru a evita generarea unei matrici
dy = diff(y_exp) ./ diff(t_exp(:)); 

[max_slope, idx_slope] = max(dy);
t_inf = t_exp(idx_slope);
y_inf = y_exp(idx_slope);

fprintf('Punct de inflexiune: t_inf = %.4f min, y_inf = %.4f\n', t_inf, y_inf);
fprintf('Panta in punctul de inflexiune: %.6f\n', max_slope);

% Timp mort si constanta de timp
Tm_tang = t_inf - y_inf / max_slope;
T_tang  = (yst - y_inf) / max_slope;

fprintf('Tm (metoda tangentei) = %.4f min\n', Tm_tang);
fprintf('T  (metoda tangentei) = %.4f min\n', T_tang);
fprintf('H_F_tang(s) = %.4f / (1 + %.4f*s) * exp(-%.4f*s)\n\n', K_f, T_tang, Tm_tang);
%% =========================================================
%% METODA COHEN-COON
%% =========================================================
fprintf('--- METODA COHEN-COON ---\n');
y28_val  = 0.28 * yst;
y632_val = 0.632 * yst;
t28  = interp1(y_exp, t_exp, y28_val);
t632 = interp1(y_exp, t_exp, y632_val);
fprintf('t28 = %.4f min,  t632 = %.4f min\n', t28, t632);

T_cc  = 1.5 * (t632 - t28);
Tm_cc = 1.5 * (t28 - t632/3);
alpha_cc = T_cc / Tm_cc;
fprintf('T (Cohen-Coon) = %.4f min\n', T_cc);
fprintf('Tm(Cohen-Coon) = %.4f min\n', Tm_cc);
fprintf('alpha = T/Tm   = %.4f\n', alpha_cc);
fprintf('H_F_cc(s) = %.4f / (1 + %.4f*s) * exp(-%.4f*s)\n\n', K_f, T_cc, Tm_cc);

%% =========================================================
%% STOCARE PARAMETRI IDENTIFICATI
%% =========================================================
% Se folosesc parametrii din metoda tangentei pentru Tabelele 2.1 si 2.2
% iar pentru Cohen-Coon se folosesc parametrii proprii
Tm = Tm_tang;
T  = T_tang;
Kf = K_f;

Tm_cc_val = Tm_cc;
T_cc_val  = T_cc;
alpha     = alpha_cc;
Kf_cc     = K_f;

%% =========================================================
%% CALCUL REGULATOARE - TABELUL 2.1 (raspuns optim la referinta)
%% =========================================================
fprintf('=== TABELUL 2.1 - Raspuns optim la referinta ===\n\n');

% ---- Ziegler-Nichols ----
fprintf('--- Ziegler-Nichols ---\n');
% P
KR_ZN_P = T / (Tm * Kf);
fprintf('P:   KR = T/(Tm*Kf) = %.4f\n', KR_ZN_P);
% PI
KR_ZN_PI = 0.9 * T / (Tm * Kf);
TI_ZN_PI = 3.3 * Tm;
fprintf('PI:  KR = 0.9*T/(Tm*Kf) = %.4f,  TI = 3.3*Tm = %.4f min\n', KR_ZN_PI, TI_ZN_PI);
% PID (q=1)
KR_ZN_PID = 1.2 * T / (Tm * Kf);
TI_ZN_PID = 2 * Tm;
TD_ZN_PID = 0.5 * Tm;
fprintf('PID: KR = 1.2*T/(Tm*Kf) = %.4f,  TI = 2*Tm = %.4f min,  TD = 0.5*Tm = %.4f min\n\n', ...
    KR_ZN_PID, TI_ZN_PID, TD_ZN_PID);

% ---- Oppelt ----
fprintf('--- Oppelt ---\n');
KR_OP_P = T / (Tm * Kf);
fprintf('P:   KR = T/(Tm*Kf) = %.4f\n', KR_OP_P);
KR_OP_PI = 0.8 * T / (Tm * Kf);
TI_OP_PI = 3 * Tm;
fprintf('PI:  KR = 0.8*T/(Tm*Kf) = %.4f,  TI = 3*Tm = %.4f min\n', KR_OP_PI, TI_OP_PI);
KR_OP_PID = 1.2 * T / (Tm * Kf);
TI_OP_PID = 2 * Tm;
TD_OP_PID = 0.42 * Tm;
fprintf('PID: KR = 1.2*T/(Tm*Kf) = %.4f,  TI = 2*Tm = %.4f min,  TD = 0.42*Tm = %.4f min\n\n', ...
    KR_OP_PID, TI_OP_PID, TD_OP_PID);

% ---- Chien-Hrones-Reswich (raspuns aperiodic) ----
fprintf('--- Chien-Hrones-Reswich (aperiodic, referinta) ---\n');
KR_CHR_P = 0.3 * T / (Tm * Kf);
fprintf('P:   KR = 0.3*T/(Tm*Kf) = %.4f\n', KR_CHR_P);
KR_CHR_PI = 0.35 * T / (Tm * Kf);
TI_CHR_PI = 1.2 * Tm;
fprintf('PI:  KR = 0.35*T/(Tm*Kf) = %.4f,  TI = 1.2*Tm = %.4f min\n', KR_CHR_PI, TI_CHR_PI);
KR_CHR_PID = 0.6 * T / (Tm * Kf);
TI_CHR_PID = Tm;
TD_CHR_PID = 0.5 * Tm;
fprintf('PID: KR = 0.6*T/(Tm*Kf) = %.4f,  TI = Tm = %.4f min,  TD = 0.5*Tm = %.4f min\n\n', ...
    KR_CHR_PID, TI_CHR_PID, TD_CHR_PID);

%% =========================================================
%% CALCUL REGULATOARE - TABELUL 2.2 (raspuns optim la perturbatii)
%% =========================================================
fprintf('=== TABELUL 2.2 - Raspuns optim la perturbatii ===\n\n');

% ---- Kopelovici (aperiodic) ----
fprintf('--- Kopelovici (raspuns aperiodic) ---\n');
KR_KP_P = 0.3 * T / (Tm * Kf);
fprintf('P:   KR = 0.3*T/(Tm*Kf) = %.4f\n', KR_KP_P);
KR_KP_PI = 0.6 * T / (Tm * Kf);
TI_KP_PI = 0.8 * Tm + 0.5 * T;
fprintf('PI:  KR = 0.6*T/(Tm*Kf) = %.4f,  TI = 0.8*Tm+0.5*T = %.4f min\n', KR_KP_PI, TI_KP_PI);
KR_KP_PID = 0.95 * T / (Tm * Kf);
TI_KP_PID = 2 * Tm;
TD_KP_PID = 0.4 * Tm;
fprintf('PID: KR = 0.95*T/(Tm*Kf) = %.4f,  TI = 2*Tm = %.4f min,  TD = 0.4*Tm = %.4f min\n\n', ...
    KR_KP_PID, TI_KP_PID, TD_KP_PID);

% ---- Kopelovici (oscilant) ----
fprintf('--- Kopelovici (raspuns oscilant) ---\n');
KR_KPo_P  = 1.41 / Kf * (T/Tm)^0.917;
fprintf('P:   KR = 1.41/Kf*(T/Tm)^0.917 = %.4f\n', KR_KPo_P);
KR_KPo_PI = 1.41 / Kf * (T/Tm)^0.945;
TI_KPo_PI = 2.03 * T * (Tm/T)^0.739;
fprintf('PI:  KR = %.4f,  TI = %.4f min\n', KR_KPo_PI, TI_KPo_PI);
KR_KPo_PID = 1.3 / Kf * (T/Tm)^0.945;
TI_KPo_PID = 0.917 * T * (Tm/T)^0.771;
TD_KPo_PID = 0.59 * Tm;
fprintf('PID: KR = %.4f,  TI = %.4f min,  TD = %.4f min\n\n', KR_KPo_PID, TI_KPo_PID, TD_KPo_PID);

% ---- Chien-Hrones-Reswich (raspuns aperiodic, perturbatii) ----
fprintf('--- Chien-Hrones-Reswich (aperiodic, perturbatii) ---\n');
KR_CHRp_P = 0.3 * T / (Tm * Kf);
fprintf('P:   KR = 0.3*T/(Tm*Kf) = %.4f\n', KR_CHRp_P);
KR_CHRp_PI = 0.6 * T / (Tm * Kf);
TI_CHRp_PI = 4 * Tm;
fprintf('PI:  KR = 0.6*T/(Tm*Kf) = %.4f,  TI = 4*Tm = %.4f min\n', KR_CHRp_PI, TI_CHRp_PI);
KR_CHRp_PID = 0.95 * T / (Tm * Kf);
TI_CHRp_PID = 2.4 * Tm;
TD_CHRp_PID = 0.42 * Tm;
fprintf('PID: KR = 0.95*T/(Tm*Kf) = %.4f,  TI = 2.4*Tm = %.4f min,  TD = 0.42*Tm = %.4f min\n\n', ...
    KR_CHRp_PID, TI_CHRp_PID, TD_CHRp_PID);

% ---- Cohen-Coon (folosind parametrii Cohen-Coon) ----
fprintf('--- Cohen-Coon ---\n');
fprintf('  Parametri Cohen-Coon: T=%.4f min, Tm=%.4f min, alpha=%.4f\n', T_cc_val, Tm_cc_val, alpha);
KR_CC_P  = 1.5 / Kf_cc * (1/alpha + 0.333);
fprintf('P:   KR = 1.5/Kf*(1/alpha+0.333) = %.4f\n', KR_CC_P);
KR_CC_PI = 1.5 / Kf_cc * (1/alpha + 0.333);  % same formula for P and PI KR in Cohen-Coon
TI_CC_PI = Tm_cc_val * (3.33*alpha + 0.333*alpha^2) / (1 + 2.2*alpha);
fprintf('PI:  KR = %.4f,  TI = %.4f min\n', KR_CC_PI, TI_CC_PI);
KR_CC_PID = 1.35 / Kf_cc * (1/alpha + 0.2);
TI_CC_PID = Tm_cc_val * (2.5*alpha + 0.5*alpha^2) / (1 + 0.6*alpha);
TD_CC_PID = Tm_cc_val * 0.37*alpha / (1 + 0.2*alpha);
fprintf('PID: KR = %.4f,  TI = %.4f min,  TD = %.4f min\n\n', KR_CC_PID, TI_CC_PID, TD_CC_PID);

%% =========================================================
%% SALVARE PARAMETRI pentru utilizare in celelalte scripturi
%% =========================================================
save('lab2_params.mat', ...
    'Kf', 'T', 'Tm', 'T_cc_val', 'Tm_cc_val', 'alpha', 'Kf_cc', ...
    'KR_ZN_P',  'KR_ZN_PI',  'TI_ZN_PI',  'KR_ZN_PID',  'TI_ZN_PID',  'TD_ZN_PID', ...
    'KR_OP_P',  'KR_OP_PI',  'TI_OP_PI',  'KR_OP_PID',  'TI_OP_PID',  'TD_OP_PID', ...
    'KR_CHR_P', 'KR_CHR_PI', 'TI_CHR_PI', 'KR_CHR_PID', 'TI_CHR_PID', 'TD_CHR_PID', ...
    'KR_KP_P',  'KR_KP_PI',  'TI_KP_PI',  'KR_KP_PID',  'TI_KP_PID',  'TD_KP_PID', ...
    'KR_KPo_P', 'KR_KPo_PI', 'TI_KPo_PI', 'KR_KPo_PID', 'TI_KPo_PID', 'TD_KPo_PID', ...
    'KR_CHRp_P','KR_CHRp_PI','TI_CHRp_PI','KR_CHRp_PID','TI_CHRp_PID','TD_CHRp_PID', ...
    'KR_CC_P',  'KR_CC_PI',  'TI_CC_PI',  'KR_CC_PID',  'TI_CC_PID',  'TD_CC_PID', ...
    't_exp', 'y_exp', 't28', 't632', 'Tm_tang', 'T_tang', 'Tm_cc', 'T_cc');

fprintf('Parametrii salvati in lab2_params.mat\n');
fprintf('Rulati acum: task2_simulare_tab21.m si task2_simulare_tab22.m\n');
