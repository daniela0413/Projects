%% LABORATOR NR. 2 - Sarcina 3: Simulare regulatoare din TABELUL 2.2
%% Raspuns optim la perturbatii (p=0 initial, se verifica respingerea perturbatiei)
%% Pe aceeasi figura: comparatie regulatoare pe aceeasi linie (P, PI, PID)
%% Pe figura separata: comparatie regulatoare pe aceeasi coloana (criteriu)



%% Incarcare parametri
if ~exist('lab2_params.mat','file')
    fprintf('Rulati mai intai task1_identificare_regulatoare.m!\n');
    return;
end
load('lab2_params.mat');

s = tf('s');


%% Kopelovici aperiodic
[y_KP_P,  t_out, ~] = simulate_pert('P',   KR_KP_P,  0,        0,        H_plant, t_sim, s);
[y_KP_PI, ~,     ~] = simulate_pert('PI',  KR_KP_PI, TI_KP_PI, 0,        H_plant, t_sim, s);
[y_KP_PID,~,     ~] = simulate_pert('PID', KR_KP_PID,TI_KP_PID,TD_KP_PID,H_plant, t_sim, s);

%% Kopelovici oscilant
[y_KPo_P,  ~, ~] = simulate_pert('P',   KR_KPo_P,  0,         0,          H_plant, t_sim, s);
[y_KPo_PI, ~, ~] = simulate_pert('PI',  KR_KPo_PI, TI_KPo_PI, 0,          H_plant, t_sim, s);
[y_KPo_PID,~, ~] = simulate_pert('PID', KR_KPo_PID,TI_KPo_PID,TD_KPo_PID, H_plant, t_sim, s);

%% Chien-Hrones-Reswich perturbatii
[y_CHRp_P,  ~, ~] = simulate_pert('P',   KR_CHRp_P,  0,          0,           H_plant, t_sim, s);
[y_CHRp_PI, ~, ~] = simulate_pert('PI',  KR_CHRp_PI, TI_CHRp_PI, 0,           H_plant, t_sim, s);
[y_CHRp_PID,~, ~] = simulate_pert('PID', KR_CHRp_PID,TI_CHRp_PID,TD_CHRp_PID, H_plant, t_sim, s);

%% Cohen-Coon
[y_CC_P,  ~, ~] = simulate_pert('P',   KR_CC_P,  0,        0,        H_plant, t_sim, s);
[y_CC_PI, ~, ~] = simulate_pert('PI',  KR_CC_PI, TI_CC_PI, 0,        H_plant, t_sim, s);
[y_CC_PID,~, ~] = simulate_pert('PID', KR_CC_PID,TI_CC_PID,TD_CC_PID,H_plant, t_sim, s);

%% Performante perturbatie
[ym_KP_P,  tr_KP_P]  = calc_perf_pert(y_KP_P,  t_out, 3);
[ym_KP_PI, tr_KP_PI] = calc_perf_pert(y_KP_PI, t_out, 3);
[ym_KP_PID,tr_KP_PID]= calc_perf_pert(y_KP_PID,t_out, 3);
[ym_KPo_P,  tr_KPo_P]  = calc_perf_pert(y_KPo_P,  t_out, 3);
[ym_KPo_PI, tr_KPo_PI] = calc_perf_pert(y_KPo_PI, t_out, 3);
[ym_KPo_PID,tr_KPo_PID]= calc_perf_pert(y_KPo_PID,t_out, 3);
[ym_CHRp_P,  tr_CHRp_P]  = calc_perf_pert(y_CHRp_P,  t_out, 3);
[ym_CHRp_PI, tr_CHRp_PI] = calc_perf_pert(y_CHRp_PI, t_out, 3);
[ym_CHRp_PID,tr_CHRp_PID]= calc_perf_pert(y_CHRp_PID,t_out, 3);
[ym_CC_P,  tr_CC_P]  = calc_perf_pert(y_CC_P,  t_out, 3);
[ym_CC_PI, tr_CC_PI] = calc_perf_pert(y_CC_PI, t_out, 3);
[ym_CC_PID,tr_CC_PID]= calc_perf_pert(y_CC_PID,t_out, 3);

