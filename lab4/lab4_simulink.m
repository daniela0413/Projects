%% LABORATOR NR. 4 - Construire modele Simulink
%% Schema monocontur (fig. 4.8) si schema feedforward cu bloc de compensare (fig. 4.12)
%% Necesita Simulink instalat. Rulati dupa lab4_identificare.m

clear; clc; close all;

if ~exist('lab4_params.mat','file')
    error('Rulati mai intai lab4_identificare.m!');
end
load('lab4_params.mat');

%% =========================================================
%% PARAMETRI TRANSFER FUNCTIONS (numitori/numaratori pentru blocuri Simulink)
%% =========================================================
% H_IT = K_IT / (1 + T*s)
num_IT = K_IT;          den_IT = [T 1];
% H_EE = 1 / (1 + T_EE*s)
num_EE = 1;             den_EE = [T_EE 1];
% H_TM1 = 1 / (1 + T_TM1*s)
num_TM1 = 1;            den_TM1 = [T_TM1 1];
% H_TM2 = 1 / (1 + T_TM2*s)
num_TM2 = 1;            den_TM2 = [T_TM2 1];

% Regulator PI: K_R*(T_I*s + 1)/(T_I*s)
num_R1 = K_R_modul * [T_I_modul 1];
den_R1 = [T_I_modul 0];

% Bloc compensare realizabil: (1+T*s)*(1+T_EE*s)*(1+T_TM2*s) / (K_IT*(1+Tf*s)^3)
num_BC = conv(conv([T 1],[T_EE 1]),[T_TM2 1]);
den_BC = K_IT * conv(conv([Tf 1],[Tf 1]),[Tf 1]);

% Bloc compensare simplificat: (1+T*s)*(1+T_EE*s) / (K_IT*(1+Tf*s)^2)
num_BC_s = conv([T 1],[T_EE 1]);
den_BC_s = K_IT * conv([Tf 1],[Tf 1]);

t_stop = 150;

fprintf('Parametri pregatiti. Construire modele Simulink...\n\n');

%% =========================================================
%% MODEL 1: SCHEMA MONOCONTUR (fig. 4.8 echivalent)
%% =========================================================
model_mono = 'lab4_monocontur';
if bdIsLoaded(model_mono); close_system(model_mono,0); end
new_system(model_mono);
open_system(model_mono);

% Blocuri
add_block('simulink/Sources/Step',              [model_mono '/w']);
add_block('simulink/Math Operations/Sum',        [model_mono '/Comp']);
add_block('simulink/Continuous/Transfer Fcn',    [model_mono '/HR']);
add_block('simulink/Continuous/Transfer Fcn',    [model_mono '/HEE']);
add_block('simulink/Continuous/Transfer Fcn',    [model_mono '/HIT']);
add_block('simulink/Sources/Step',               [model_mono '/p']);
add_block('simulink/Math Operations/Sum',        [model_mono '/SumP']);
add_block('simulink/Continuous/Transfer Fcn',    [model_mono '/HTM1']);
add_block('simulink/Sinks/Scope',                [model_mono '/Scope_y']);
add_block('simulink/Sinks/To Workspace',         [model_mono '/y_out']);
add_block('simulink/Sinks/To Workspace',         [model_mono '/c_out']);

% Parametri
set_param([model_mono '/w'],   'Time','0','Before','0','After','1','Position',[30,130,90,160]);
set_param([model_mono '/Comp'],'Inputs','+-','Position',[150,130,190,170]);
set_param([model_mono '/HR'],  'Numerator',mat2str(num_R1),'Denominator',mat2str(den_R1),'Position',[230,115,350,175]);
set_param([model_mono '/HEE'], 'Numerator',mat2str(num_EE),'Denominator',mat2str(den_EE),'Position',[400,115,500,175]);
set_param([model_mono '/HIT'], 'Numerator',mat2str(num_IT),'Denominator',mat2str(den_IT),'Position',[540,115,640,175]);
set_param([model_mono '/p'],   'Time','50','Before','0','After','1','Position',[540,30,620,60]);
set_param([model_mono '/SumP'],'Inputs','++','Position',[660,120,710,180]);
set_param([model_mono '/HTM1'],'Numerator',mat2str(num_TM1),'Denominator',mat2str(den_TM1),'Position',[540,220,640,260]);
set_param([model_mono '/Scope_y'],'Position',[760,130,840,180]);
set_param([model_mono '/y_out'],'VariableName','y_mono','SaveFormat','Array','Position',[760,200,860,230]);
set_param([model_mono '/c_out'],'VariableName','c_mono','SaveFormat','Array','Position',[230,200,330,230]);

