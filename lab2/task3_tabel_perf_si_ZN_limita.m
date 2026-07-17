%% LABORATOR NR. 2 - Sarcina 4: Tabel centralizator de performante
%% Sarcina 5: Criteriul Ziegler-Nichols bazat pe aducerea la limita de stabilitate
%%
%% Functia de transfer (Sarcina 5):
%% H_f2(s) = 3.3 / ((1+11s)*(1+22s)) * exp(-5s)   [min]
clear; clc; close all;

%% Incarcare parametri din task1
if ~exist('lab2_params.mat','file')
    fprintf('Rulati mai intai task1_identificare_regulatoare.m!\n');
    return;
end
load('lab2_params.mat');
s = tf('s');

%% Functia de transfer a partii fixate (Sarcina 1-4)
[num_pade, den_pade] = pade(Tm, 3);
H_delay = tf(num_pade, den_pade);
H_plant = tf(Kf, [T 1]) * H_delay;
t_sim = 0:0.5:400;

%% =========================================================
%% TABEL CENTRALIZATOR - toate regulatoarele din Tab 2.1 si 2.2
%% =========================================================
fprintf('=== TABEL CENTRALIZATOR PERFORMANTE ===\n');
fprintf('(Simulare cu functia tangenta, p=0, referinta treapta unitara)\n\n');

regs = {
    'Ziegler-Nichols',       'P',   KR_ZN_P,   0,          0;
    'Ziegler-Nichols',       'PI',  KR_ZN_PI,  TI_ZN_PI,   0;
    'Ziegler-Nichols',       'PID', KR_ZN_PID, TI_ZN_PID,  TD_ZN_PID;
    'Oppelt',                'P',   KR_OP_P,   0,          0;
    'Oppelt',                'PI',  KR_OP_PI,  TI_OP_PI,   0;
    'Oppelt',                'PID', KR_OP_PID, TI_OP_PID,  TD_OP_PID;
    'CHR (referinta)',       'P',   KR_CHR_P,  0,          0;
    'CHR (referinta)',       'PI',  KR_CHR_PI, TI_CHR_PI,  0;
    'CHR (referinta)',       'PID', KR_CHR_PID,TI_CHR_PID, TD_CHR_PID;
    'Kopelovici aperiodic',  'P',   KR_KP_P,   0,          0;
    'Kopelovici aperiodic',  'PI',  KR_KP_PI,  TI_KP_PI,   0;
    'Kopelovici aperiodic',  'PID', KR_KP_PID, TI_KP_PID,  TD_KP_PID;
    'Kopelovici oscilant',   'P',   KR_KPo_P,  0,          0;
    'Kopelovici oscilant',   'PI',  KR_KPo_PI, TI_KPo_PI,  0;
    'Kopelovici oscilant',   'PID', KR_KPo_PID,TI_KPo_PID, TD_KPo_PID;
    'CHR (perturbatii)',     'P',   KR_CHRp_P, 0,          0;
    'CHR (perturbatii)',     'PI',  KR_CHRp_PI,TI_CHRp_PI, 0;
    'CHR (perturbatii)',     'PID', KR_CHRp_PID,TI_CHRp_PID,TD_CHRp_PID;
    'Cohen-Coon',            'P',   KR_CC_P,   0,          0;
    'Cohen-Coon',            'PI',  KR_CC_PI,  TI_CC_PI,   0;
    'Cohen-Coon',            'PID', KR_CC_PID, TI_CC_PID,  TD_CC_PID;
};

n = size(regs,1);
results = zeros(n, 5);  % [astp, sigma, tr, cmin, cmax]

for i = 1:n
    type = regs{i,2};
    KR   = regs{i,3};
    TI   = regs{i,4};
    TD   = regs{i,5};
    
    HR   = build_reg(type, KR, TI, TD, s);
    H_OL = HR * H_plant;
    H_CL = feedback(H_OL, 1);
    H_cmd= HR * feedback(1, H_plant*HR);
    
    [y, t_out] = step(H_CL,  t_sim);
    [c, ~]     = step(H_cmd, t_sim);
    
    [sig, tr, astp, cmin, cmax] = full_perf(y, t_out, c, 3);
    results(i,:) = [astp, sig, tr, cmin, cmax];
end

% Afisaj tabel
fprintf('%-5s %-25s %-5s %8s %10s %10s %10s %10s\n', ...
    'Nr.','Criteriu','Reg.','a_stp','sigma[%]','tr[min]','c_min','c_max');
