%% LABORATOR NR. 2 - Simulink pentru Sarcina 5
%% Criteriul Ziegler-Nichols bazat pe aducerea la limita de stabilitate
%%
%% H_f2(s) = 3.3 / ((1+11s)*(1+22s)) * exp(-5s)   [minute]
%%
%% Pasi:
%%   1. Construieste schema Simulink cu regulator P
%%   2. Creste KR pana la oscilatie intretinuta => K_Rlim, T_lim
%%   3. Calculeaza regulatoarele P, PI, PID (Tabelul 2.3)
%%   4. Simuleaza si compara raspunsurile
clear; clc; close all;

%% =========================================================
%% PARAMETRI PROCES SARCINA 5
%% =========================================================
Kf2  = 3.3;
T12  = 11;    % min
T22  = 22;    % min
Tm2  = 5;     % min (timp mort)
t_stop2 = 200;

model2 = 'lab2_schema_sarcina5';

%% =========================================================
%% CONSTRUIRE MODEL SIMULINK
%% =========================================================
fprintf('Construire model Simulink: %s\n', model2);

if bdIsLoaded(model2)
    close_system(model2, 0);
end
new_system(model2);
open_system(model2);

% Blocuri
add_block('simulink/Sources/Step',              [model2 '/w']);
add_block('simulink/Math Operations/Sum',        [model2 '/Comp']);
add_block('simulink/Continuous/Transfer Fcn',    [model2 '/HR']);
add_block('simulink/Continuous/Transfer Fcn',    [model2 '/HF2']);
add_block('simulink/Continuous/Transport Delay', [model2 '/Delay2']);
add_block('simulink/Sources/Step',               [model2 '/p']);
add_block('simulink/Math Operations/Sum',        [model2 '/SumP']);
add_block('simulink/Sinks/Scope',                [model2 '/Scope_y']);
add_block('simulink/Sinks/To Workspace',         [model2 '/y_out']);
add_block('simulink/Sinks/To Workspace',         [model2 '/c_out']);

% Pozitii
set_param([model2 '/w'],       'Position',[30,130,100,160],  'Time','0','Before','0','After','1');
set_param([model2 '/Comp'],    'Position',[160,130,200,170], 'Inputs','+-');
set_param([model2 '/HR'],      'Position',[260,120,380,180]);
set_param([model2 '/HF2'],     'Position',[460,120,580,180], ...
    'Numerator', num2str(Kf2), ...
    'Denominator', mat2str(conv([T12 1],[T22 1])));
set_param([model2 '/Delay2'],  'Position',[600,120,720,180], 'DelayTime', num2str(Tm2));
set_param([model2 '/p'],       'Position',[600,30,700,60],   'Time','0','Before','0','After','0');
set_param([model2 '/SumP'],    'Position',[740,120,800,180], 'Inputs','++');
set_param([model2 '/Scope_y'], 'Position',[840,120,920,180]);
set_param([model2 '/y_out'],   'Position',[840,200,940,230], 'VariableName','y2_sim','SaveFormat','Array');
set_param([model2 '/c_out'],   'Position',[260,200,360,230], 'VariableName','c2_sim','SaveFormat','Array');

% Conexiuni
add_line(model2, 'w/1',      'Comp/1',   'autorouting','on');
add_line(model2, 'Comp/1',   'HR/1',     'autorouting','on');
add_line(model2, 'HR/1',     'HF2/1',    'autorouting','on');
add_line(model2, 'HR/1',     'c_out/1',  'autorouting','on');
add_line(model2, 'HF2/1',    'Delay2/1', 'autorouting','on');
add_line(model2, 'Delay2/1', 'SumP/1',   'autorouting','on');
add_line(model2, 'p/1',      'SumP/2',   'autorouting','on');
add_line(model2, 'SumP/1',   'Scope_y/1','autorouting','on');
add_line(model2, 'SumP/1',   'y_out/1',  'autorouting','on');
add_line(model2, 'SumP/1',   'Comp/2',   'autorouting','on');

set_param(model2, 'StopTime', num2str(t_stop2), 'Solver','ode45');

%% =========================================================
%% PAS 1: Gasire K_Rlim prin crestere progresiva a KR (regulator P)
%% =========================================================
fprintf('\nCautare K_Rlim (regulator P, crestem KR pana la oscilatie)...\n');
KR_search = 0.05:0.05:10;
KR_lim    = NaN;
T_lim     = NaN;