% Conexiuni
add_line(model_mono,'w/1','Comp/1','autorouting','on');
add_line(model_mono,'Comp/1','HR/1','autorouting','on');
add_line(model_mono,'HR/1','HEE/1','autorouting','on');
add_line(model_mono,'HR/1','c_out/1','autorouting','on');
add_line(model_mono,'HEE/1','HIT/1','autorouting','on');
add_line(model_mono,'HIT/1','SumP/1','autorouting','on');
add_line(model_mono,'p/1','SumP/2','autorouting','on');
add_line(model_mono,'SumP/1','Scope_y/1','autorouting','on');
add_line(model_mono,'SumP/1','y_out/1','autorouting','on');
add_line(model_mono,'SumP/1','HTM1/1','autorouting','on');
add_line(model_mono,'HTM1/1','Comp/2','autorouting','on');

set_param(model_mono,'StopTime',num2str(t_stop),'Solver','ode45');
save_system(model_mono,[model_mono '.slx']);
fprintf('Model salvat: %s.slx\n', model_mono);

%% =========================================================
%% MODEL 2: SCHEMA FEEDFORWARD - Varianta 1 (fig. 4.2)
%% Perturbatia pe iesirea IT, BC pe reactia de la perturbatie
%% =========================================================
model_ff = 'lab4_feedforward';
if bdIsLoaded(model_ff); close_system(model_ff,0); end
new_system(model_ff);
open_system(model_ff);

% Blocuri
add_block('simulink/Sources/Step',           [model_ff '/w']);
add_block('simulink/Math Operations/Sum',     [model_ff '/Comp_w']);
add_block('simulink/Continuous/Transfer Fcn', [model_ff '/HR1']);
add_block('simulink/Math Operations/Sum',     [model_ff '/Sum_c']);
add_block('simulink/Continuous/Transfer Fcn', [model_ff '/HEE']);
add_block('simulink/Continuous/Transfer Fcn', [model_ff '/HIT']);
add_block('simulink/Sources/Step',            [model_ff '/p']);
add_block('simulink/Math Operations/Sum',     [model_ff '/SumP']);
add_block('simulink/Continuous/Transfer Fcn', [model_ff '/HTM1']);
add_block('simulink/Continuous/Transfer Fcn', [model_ff '/HTM2']);
add_block('simulink/Continuous/Transfer Fcn', [model_ff '/HBC']);
add_block('simulink/Sinks/Scope',             [model_ff '/Scope_y']);
add_block('simulink/Sinks/To Workspace',      [model_ff '/y_out']);
add_block('simulink/Sinks/To Workspace',      [model_ff '/c_out']);

% Parametri blocuri
set_param([model_ff '/w'],      'Time','0','Before','0','After','1','Position',[30,200,90,230]);
set_param([model_ff '/Comp_w'], 'Inputs','+-','Position',[150,195,190,235]);
set_param([model_ff '/HR1'],    'Numerator',mat2str(num_R1),'Denominator',mat2str(den_R1),'Position',[230,185,350,245]);
set_param([model_ff '/Sum_c'],  'Inputs','+-','Position',[400,195,440,235]);
set_param([model_ff '/HEE'],    'Numerator',mat2str(num_EE),'Denominator',mat2str(den_EE),'Position',[480,185,580,245]);
set_param([model_ff '/HIT'],    'Numerator',mat2str(num_IT),'Denominator',mat2str(den_IT),'Position',[620,185,720,245]);
set_param([model_ff '/p'],      'Time','50','Before','0','After','1','Position',[820,50,900,80]);
set_param([model_ff '/SumP'],   'Inputs','++','Position',[740,185,800,245]);
set_param([model_ff '/HTM1'],   'Numerator',mat2str(num_TM1),'Denominator',mat2str(den_TM1),'Position',[620,310,720,360]);
set_param([model_ff '/HTM2'],   'Numerator',mat2str(num_TM2),'Denominator',mat2str(den_TM2),'Position',[820,100,920,140]);
set_param([model_ff '/HBC'],    'Numerator',mat2str(num_BC_s),'Denominator',mat2str(den_BC_s),'Position',[640,50,760,100]);
set_param([model_ff '/Scope_y'],'Position',[840,195,920,245]);
set_param([model_ff '/y_out'],  'VariableName','y_ff','SaveFormat','Array','Position',[840,265,940,295]);
set_param([model_ff '/c_out'],  'VariableName','c_ff','SaveFormat','Array','Position',[400,265,500,295]);

