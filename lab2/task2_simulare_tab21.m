%% LABORATOR NR. 2 - Sarcina 3: Simulare regulatoare din TABELUL 2.1
%% Raspuns optim la referinta (p=0)
%% Pe aceeasi figura: comparatie regulatoare pe aceeasi linie (P, PI, PID)
%% Pe figura separata: comparatie regulatoare pe aceeasi coloana (criteriu)


%% Incarcare parametri
if ~exist('lab2_params.mat','file')
    fprintf('Rulati mai intai task1_identificare_regulatoare.m!\n');
    return;
end
load('lab2_params.mat');
s = tf('s');

%% Functia de transfer a partii fixate cu timp mort (Pade approx pt simulare)
% H_F(s) = Kf / (1 + T*s) * exp(-Tm*s)
% Folosim Pade de ordinul 3 pentru timp mort
[num_pade, den_pade] = pade(Tm, 3);
H_delay = tf(num_pade, den_pade);
H_plant = tf(Kf, [T 1]) * H_delay;
% Timp simulare
t_sim = 0:0.5:300;

%% =========================================================
%% SIMULARI TABELUL 2.1
%% =========================================================
fprintf('=== TABELUL 2.1 - Simulari (referinta treapta, p=0) ===\n\n');

% Ziegler-Nichols
[y_ZN_P,  t_out, c_ZN_P]  = simulate_reg('P',   KR_ZN_P,  0,         0,         H_plant, t_sim, s);
[y_ZN_PI, ~,     c_ZN_PI] = simulate_reg('PI',  KR_ZN_PI, TI_ZN_PI,  0,         H_plant, t_sim, s);
[y_ZN_PID,~,     c_ZN_PID]= simulate_reg('PID', KR_ZN_PID,TI_ZN_PID, TD_ZN_PID, H_plant, t_sim, s);

% Oppelt
[y_OP_P,  ~, c_OP_P]  = simulate_reg('P',   KR_OP_P,  0,         0,         H_plant, t_sim, s);
[y_OP_PI, ~, c_OP_PI] = simulate_reg('PI',  KR_OP_PI, TI_OP_PI,  0,         H_plant, t_sim, s);
[y_OP_PID,~, c_OP_PID]= simulate_reg('PID', KR_OP_PID,TI_OP_PID, TD_OP_PID, H_plant, t_sim, s);

% Chien-Hrones-Reswich
[y_CHR_P,  ~, c_CHR_P]  = simulate_reg('P',   KR_CHR_P,  0,          0,          H_plant, t_sim, s);
[y_CHR_PI, ~, c_CHR_PI] = simulate_reg('PI',  KR_CHR_PI, TI_CHR_PI,  0,          H_plant, t_sim, s);
[y_CHR_PID,~, c_CHR_PID]= simulate_reg('PID', KR_CHR_PID,TI_CHR_PID, TD_CHR_PID, H_plant, t_sim, s);

%% Performante
[s_ZN_P,  tr_ZN_P,  a_ZN_P]  = calc_perf(y_ZN_P,  t_out, 3);
[s_ZN_PI, tr_ZN_PI, a_ZN_PI] = calc_perf(y_ZN_PI, t_out, 3);
[s_ZN_PID,tr_ZN_PID,a_ZN_PID]= calc_perf(y_ZN_PID,t_out, 3);

[s_OP_P,  tr_OP_P,  a_OP_P]  = calc_perf(y_OP_P,  t_out, 3);
[s_OP_PI, tr_OP_PI, a_OP_PI] = calc_perf(y_OP_PI, t_out, 3);
[s_OP_PID,tr_OP_PID,a_OP_PID]= calc_perf(y_OP_PID,t_out, 3);

[s_CHR_P,  tr_CHR_P,  a_CHR_P]  = calc_perf(y_CHR_P,  t_out, 3);
[s_CHR_PI, tr_CHR_PI, a_CHR_PI] = calc_perf(y_CHR_PI, t_out, 3);
[s_CHR_PID,tr_CHR_PID,a_CHR_PID]= calc_perf(y_CHR_PID,t_out, 3);

%% Afisaj performante in consola
fprintf('%-35s %8s %10s %12s\n', 'Criteriu - Regulator', 'a_stp', 'sigma[%]', 'tr[min]');
fprintf('%s\n', repmat('-',1,70));
fprintf('%-35s %8.4f %10.2f %12.2f\n', 'Ziegler-Nichols - P',   a_ZN_P,  s_ZN_P,  tr_ZN_P);
fprintf('%-35s %8.4f %10.2f %12.2f\n', 'Ziegler-Nichols - PI',  a_ZN_PI, s_ZN_PI, tr_ZN_PI);
fprintf('%-35s %8.4f %10.2f %12.2f\n', 'Ziegler-Nichols - PID', a_ZN_PID,s_ZN_PID,tr_ZN_PID);
fprintf('%-35s %8.4f %10.2f %12.2f\n', 'Oppelt - P',   a_OP_P,  s_OP_P,  tr_OP_P);
fprintf('%-35s %8.4f %10.2f %12.2f\n', 'Oppelt - PI',  a_OP_PI, s_OP_PI, tr_OP_PI);
fprintf('%-35s %8.4f %10.2f %12.2f\n', 'Oppelt - PID', a_OP_PID,s_OP_PID,tr_OP_PID);
fprintf('%-35s %8.4f %10.2f %12.2f\n', 'CHR - P',   a_CHR_P,  s_CHR_P,  tr_CHR_P);
fprintf('%-35s %8.4f %10.2f %12.2f\n', 'CHR - PI',  a_CHR_PI, s_CHR_PI, tr_CHR_PI);
fprintf('%-35s %8.4f %10.2f %12.2f\n', 'CHR - PID', a_CHR_PID,s_CHR_PID,tr_CHR_PID);