for KR_try = KR_search
    % Seteaza regulator P
    set_param([model2 '/HR'], 'Numerator', num2str(KR_try), 'Denominator', '1');
    try
        sim_out = sim(model2, 'StopTime', num2str(t_stop2));
        y_try   = sim_out.y2_sim;
        
        % Detectam oscilatie intretinuta: variatia in ultima treime e semnificativa
        y_last  = y_try(round(end*2/3):end);
        amp_var = max(y_last) - min(y_last);
        if amp_var > 0.05 * max(abs(y_try))   % oscilatie detectata
            KR_lim = KR_try;
            % Estimam perioada: cautam doua maxime consecutive in y_last
            [pks, locs] = findpeaks(y_last);
            if length(locs) >= 2
                dt = t_stop2 / (length(y_try)-1);
                T_lim = mean(diff(locs)) * dt;
            end
            break;
        end
    catch
        % Sistem instabil - am depasit limita
        KR_lim = KR_try - 0.05;
        break;
    end
end

if isnan(KR_lim) || KR_lim <= 0
    fprintf('ATENTIE: K_Rlim nu s-a detectat automat. Se foloseste valoarea din exemplul lucrarii.\n');
    KR_lim = 1.03853;
    T_lim  = 13.76;
end

if isnan(T_lim) || T_lim <= 0
    T_lim = 13.76;  % valoare din lucrare ca fallback
end

fprintf('K_Rlim = %.5f\n', KR_lim);
fprintf('T_lim  = %.4f min\n', T_lim);

%% =========================================================
%% PAS 2: Calculul regulatoarelor (Tabelul 2.3)
%% =========================================================
fprintf('\n--- Parametri regulatoare (Tabelul 2.3) ---\n');
KR_P   = 0.5  * KR_lim;

%% Corectat text LaTeX inline conform regulilor locale: p% -> procente simple, fara simboluri periculoase
KR_PI  = 0.45 * KR_lim;  
TI_PI  = 0.8 * T_lim;

KR_PID = 0.75 * KR_lim;  
TI_PID = 0.6 * T_lim;  
TD_PID = 0.1 * T_lim;
Tf_PID = 0.1 * TD_PID;

fprintf('P:   KR = 0.5 * %.5f = %.5f\n', KR_lim, KR_P);
fprintf('PI:  KR = 0.45 * %.5f = %.5f,  TI = 0.8 * %.4f = %.4f min\n', KR_lim, KR_PI, T_lim, TI_PI);
fprintf('PID: KR = 0.75 * %.5f = %.5f,  TI = 0.6 * %.4f = %.4f min,  TD = 0.1 * %.4f = %.4f min\n', ...
    KR_lim, KR_PID, T_lim, TI_PID, T_lim, TD_PID);

fprintf('\nRegulator PI (conform exemplului din lucrare, ec. 2.10):\n');
fprintf('H_R_PI(s) = %.4f*(1 + 1/(%.4f*s))\n', KR_PI, TI_PI);

%% =========================================================
%% PAS 3: Simulare cu regulatoarele calculate
%% =========================================================
% --- Regulator P ---
set_param([model2 '/HR'], 'Numerator', num2str(KR_P), 'Denominator', '1');
sim_P = sim(model2, 'StopTime', num2str(t_stop2));
y_P   = sim_P.y2_sim;
c_P   = sim_P.c2_sim;
t_P   = linspace(0, t_stop2, length(y_P)); % Vector de timp dedicat pentru P

% --- Regulator PI ---
num_PI2 = KR_PI * [TI_PI, 1];
den_PI2 = [TI_PI, 0];
set_param([model2 '/HR'], 'Numerator', mat2str(num_PI2), 'Denominator', mat2str(den_PI2));
sim_PI = sim(model2, 'StopTime', num2str(t_stop2));
y_PI   = sim_PI.y2_sim;
c_PI   = sim_PI.c2_sim;
t_PI   = linspace(0, t_stop2, length(y_PI)); % Vector de timp dedicat pentru PI