% Conexiuni feedforward
add_line(model_ff,'w/1','Comp_w/1','autorouting','on');
add_line(model_ff,'Comp_w/1','HR1/1','autorouting','on');
add_line(model_ff,'HR1/1','Sum_c/1','autorouting','on');
add_line(model_ff,'Sum_c/1','HEE/1','autorouting','on');
add_line(model_ff,'Sum_c/1','c_out/1','autorouting','on');
add_line(model_ff,'HEE/1','HIT/1','autorouting','on');
add_line(model_ff,'HIT/1','SumP/1','autorouting','on');
add_line(model_ff,'p/1','SumP/2','autorouting','on');
add_line(model_ff,'p/1','HTM2/1','autorouting','on');
add_line(model_ff,'HTM2/1','HBC/1','autorouting','on');
add_line(model_ff,'HBC/1','Sum_c/2','autorouting','on');
add_line(model_ff,'SumP/1','Scope_y/1','autorouting','on');
add_line(model_ff,'SumP/1','y_out/1','autorouting','on');
add_line(model_ff,'SumP/1','HTM1/1','autorouting','on');
add_line(model_ff,'HTM1/1','Comp_w/2','autorouting','on');

set_param(model_ff,'StopTime',num2str(t_stop),'Solver','ode45');
save_system(model_ff,[model_ff '.slx']);
fprintf('Model salvat: %s.slx\n', model_ff);

%% =========================================================
%% RULARE SIMULARE SI GRAFICE
%% =========================================================
fprintf('\nRulare simulari Simulink...\n');

% Monocontur - treapta perturbatie la t=50s
try
    sim_m = sim(model_mono,'StopTime',num2str(t_stop));
    y_m   = sim_m.y_mono;
    c_m   = sim_m.c_mono;
    t_vec = linspace(0, t_stop, length(y_m));

    % Feedforward
    sim_f = sim(model_ff,'StopTime',num2str(t_stop));
    y_f   = sim_f.y_ff;
    c_f   = sim_f.c_ff;

    figure(10);
    plot(t_vec, y_m, 'b-',  'LineWidth',2, 'DisplayName','Monocontur');
    hold on;
    plot(t_vec, y_f, 'r--', 'LineWidth',2, 'DisplayName','Feedforward (simplificat)');
    yline(1,'k:','LineWidth',1,'HandleVisibility','off');
    grid on; xlabel('Timp [s]'); ylabel('y [u.r.]');
    title('Simulink - Raspuns la referinta treapta + perturbatie treapta (t=50s)');
    legend('Location','southeast'); xlim([0 t_stop]);

    figure(11);
    plot(t_vec, c_m, 'b-',  'LineWidth',2, 'DisplayName','c_3 Monocontur');
    hold on;
    plot(t_vec, c_f, 'r--', 'LineWidth',2, 'DisplayName','c_3 Feedforward');
    grid on; xlabel('Timp [s]'); ylabel('c_3 [%]');
    title('Simulink - Semnalul de comanda final c_3');
    legend; xlim([0 t_stop]);

    fprintf('Figurile 10 si 11 generate cu succes.\n');
catch ME
    fprintf('Eroare simulare Simulink: %s\n', ME.message);
    fprintf('Verificati ca Simulink este instalat si rulati manual modelele.\n');
end

fprintf('\nModele Simulink disponibile:\n');
fprintf('  %s.slx - Schema monocontur\n', model_mono);
fprintf('  %s.slx - Schema feedforward (Varianta 1 - fig. 4.2)\n', model_ff);
fprintf('\nPentru a modifica tipul perturbatiei:\n');
fprintf('  - Blocul "p": schimbati After=1 (treapta), sau conectati un bloc Ramp/Sine Wave\n');
fprintf('  - Blocul "HBC": schimbati num/den pentru forma realizabila/simplificata/proportionala\n');