fprintf('%-40s %12s %12s\n', 'Criteriu - Regulator', '|y|_max', 'tr_pert[min]');
fprintf('%s\n', repmat('-',1,68));
fprintf('%-40s %12.4f %12.2f\n', 'Kopelovici aperiodic - P',   ym_KP_P,   tr_KP_P);
fprintf('%-40s %12.4f %12.2f\n', 'Kopelovici aperiodic - PI',  ym_KP_PI,  tr_KP_PI);
fprintf('%-40s %12.4f %12.2f\n', 'Kopelovici aperiodic - PID', ym_KP_PID, tr_KP_PID);
fprintf('%-40s %12.4f %12.2f\n', 'Kopelovici oscilant - P',    ym_KPo_P,  tr_KPo_P);
fprintf('%-40s %12.4f %12.2f\n', 'Kopelovici oscilant - PI',   ym_KPo_PI, tr_KPo_PI);
fprintf('%-40s %12.4f %12.2f\n', 'Kopelovici oscilant - PID',  ym_KPo_PID,tr_KPo_PID);
fprintf('%-40s %12.4f %12.2f\n', 'CHR (perturbatii) - P',   ym_CHRp_P,   tr_CHRp_P);
fprintf('%-40s %12.4f %12.2f\n', 'CHR (perturbatii) - PI',  ym_CHRp_PI,  tr_CHRp_PI);
fprintf('%-40s %12.4f %12.2f\n', 'CHR (perturbatii) - PID', ym_CHRp_PID, tr_CHRp_PID);
fprintf('%-40s %12.4f %12.2f\n', 'Cohen-Coon - P',   ym_CC_P,   tr_CC_P);
fprintf('%-40s %12.4f %12.2f\n', 'Cohen-Coon - PI',  ym_CC_PI,  tr_CC_PI);
fprintf('%-40s %12.4f %12.2f\n', 'Cohen-Coon - PID', ym_CC_PID, tr_CC_PID);

%% =========================================================
%% FIGURA 3: Comparatie pe LINIE (P vs PI vs PID) - Tabelul 2.2
%% =========================================================
figure(3);
sgtitle('Tabelul 2.2 - Comparatie regulatoare pe aceeasi linie (tip)','FontSize',12,'FontWeight','bold');

