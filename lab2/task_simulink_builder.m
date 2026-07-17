%% LABORATOR NR. 2 - Construire modele Simulink (.slx) automat
%% Creeaza schema din figura 2.1 pentru fiecare regulator (P, PI, PID)
%% din Tabelele 2.1 si 2.2, ruleaza simularea si salveaza rezultatele.
%%
%% CERINTA: Simulink trebuie instalat (toolbox Simulink).
%% Rulati DUPA task1_identificare_regulatoare.m
clear; clc; close all;

if ~exist('lab2_params.mat','file')
    error('Rulati mai intai task1_identificare_regulatoare.m!');
end
load('lab2_params.mat');

%% =========================================================
%% PARAMETRI PROCES
%% =========================================================
% Functia de transfer parte fixata identificata prin metoda tangentei:
% H_F(s) = Kf / (1 + T*s) * exp(-Tm*s)
% Reprezentata in Simulink ca: Transfer Fcn + Transport Delay
Kf_val = Kf;
T_val  = T;
Tm_val = Tm;
Tf_val = 0.1;   % factor filtru derivativ (relativ la TD)
t_stop = 300;   % durata simulare [min]

%% =========================================================
%% LISTA REGULATOARE DE SIMULAT
%% =========================================================
% {Nume criteriu, Tip reg, KR, TI, TD}
regs = {
    'ZN_P',        'P',   KR_ZN_P,    0,           0;
    'ZN_PI',       'PI',  KR_ZN_PI,   TI_ZN_PI,    0;
    'ZN_PID',      'PID', KR_ZN_PID,  TI_ZN_PID,   TD_ZN_PID;
    'Oppelt_P',    'P',   KR_OP_P,    0,           0;
    'Oppelt_PI',   'PI',  KR_OP_PI,   TI_OP_PI,    0;
    'Oppelt_PID',  'PID', KR_OP_PID,  TI_OP_PID,   TD_OP_PID;
    'CHR_ref_P',   'P',   KR_CHR_P,   0,           0;
    'CHR_ref_PI',  'PI',  KR_CHR_PI,  TI_CHR_PI,   0;
    'CHR_ref_PID', 'PID', KR_CHR_PID, TI_CHR_PID,  TD_CHR_PID;
    'Kop_ap_P',    'P',   KR_KP_P,    0,           0;
    'Kop_ap_PI',   'PI',  KR_KP_PI,   TI_KP_PI,    0;
    'Kop_ap_PID',  'PID', KR_KP_PID,  TI_KP_PID,   TD_KP_PID;
    'Kop_osc_P',   'P',   KR_KPo_P,   0,           0;
    'Kop_osc_PI',  'PI',  KR_KPo_PI,  TI_KPo_PI,   0;
    'Kop_osc_PID', 'PID', KR_KPo_PID, TI_KPo_PID,  TD_KPo_PID;
    'CHR_pert_P',  'P',   KR_CHRp_P,  0,           0;
    'CHR_pert_PI', 'PI',  KR_CHRp_PI, TI_CHRp_PI,  0;
    'CHR_pert_PID','PID', KR_CHRp_PID,TI_CHRp_PID, TD_CHRp_PID;
    'CC_P',        'P',   KR_CC_P,    0,           0;
    'CC_PI',       'PI',  KR_CC_PI,   TI_CC_PI,    0;
    'CC_PID',      'PID', KR_CC_PID,  TI_CC_PID,   TD_CC_PID;
};
n_regs = size(regs, 1);

%% =========================================================
%% CONSTRUIRE MODEL SIMULINK DE BAZA (schema fig. 2.1)
%% =========================================================
model_name = 'lab2_schema_fig21';
fprintf('Construire model Simulink: %s\n', model_name);

% Inchide modelul daca e deja deschis
if bdIsLoaded(model_name)
    close_system(model_name, 0);
end
new_system(model_name);
open_system(model_name);