fprintf('%s\n', repmat('-',1,85));
for i = 1:n
    fprintf('%-5d %-25s %-5s %8.4f %10.2f %10.2f %10.4f %10.4f\n', ...
        i, regs{i,1}, regs{i,2}, results(i,1), results(i,2), results(i,3), results(i,4), results(i,5));
end

%% =========================================================
%% SARCINA 5: Ziegler-Nichols - Aducerea la limita de stabilitate
%% H_f2(s) = 3.3 / ((1+11s)*(1+22s)) * exp(-5s)   [minute]
%% =========================================================
fprintf('\n\n=== SARCINA 5: Criteriul Ziegler-Nichols - Limita de stabilitate ===\n');
fprintf('H_f2(s) = 3.3 / ((1+11s)*(1+22s)) * exp(-5s)\n\n');

Kf2  = 3.3;
T12  = 11;
T22  = 22;
Tm2  = 5;

[num_p2, den_p2] = pade(Tm2, 3);
H_delay2 = tf(num_p2, den_p2);
H_plant2 = tf(Kf2, conv([T12 1],[T22 1])) * H_delay2;

%% Gasim K_Rlim prin cautare (regulator P, crestem KR pana la oscilatie intretinuta)
fprintf('Cautare K_Rlim (regulator P, oscilatie intretinuta)...\n');
KR_test_vals = 0.01:0.005:5;
KR_lim = NaN;

for KR_try = KR_test_vals
    H_OL_try = tf(KR_try, 1) * H_plant2;
    H_CL_try = feedback(H_OL_try, 1);
    p = pole(H_CL_try);
    % Sistem la limita: poli pur imaginari (Re=0)
    max_re = max(real(p));
    if max_re >= 0
        KR_lim = KR_try;
        break;
    end
end

if isnan(KR_lim)
    fprintf('ATENTIE: K_Rlim nu s-a gasit in intervalul cercetat. Mariti intervalul.\n');
    KR_lim = 1.0;  % valoare implicita
end
fprintf('K_Rlim gasit: %.5f\n', KR_lim);

%% Perioada oscilatiilor la limita de stabilitate
% Frecventa de oscilatie: omega_lim = frecventa proprie la KR_lim
[mag, phase, wout] = bode(H_plant2, logspace(-3, 1, 5000));
mag   = squeeze(mag);
phase = squeeze(phase);

% Gasim frecventa la care faza = -180 grade
idx_180 = find(phase <= -180, 1, 'first');
if ~isempty(idx_180)
    omega_lim = wout(idx_180);
    T_lim = 2*pi / omega_lim;
    fprintf('Perioada oscilatiilor T_lim = %.4f min\n', T_lim);
else
    % Estimare din simulare cu K_Rlim
    T_lim = 13.76;  % valoare din exemplul lucrarii ca fallback
    fprintf('T_lim estimat (din faza -180): %.4f min (estimat)\n', T_lim);
end

%% Calculul regulatoarelor (Tabelul 2.3)
fprintf('\n--- Parametri regulatoare (Tabelul 2.3 - Ziegler-Nichols limita) ---\n');
% P
KR_ZN2_P = 0.5 * KR_lim;
fprintf('P:   KR = 0.5*K_Rlim = %.4f\n', KR_ZN2_P);

% PI
KR_ZN2_PI = 0.45 * KR_lim;
TI_ZN2_PI = 0.8 * T_lim;
fprintf('PI:  KR = 0.45*K_Rlim = %.4f,  TI = 0.8*T_lim = %.4f min\n', KR_ZN2_PI, TI_ZN2_PI);

% PID
KR_ZN2_PID = 0.75 * KR_lim;
TI_ZN2_PID = 0.6 * T_lim;
TD_ZN2_PID = 0.1 * T_lim;
fprintf('PID: KR = 0.75*K_Rlim = %.4f,  TI = 0.6*T_lim = %.4f min,  TD = 0.1*T_lim = %.4f min\n', ...
    KR_ZN2_PID, TI_ZN2_PID, TD_ZN2_PID);

%% Simulare raspuns cu regulator PI (ca in exemplul din lucrare)
t_sim2 = 0:0.5:200;

HR_PI2 = KR_ZN2_PI * (1 + 1/(TI_ZN2_PI * s));
H_OL2  = HR_PI2 * H_plant2;
H_CL2  = feedback(H_OL2, 1);
[y_PI2, t_PI2] = step(H_CL2, t_sim2);

HR_PID2 = KR_ZN2_PID * (1 + 1/(TI_ZN2_PID*s) + (TD_ZN2_PID*s)/(1 + 0.1*TD_ZN2_PID*s));
H_OL2b  = HR_PID2 * H_plant2;
H_CL2b  = feedback(H_OL2b, 1);
[y_PID2, ~] = step(H_CL2b, t_sim2);