subplot(4,1,1);
plot(t_out, y_KP_P,   'b-',  'LineWidth',2,'DisplayName','Kopelovici aperiodic P'); hold on;
plot(t_out, y_KPo_P,  'r--', 'LineWidth',2,'DisplayName','Kopelovici oscilant P');
plot(t_out, y_CHRp_P, 'g-.', 'LineWidth',2,'DisplayName','CHR P');
plot(t_out, y_CC_P,   'm:',  'LineWidth',2,'DisplayName','Cohen-Coon P');
yline(0,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [min]'); ylabel('y'); title('Regulatoare P'); legend('Location','northeast'); xlim([0 300]);

subplot(4,1,2);
plot(t_out, y_KP_PI,   'b-',  'LineWidth',2,'DisplayName','Kopelovici aperiodic PI'); hold on;
plot(t_out, y_KPo_PI,  'r--', 'LineWidth',2,'DisplayName','Kopelovici oscilant PI');
plot(t_out, y_CHRp_PI, 'g-.', 'LineWidth',2,'DisplayName','CHR PI');
plot(t_out, y_CC_PI,   'm:',  'LineWidth',2,'DisplayName','Cohen-Coon PI');
yline(0,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [min]'); ylabel('y'); title('Regulatoare PI'); legend('Location','northeast'); xlim([0 300]);

subplot(4,1,3);
plot(t_out, y_KP_PID,   'b-',  'LineWidth',2,'DisplayName','Kopelovici aperiodic PID'); hold on;
plot(t_out, y_KPo_PID,  'r--', 'LineWidth',2,'DisplayName','Kopelovici oscilant PID');
plot(t_out, y_CHRp_PID, 'g-.', 'LineWidth',2,'DisplayName','CHR PID');
plot(t_out, y_CC_PID,   'm:',  'LineWidth',2,'DisplayName','Cohen-Coon PID');
yline(0,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [min]'); ylabel('y'); title('Regulatoare PID'); legend('Location','northeast'); xlim([0 300]);

subplot(4,1,4);
% Sumar: cel mai bun din fiecare tip
plot(t_out, y_KP_P,   'b-',  'LineWidth',2,'DisplayName','P (Kop. aperiodic)'); hold on;
plot(t_out, y_KPo_PI, 'r--', 'LineWidth',2,'DisplayName','PI (Kop. oscilant)');
plot(t_out, y_KP_PID, 'g-.', 'LineWidth',2,'DisplayName','PID (Kop. aperiodic)');
yline(0,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [min]'); ylabel('y'); title('Sumar: Best P / PI / PID'); legend('Location','northeast'); xlim([0 300]);

%% =========================================================
%% FIGURA 4: Comparatie pe COLOANA (P/PI/PID per criteriu) - Tabelul 2.2
%% =========================================================
figure(4);
sgtitle('Tabelul 2.2 - Comparatie P/PI/PID pentru fiecare criteriu','FontSize',12,'FontWeight','bold');

subplot(2,2,1);
plot(t_out, y_KP_P,   'b-',  'LineWidth',2,'DisplayName','P'); hold on;
plot(t_out, y_KP_PI,  'r--', 'LineWidth',2,'DisplayName','PI');
plot(t_out, y_KP_PID, 'g-.', 'LineWidth',2,'DisplayName','PID');
yline(0,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [min]'); ylabel('y');
title('Kopelovici aperiodic'); legend; xlim([0 300]);

subplot(2,2,2);
plot(t_out, y_KPo_P,   'b-',  'LineWidth',2,'DisplayName','P'); hold on;
plot(t_out, y_KPo_PI,  'r--', 'LineWidth',2,'DisplayName','PI');
plot(t_out, y_KPo_PID, 'g-.', 'LineWidth',2,'DisplayName','PID');
yline(0,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [min]'); ylabel('y');
title('Kopelovici oscilant'); legend; xlim([0 300]);

subplot(2,2,3);
plot(t_out, y_CHRp_P,   'b-',  'LineWidth',2,'DisplayName','P'); hold on;
plot(t_out, y_CHRp_PI,  'r--', 'LineWidth',2,'DisplayName','PI');
plot(t_out, y_CHRp_PID, 'g-.', 'LineWidth',2,'DisplayName','PID');
yline(0,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [min]'); ylabel('y');
title('CHR (perturbatii)'); legend; xlim([0 300]);

subplot(2,2,4);
plot(t_out, y_CC_P,   'b-',  'LineWidth',2,'DisplayName','P'); hold on;
plot(t_out, y_CC_PI,  'r--', 'LineWidth',2,'DisplayName','PI');
plot(t_out, y_CC_PID, 'g-.', 'LineWidth',2,'DisplayName','PID');
yline(0,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [min]'); ylabel('y');
title('Cohen-Coon'); legend; xlim([0 300]);

fprintf('\nFigurile 3 si 4 generate pentru Tabelul 2.2.\n');
%% Functia de transfer a partii fixate cu timp mort
[num_pade, den_pade] = pade(Tm, 3);
H_delay = tf(num_pade, den_pade);
H_plant = tf(Kf, [T 1]) * H_delay;

t_sim = 0:0.5:300;

%% Helper: simuleaza sistem in bucla inchisa (referinta=0, perturbatie treapta la t=0)
function [y_out, t_out, c_out] = simulate_pert(type, KR, TI, TD, H_plant, t_sim, s)
    Tf = 0.1 * max(TD, 0.001);
    switch type
        case 'P'
            HR = tf(KR, 1);
        case 'PI'
            HR = KR * (1 + 1/(TI*s));
        case 'PID'
            HR = KR * (1 + 1/(TI*s) + (TD*s)/(1 + Tf*s));
    end
    % Raspuns la perturbatie cu w=0: Y(s) = H_plant/(1+HR*H_plant) * P(s)
    H_CL_pert = feedback(H_plant, HR);
    % Semnal de comanda: C(s) = -HR/(1+HR*H_plant)*P(s)
    H_cmd_pert = -feedback(HR * H_plant, 1) * (1/H_plant) * feedback(H_plant, HR);
    % Simplificat: e(s) = -Y_pert(s), c(s) = HR * e(s)
    [y_out, t_out] = step(H_CL_pert, t_sim);
    H_cmd2 = HR * feedback(1, H_plant*HR);
    % Folosim: semnal de comanda la perturbatie
    c_out = zeros(size(t_out));  % aproximatie
end

%% Helper: calcul performante perturbatie (cat de repede revine la 0)
function [ymax_abs, tr_pert] = calc_perf_pert(y, t, band_pct)
    ymax_abs = max(abs(y));
    band = band_pct/100 * 1;  % banda ±3% fata de yst=1 (referinta=1 in practica)
    in_band = abs(y) <= band;
    out_idx = find(~in_band, 1, 'last');
    if isempty(out_idx)
        tr_pert = t(1);
    else
        tr_pert = t(out_idx);
    end
end