% --- Pozitii blocuri (x, y, width, height) ---
pos_w    = [30,  130, 100, 160];   % Step (referinta w)
pos_sum  = [160, 130, 200, 170];   % Sumator comparator
pos_HR   = [260, 120, 380, 180];   % Regulator HR
pos_HF   = [460, 120, 580, 180];   % Parte fixata HF
pos_HFd  = [580, 120, 700, 180];   % Transport Delay (timp mort)
pos_p    = [460,  30, 580,  60];   % Step perturbatie p
pos_sump = [700, 120, 760, 180];   % Sumator perturbatie
pos_scope= [830, 110, 930, 190];   % Scope iesire y
pos_sc   = [460, 220, 580, 280];   % Scope comanda c
pos_to_w = [160, 220, 260, 260];   % To Workspace y
pos_to_c = [460, 290, 560, 320];   % To Workspace c

% --- Adaugare blocuri ---
% Referinta
add_block('simulink/Sources/Step', [model_name '/w']);
set_param([model_name '/w'], ...
    'Time','0','Before','0','After','1', ...
    'Position', pos_w);

% Sumator comparator (w - r)
add_block('simulink/Math Operations/Sum', [model_name '/Comp']);
set_param([model_name '/Comp'], 'Inputs','+-', 'Position', pos_sum);

% Regulator (Transfer Fcn - va fi actualizat pentru fiecare simulare)
add_block('simulink/Continuous/Transfer Fcn', [model_name '/HR']);
set_param([model_name '/HR'], 'Position', pos_HR);

% Parte fixata (Transfer Fcn)
add_block('simulink/Continuous/Transfer Fcn', [model_name '/HF']);
set_param([model_name '/HF'], ...
    'Numerator', num2str(Kf_val), ...
    'Denominator', mat2str([T_val, 1]), ...
    'Position', pos_HF);

% Transport Delay (timp mort)
add_block('simulink/Continuous/Transport Delay', [model_name '/Delay']);
set_param([model_name '/Delay'], ...
    'DelayTime', num2str(Tm_val), ...
    'Position', pos_HFd);

% Perturbatie p (treapta, setata la 0 implicit)
add_block('simulink/Sources/Step', [model_name '/p']);
set_param([model_name '/p'], ...
    'Time','0','Before','0','After','0', ...
    'Position', pos_p);

% Sumator perturbatie (iesire HF + p)
add_block('simulink/Math Operations/Sum', [model_name '/SumP']);
set_param([model_name '/SumP'], 'Inputs','++', 'Position', pos_sump);

% Scope iesire y
add_block('simulink/Sinks/Scope', [model_name '/Scope_y']);
set_param([model_name '/Scope_y'], 'Position', pos_scope);

% Scope comanda c
add_block('simulink/Sinks/Scope', [model_name '/Scope_c']);
set_param([model_name '/Scope_c'], 'Position', pos_sc);

% To Workspace - y
add_block('simulink/Sinks/To Workspace', [model_name '/y_out']);
set_param([model_name '/y_out'], ...
    'VariableName','y_sim', 'SaveFormat','Array', ...
    'Position', pos_to_w);

% To Workspace - c (semnal comanda)
add_block('simulink/Sinks/To Workspace', [model_name '/c_out']);
set_param([model_name '/c_out'], ...
    'VariableName','c_sim', 'SaveFormat','Array', ...
    'Position', pos_to_c);

% --- Conexiuni ---
add_line(model_name, 'w/1',     'Comp/1',   'autorouting','on');
add_line(model_name, 'Comp/1',  'HR/1',     'autorouting','on');
add_line(model_name, 'HR/1',    'HF/1',     'autorouting','on');
add_line(model_name, 'HR/1',    'Scope_c/1','autorouting','on');
add_line(model_name, 'HR/1',    'c_out/1',  'autorouting','on');
add_line(model_name, 'HF/1',    'Delay/1',  'autorouting','on');
add_line(model_name, 'Delay/1', 'SumP/1',   'autorouting','on');
add_line(model_name, 'p/1',     'SumP/2',   'autorouting','on');
add_line(model_name, 'SumP/1',  'Scope_y/1','autorouting','on');
add_line(model_name, 'SumP/1',  'y_out/1',  'autorouting','on');
add_line(model_name, 'SumP/1',  'Comp/2',   'autorouting','on');