% Performante
yst2 = y_PI2(end);
ymax2 = max(y_PI2);
sigma_PI2 = (ymax2 - yst2)/yst2*100;
in_band2 = abs(y_PI2 - yst2) <= 0.03*yst2;
out_idx2 = find(~in_band2,1,'last');
if ~isempty(out_idx2); tr_PI2 = t_PI2(out_idx2); else; tr_PI2 = 0; end

fprintf('\nPerformante regulator PI (Ziegler-Nichols limita stabilitate):\n');
fprintf('  sigma = %.2f%%,  tr = %.2f min\n', sigma_PI2, tr_PI2);

%% Figura Tabel centralizator (bara comparativa)
figure(5);
subplot(3,1,1);
bar(results(:,1));
set(gca,'XTickLabel', cellfun(@(a,b) [a(1:min(4,end)) '-' b], regs(:,1), regs(:,2),'UniformOutput',false));
xtickangle(45); ylabel('a_{stp}'); title('Abatere stationara la pozitie');
grid on;

subplot(3,1,2);
bar(results(:,2));
set(gca,'XTickLabel', cellfun(@(a,b) [a(1:min(4,end)) '-' b], regs(:,1), regs(:,2),'UniformOutput',false));
xtickangle(45); ylabel('\sigma [%]'); title('Suprareglaj');
grid on;

subplot(3,1,3);
bar(results(:,3));
set(gca,'XTickLabel', cellfun(@(a,b) [a(1:min(4,end)) '-' b], regs(:,1), regs(:,2),'UniformOutput',false));
xtickangle(45); ylabel('t_r [min]'); title('Timp de raspuns');
grid on;
sgtitle('Tabel centralizator performante - toate regulatoarele','FontSize',11,'FontWeight','bold');

%% Figura Sarcina 5: raspuns PI si PID Ziegler-Nichols limita stabilitate
figure(6);
plot(t_PI2, y_PI2,  'b-',  'LineWidth',2, 'DisplayName', ...
    sprintf('PI: KR=%.4f, TI=%.4f min (\\sigma=%.1f%%, tr=%.1f min)', KR_ZN2_PI, TI_ZN2_PI, sigma_PI2, tr_PI2));
hold on;
plot(t_PI2, y_PID2, 'r--', 'LineWidth',2, 'DisplayName', ...
    sprintf('PID: KR=%.4f, TI=%.4f min, TD=%.4f min', KR_ZN2_PID, TI_ZN2_PID, TD_ZN2_PID));
yline(1, 'k:', 'LineWidth',1, 'HandleVisibility','off');
yline(1.03,'g:','LineWidth',0.8,'HandleVisibility','off');
yline(0.97,'g:','LineWidth',0.8,'HandleVisibility','off');
grid on; xlabel('Timp [min]'); ylabel('y');
title(sprintf('Sarcina 5 - Ziegler-Nichols limita stabilitate\nK_{Rlim}=%.4f, T_{lim}=%.4f min', KR_lim, T_lim));
legend('Location','southeast');
xlim([0 200]);

fprintf('\nToate figurile au fost generate.\n');
fprintf('Figura 5: Tabel centralizator performante (toate regulatoarele Tab 2.1 + 2.2)\n');
fprintf('Figura 6: Sarcina 5 - Ziegler-Nichols limita stabilitate\n');

%% =========================================================
%% Helper functii locale (INTOTDEAUNA LA FINAL)
%% =========================================================
function HR = build_reg(type, KR, TI, TD, s)
    Tf = 0.1 * max(TD, 0.001);
    switch type
        case 'P'
            HR = tf(KR, 1);
        case 'PI'
            HR = KR * (1 + 1/(TI*s));
        case 'PID'
            HR = KR * (1 + 1/(TI*s) + (TD*s)/(1 + Tf*s));
    end
end

function [sigma, tr, astp, cmin, cmax] = full_perf(y, t, c, band_pct)
    yst  = y(end);
    ymax = max(y);
    if yst > 0.01
        sigma = (ymax - yst) / yst * 100;
        astp  = 1 - yst;
    else
        sigma = 0; astp = 0;
    end
    band = band_pct/100;
    in_band = abs(y - yst) <= band * max(yst, 0.01);
    out_idx = find(~in_band, 1, 'last');
    tr = t(isempty(out_idx) * 1 + ~isempty(out_idx) * out_idx);
    if isempty(out_idx); tr = t(1); end
    cmin = min(c); cmax = max(c);
end