%% =========================================================
%% FIGURA 1: Comparatie pe LINIE (P vs PI vs PID) - Tabelul 2.1
%%           O figura cu 3 subplot-uri (una per criteriu)
%% =========================================================
figure(1);
sgtitle('Tabelul 2.1 - Comparatie regulatoare pe aceeasi linie (criteriu)','FontSize',12,'FontWeight','bold');

subplot(3,1,1);
plot(t_out, y_ZN_P,  'b-',  'LineWidth',2, 'DisplayName','Ziegler-Nichols P'); hold on;
plot(t_out, y_OP_P,  'r--', 'LineWidth',2, 'DisplayName','Oppelt P');
plot(t_out, y_CHR_P, 'g-.', 'LineWidth',2, 'DisplayName','CHR P');
yline(1,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [min]'); ylabel('y');
title('Regulatoare P - comparatie criterii'); legend('Location','southeast');
xlim([0 300]);

subplot(3,1,2);
plot(t_out, y_ZN_PI,  'b-',  'LineWidth',2, 'DisplayName','Ziegler-Nichols PI'); hold on;
plot(t_out, y_OP_PI,  'r--', 'LineWidth',2, 'DisplayName','Oppelt PI');
plot(t_out, y_CHR_PI, 'g-.', 'LineWidth',2, 'DisplayName','CHR PI');
yline(1,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [min]'); ylabel('y');
title('Regulatoare PI - comparatie criterii'); legend('Location','southeast');
xlim([0 300]);

subplot(3,1,3);
plot(t_out, y_ZN_PID,  'b-',  'LineWidth',2, 'DisplayName','Ziegler-Nichols PID'); hold on;
plot(t_out, y_OP_PID,  'r--', 'LineWidth',2, 'DisplayName','Oppelt PID');
plot(t_out, y_CHR_PID, 'g-.', 'LineWidth',2, 'DisplayName','CHR PID');
yline(1,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [min]'); ylabel('y');
title('Regulatoare PID - comparatie criterii'); legend('Location','southeast');
xlim([0 300]);

%% =========================================================
%% FIGURA 2: Comparatie pe COLOANA (P, PI, PID pentru fiecare criteriu)
%%           O figura cu 3 subplot-uri (una per criteriu)
%% =========================================================
figure(2);
sgtitle('Tabelul 2.1 - Comparatie P/PI/PID pentru fiecare criteriu','FontSize',12,'FontWeight','bold');

subplot(3,1,1);
plot(t_out, y_ZN_P,   'b-',  'LineWidth',2, 'DisplayName','P'); hold on;
plot(t_out, y_ZN_PI,  'r--', 'LineWidth',2, 'DisplayName','PI');
plot(t_out, y_ZN_PID, 'g-.', 'LineWidth',2, 'DisplayName','PID');
yline(1,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [min]'); ylabel('y');
title('Criteriu Ziegler-Nichols'); legend('Location','southeast'); xlim([0 300]);

subplot(3,1,2);
plot(t_out, y_OP_P,   'b-',  'LineWidth',2, 'DisplayName','P'); hold on;
plot(t_out, y_OP_PI,  'r--', 'LineWidth',2, 'DisplayName','PI');
plot(t_out, y_OP_PID, 'g-.', 'LineWidth',2, 'DisplayName','PID');
yline(1,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [min]'); ylabel('y');
title('Criteriu Oppelt'); legend('Location','southeast'); xlim([0 300]);

subplot(3,1,3);
plot(t_out, y_CHR_P,   'b-',  'LineWidth',2, 'DisplayName','P'); hold on;
plot(t_out, y_CHR_PI,  'r--', 'LineWidth',2, 'DisplayName','PI');
plot(t_out, y_CHR_PID, 'g-.', 'LineWidth',2, 'DisplayName','PID');
yline(1,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [min]'); ylabel('y');
title('Criteriu Chien-Hrones-Reswich'); legend('Location','southeast'); xlim([0 300]);

fprintf('\nFigurile 1 si 2 generate pentru Tabelul 2.1.\n');
fprintf('Rulati task2_simulare_tab22.m pentru Tabelul 2.2.\n');

%% =========================================================
%% FUNCTII LOCALE (Trebuie mutate intotdeauna la final)
%% =========================================================
function [y_out, t_out, c_out] = simulate_reg(type, KR, TI, TD, H_plant, t_sim, s)
    Tf = 0.1 * TD;  % filtru derivativ
    switch type
        case 'P'
            HR = tf(KR, 1);
        case 'PI'
            HR = KR * (1 + 1/(TI*s));
        case 'PID'
            % PID realizabil cu filtru (q=1, Tf=0.1*TD)
            HR = KR * (1 + 1/(TI*s) + (TD*s)/(1 + Tf*s));
    end
    H_OL = HR * H_plant;
    H_CL = feedback(H_OL, 1);
    H_cmd = HR * feedback(1, H_plant * HR);  % semnal de comanda
    [y_out, t_out] = step(H_CL, t_sim);
    [c_out, ~]     = step(H_cmd, t_sim);
end

function [sigma, tr, astp] = calc_perf(y, t, band_pct)
    yst = y(end);
    ymax = max(y);
    sigma = (ymax - yst) / yst * 100;
    astp  = 1 - yst;
    band = band_pct/100;
    in_band = abs(y - yst) <= band * yst;
    out_idx = find(~in_band, 1, 'last');
    if isempty(out_idx)
        tr = t(1);
    else
        tr = t(out_idx);
    end
end