% --- Regulator PID realizabil ---
num_PID2 = KR_PID * [(TI_PID*Tf_PID + TI_PID*TD_PID), (TI_PID + Tf_PID), 1];
den_PID2 = [TI_PID*Tf_PID, TI_PID, 0];
set_param([model2 '/HR'], 'Numerator', mat2str(num_PID2), 'Denominator', mat2str(den_PID2));
sim_PID = sim(model2, 'StopTime', num2str(t_stop2));
y_PID   = sim_PID.y2_sim;
c_PID   = sim_PID.c2_sim;
t_PID   = linspace(0, t_stop2, length(y_PID)); % Vector de timp dedicat pentru PID

%% =========================================================
%% CALCUL PERFORMANTE (Fiecare cu timpul lui corect)
%% =========================================================
[sig_P,  tr_P,  a_P]  = perf(y_P,  t_P);
[sig_PI, tr_PI, a_PI] = perf(y_PI, t_PI);
[sig_PID,tr_PID,a_PID]= perf(y_PID, t_PID);

fprintf('\n--- Performante Sarcina 5 (treapta unitara) ---\n');
fprintf('%-8s %10s %10s %10s\n','Reg.','a_stp','sigma[%%]','tr[min]');
fprintf('%-8s %10.4f %10.2f %10.2f\n','P',  a_P,  sig_P,  tr_P);
fprintf('%-8s %10.4f %10.2f %10.2f\n','PI', a_PI, sig_PI, tr_PI);
fprintf('%-8s %10.4f %10.2f %10.2f\n','PID',a_PID,sig_PID,tr_PID);

%% =========================================================
%% GRAFICE COMPARATIVE (Folosind vectorii de timp corecti)
%% =========================================================
figure(20);
plot(t_P, y_P,   'b-',  'LineWidth',2, 'DisplayName', ...
    sprintf('P (KR=%.4f): \\sigma=%.1f%%, t_r=%.1f min', KR_P, sig_P, tr_P));
hold on;
plot(t_PI, y_PI,  'r--', 'LineWidth',2, 'DisplayName', ...
    sprintf('PI (KR=%.4f, TI=%.4f): \\sigma=%.1f%%, t_r=%.1f min', KR_PI, TI_PI, sig_PI, tr_PI));
plot(t_PID, y_PID, 'g-.', 'LineWidth',2, 'DisplayName', ...
    sprintf('PID (KR=%.4f): \\sigma=%.1f%%, t_r=%.1f min', KR_PID, sig_PID, tr_PID));

yline(1,'k:','LineWidth',1,'HandleVisibility','off');
yline(1.03,'g:','LineWidth',0.8,'HandleVisibility','off');
yline(0.97,'g:','LineWidth',0.8,'HandleVisibility','off');

grid on; xlabel('Timp [min]'); ylabel('y');
title(sprintf('Sarcina 5 - Ziegler-Nichols limita stabilitate\nK_{Rlim}=%.5f, T_{lim}=%.4f min', KR_lim, T_lim));
legend('Location','northeast'); xlim([0 t_stop2]);

figure(21);
plot(t_P, c_P,   'b-',  'LineWidth',2, 'DisplayName','c (regulator P)');
hold on;
plot(t_PI, c_PI,  'r--', 'LineWidth',2, 'DisplayName','c (regulator PI)');
plot(t_PID, c_PID, 'g-.', 'LineWidth',2, 'DisplayName','c (regulator PID)');

grid on; xlabel('Timp [min]'); ylabel('c');
title('Sarcina 5 - Evolutia semnalelor de comanda');
legend('Location','northeast'); xlim([0 t_stop2]);

save_system(model2, [model2 '.slx']);
fprintf('\nModel salvat: %s.slx\n', model2);
fprintf('Figura 20: Raspunsuri P/PI/PID\nFigura 21: Semnale de comanda\n');

%% =========================================================
%% FUNCTII LOCALE (Plasate obligatoriu la sfarsit)
%% =========================================================
function [sig, tr, astp] = perf(y, t)
    yst = y(end); ymax = max(y);
    if yst > 0.01
        sig = (ymax-yst)/yst*100; astp = 1-yst;
    else
        sig = 0; astp = 1;
    end
    in_b = abs(y-yst) <= 0.03*max(yst,0.01);
    oi = find(~in_b,1,'last');
    if isempty(oi)
        tr = 0; 
    else 
        tr = t(oi); 
    end
end