% Parametri simulare
set_param(model_name, 'StopTime', num2str(t_stop), 'Solver','ode45');

% Salveaza modelul de baza
save_system(model_name, [model_name '.slx']);
fprintf('Model de baza salvat: %s.slx\n\n', model_name);

%% =========================================================
%% RULARE SIMULARE PENTRU FIECARE REGULATOR
%% =========================================================
fprintf('%-25s %-5s %10s %10s %10s\n', 'Criteriu','Tip','a_stp','sigma[%%]','tr[min]');
fprintf('%s\n', repmat('-',1,60));

results_slx = zeros(n_regs, 5);

for i = 1:n_regs
    reg_id  = regs{i,1};
    reg_type= regs{i,2};
    KR      = regs{i,3};
    TI      = regs{i,4};
    TD      = regs{i,5};
    Tf_d    = 0.1 * max(TD, 0.001);
    
    % Calcul numerator/numitor regulator
    [num_R, den_R] = reg_numden(reg_type, KR, TI, TD, Tf_d);
    
    % Actualizeaza parametrii regulatorului in model
    set_param([model_name '/HR'], ...
        'Numerator',   mat2str(num_R), ...
        'Denominator', mat2str(den_R));
    
    % Ruleaza simularea
    try
        sim_out = sim(model_name, 'StopTime', num2str(t_stop), ...
                      'SaveOutput','on');
        y = sim_out.y_sim;
        c = sim_out.c_sim;
        t = (0 : length(y)-1) * (t_stop / (length(y)-1));
        
        % Performante
        yst  = y(end);
        ymax = max(y);
        if yst > 0.01
            sigma = (ymax - yst)/yst*100;
            astp  = 1 - yst;
        else
            sigma = 0; astp = 1;
        end
        band = 0.03 * max(yst,0.01);
        in_b = abs(y - yst) <= band;
        out_i = find(~in_b, 1, 'last');
        if isempty(out_i); tr = 0; else; tr = t(out_i); end
        
        cmin = min(c); cmax = max(c);
        results_slx(i,:) = [astp, sigma, tr, cmin, cmax];
        
        fprintf('%-25s %-5s %10.4f %10.2f %10.2f\n', reg_id, reg_type, astp, sigma, tr);
    catch ME
        fprintf('%-25s %-5s  EROARE: %s\n', reg_id, reg_type, ME.message);
    end
end

%% =========================================================
%% GRAFICE COMPARATIVE (Tab 2.1 - pe linie)
%% =========================================================
% Re-simulam pentru grafice grupate
reg_groups_21 = {
    {'ZN_P','ZN_PI','ZN_PID'},     'Ziegler-Nichols';
    {'Oppelt_P','Oppelt_PI','Oppelt_PID'}, 'Oppelt';
    {'CHR_ref_P','CHR_ref_PI','CHR_ref_PID'}, 'CHR (referinta)';
};

colors = {'b-','r--','g-.'};
types  = {'P','PI','PID'};

figure(10);
sgtitle('Tabelul 2.1 - Simulink: comparatie criterii per tip regulator','FontSize',11,'FontWeight','bold');

for gi = 1:3
    group = reg_groups_21{gi,1};
    gname = reg_groups_21{gi,2};
    
    subplot(3,1,gi);
    hold on;
    for ri = 1:length(group)
        idx = find(strcmp(regs(:,1), group{ri}));
        if isempty(idx); continue; end
        
        [num_R, den_R] = reg_numden(regs{idx,2}, regs{idx,3}, regs{idx,4}, regs{idx,5}, ...
                                    0.1*max(regs{idx,5},0.001));
        
        set_param([model_name '/HR'], 'Numerator', mat2str(num_R), 'Denominator', mat2str(den_R));
        sim_out = sim(model_name, 'StopTime', num2str(t_stop));
        y = sim_out.y_sim;
        t = linspace(0, t_stop, length(y));
        
        plot(t, y, colors{ri}, 'LineWidth', 2, 'DisplayName', types{ri});
    end
    yline(1,'k:','LineWidth',1,'HandleVisibility','off');
    grid on; xlabel('Timp [min]'); ylabel('y');
    title(gname); legend('Location','southeast'); xlim([0 t_stop]);
end

figure(11);
sgtitle('Tabelul 2.1 - Simulink: comparatie criterii (acelasi tip)','FontSize',11,'FontWeight','bold');

all_names_21 = {'ZN','Oppelt','CHR'};
all_regs_21  = {
    {'ZN_P','Oppelt_P','CHR_ref_P'};
    {'ZN_PI','Oppelt_PI','CHR_ref_PI'};
    {'ZN_PID','Oppelt_PID','CHR_ref_PID'};
};
col3 = {'b-','r--','g-.'};

for ti = 1:3
    subplot(3,1,ti);
    hold on;
    for ci = 1:3
        idx = find(strcmp(regs(:,1), all_regs_21{ti}{ci}));
        if isempty(idx); continue; end
        
        [num_R, den_R] = reg_numden(regs{idx,2}, regs{idx,3}, regs{idx,4}, regs{idx,5}, ...
                                    0.1*max(regs{idx,5},0.001));
        
        set_param([model_name '/HR'], 'Numerator', mat2str(num_R), 'Denominator', mat2str(den_R));
        sim_out = sim(model_name, 'StopTime', num2str(t_stop));
        y = sim_out.y_sim;
        t = linspace(0, t_stop, length(y));
        
        plot(t, y, col3{ci}, 'LineWidth', 2, 'DisplayName', all_names_21{ci});
    end
    yline(1,'k:','LineWidth',1,'HandleVisibility','off');
    grid on; xlabel('Timp [min]'); ylabel('y');
    title(['Regulator ' types{ti}]); legend('Location','southeast'); xlim([0 t_stop]);
end

save_system(model_name, [model_name '.slx']);
fprintf('\nModel Simulink final salvat: %s.slx\n', model_name);
fprintf('Figurile 10 si 11 genereaza comparatiile pentru Tabelul 2.1.\n');
fprintf('\nNOTA: Pentru Tabelul 2.2 (perturbatii), setati in model:\n');
fprintf('  - Blocul "w" -> After = 0  (referinta nula)\n');
fprintf('  - Blocul "p" -> After = 1  (perturbatie treapta)\n');
fprintf('si re-rulati simularea cu regulatoarele corespunzatoare.\n');

%% =========================================================
%% HELPER: Numerator/Numitor pentru fiecare tip de regulator (Plasata corect la final)
%% =========================================================
function [num_R, den_R] = reg_numden(type, KR, TI, TD, Tf)
    switch type
        case 'P'
            num_R = KR;
            den_R = 1;
        case 'PI'
            % KR*(TI*s + 1)/(TI*s)
            num_R = KR * [TI, 1];
            den_R = [TI, 0];
        case 'PID'
            % KR*(1 + 1/(TI*s) + TD*s/(1+Tf*s))
            % = KR * [TI*Tf*s^2*(1) + TI*s + Tf*s^2 + s + TI*TD*s^2] / (TI*s*(1+Tf*s))
            % Forma: KR*(TI*Tf*s^2 + (TI + TI*TD/TI + ...))
            % Calcul direct:
            % H_PID = KR*(1 + 1/(TI*s) + TD*s/(1+Tf*s))
            % Numitor comun: TI*s*(1+Tf*s)
            % Numarator: TI*s*(1+Tf*s) + (1+Tf*s) + TI*TD*s^2
            %           = TI*Tf*s^2 + TI*s + Tf*s + 1 + TI*TD*s^2
            %           = (TI*Tf + TI*TD)*s^2 + (TI+Tf)*s + 1
            num_R = KR * [(TI*Tf + TI*TD), (TI + Tf), 1];
            den_R = [TI*Tf, TI, 0];
    end
end