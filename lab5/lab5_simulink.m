%% LABORATOR NR. 5 - Construire modele Simulink
%% Schema monocontur (fig. 5.4) si schema in cascada (fig. 5.5)
%% Necesita Simulink instalat. Rulati dupa lab5_identificare.m

clear; clc; close all;

if ~exist('lab5_params.mat','file')
    error('Rulati mai intai lab5_identificare.m!');
end
load('lab5_params.mat');

%% =========================================================
%% NUMERATORI / NUMITORI PENTRU BLOCURI SIMULINK
%% =========================================================
% Subprocese
num_IT1 = K_IT1;      den_IT1 = [T1 1];
num_IT2 = K_IT2;      den_IT2 = [T2 1];
num_EE  = K_EE;       den_EE  = [T_EE 1];
num_TM1 = K_TM1;      den_TM1 = [T_TM1 1];
num_TM2 = K_TM2;      den_TM2 = [T_TM2 1];

% R2 - criteriul modulului: K_R2*(T_I2*s+1)/(T_I2*s)
num_R2_mod = K_R2     * [T_I2     1];  den_R2_mod = [T_I2     0];
% R2 - criteriul simetriei
num_R2_sim = K_R2_sim * [T_I2_sim 1];  den_R2_sim = [T_I2_sim 0];
% R1 - criteriul modulului
num_R1_mod = K_R1     * [T_I1     1];  den_R1_mod = [T_I1     0];
% Monocontur
num_R_mono = K_R_mono * [T_I_mono 1];  den_R_mono = [T_I_mono 0];

t_stop = 400;

fprintf('Parametri Simulink pregatiti.\n\n');

%% =========================================================
%% MODEL 1: SCHEMA MONOCONTUR (fig. 5.4)
%% =========================================================
model_mono = 'lab5_monocontur';
if bdIsLoaded(model_mono); close_system(model_mono,0); end
new_system(model_mono); open_system(model_mono);

% Blocuri
add_block('simulink/Sources/Step',              [model_mono '/w']);
add_block('simulink/Math Operations/Sum',        [model_mono '/Comp']);
add_block('simulink/Continuous/Transfer Fcn',    [model_mono '/R']);
add_block('simulink/Continuous/Transfer Fcn',    [model_mono '/HEE']);
add_block('simulink/Continuous/Transfer Fcn',    [model_mono '/HIT2']);
add_block('simulink/Sources/Step',               [model_mono '/p2']);
add_block('simulink/Math Operations/Sum',        [model_mono '/SumP2']);
add_block('simulink/Continuous/Transfer Fcn',    [model_mono '/HIT1']);
add_block('simulink/Sources/Step',               [model_mono '/p1']);
add_block('simulink/Math Operations/Sum',        [model_mono '/SumP1']);
add_block('simulink/Continuous/Transfer Fcn',    [model_mono '/HTM1']);
add_block('simulink/Sinks/Scope',                [model_mono '/Scope_y']);
add_block('simulink/Sinks/To Workspace',         [model_mono '/y_out']);
add_block('simulink/Sinks/To Workspace',         [model_mono '/c_out']);

% Parametri
set_param([model_mono '/w'],    'Time','0','Before','0','After','0.1','Position',[20,170,80,200]);
set_param([model_mono '/Comp'], 'Inputs','+-','Position',[140,165,180,205]);
set_param([model_mono '/R'],    'Numerator',mat2str(num_R_mono),'Denominator',mat2str(den_R_mono),'Position',[220,155,330,215]);
set_param([model_mono '/HEE'],  'Numerator',mat2str(num_EE),'Denominator',mat2str(den_EE),'Position',[370,155,460,215]);
set_param([model_mono '/HIT2'], 'Numerator',mat2str(num_IT2),'Denominator',mat2str(den_IT2),'Position',[500,155,590,215]);
set_param([model_mono '/p2'],   'Time','80','Before','0','After','1','Position',[500,60,580,90]);
set_param([model_mono '/SumP2'],'Inputs','++','Position',[620,155,680,215]);
set_param([model_mono '/HIT1'], 'Numerator',mat2str(num_IT1),'Denominator',mat2str(den_IT1),'Position',[720,155,810,215]);
set_param([model_mono '/p1'],   'Time','0','Before','0','After','0','Position',[720,60,800,90]);
set_param([model_mono '/SumP1'],'Inputs','++','Position',[840,155,900,215]);
set_param([model_mono '/HTM1'], 'Numerator',mat2str(num_TM1),'Denominator',mat2str(den_TM1),'Position',[720,290,810,330]);
set_param([model_mono '/Scope_y'],'Position',[950,165,1020,215]);
set_param([model_mono '/y_out'],'VariableName','y_mono','SaveFormat','Array','Position',[950,240,1050,270]);
set_param([model_mono '/c_out'],'VariableName','c_mono','SaveFormat','Array','Position',[220,240,320,270]);

% Conexiuni
add_line(model_mono,'w/1','Comp/1','autorouting','on');
add_line(model_mono,'Comp/1','R/1','autorouting','on');
add_line(model_mono,'R/1','HEE/1','autorouting','on');
add_line(model_mono,'R/1','c_out/1','autorouting','on');
add_line(model_mono,'HEE/1','HIT2/1','autorouting','on');
add_line(model_mono,'HIT2/1','SumP2/1','autorouting','on');
add_line(model_mono,'p2/1','SumP2/2','autorouting','on');
add_line(model_mono,'SumP2/1','HIT1/1','autorouting','on');
add_line(model_mono,'HIT1/1','SumP1/1','autorouting','on');
add_line(model_mono,'p1/1','SumP1/2','autorouting','on');
add_line(model_mono,'SumP1/1','Scope_y/1','autorouting','on');
add_line(model_mono,'SumP1/1','y_out/1','autorouting','on');
add_line(model_mono,'SumP1/1','HTM1/1','autorouting','on');
add_line(model_mono,'HTM1/1','Comp/2','autorouting','on');

set_param(model_mono,'StopTime',num2str(t_stop),'Solver','ode45');
save_system(model_mono,[model_mono '.slx']);
fprintf('Model salvat: %s.slx\n', model_mono);

%% =========================================================
%% MODEL 2: SCHEMA IN CASCADA (fig. 5.5)
%% =========================================================
model_casc = 'lab5_cascada';
if bdIsLoaded(model_casc); close_system(model_casc,0); end
new_system(model_casc); open_system(model_casc);

% Blocuri
add_block('simulink/Sources/Step',              [model_casc '/w']);
add_block('simulink/Math Operations/Sum',        [model_casc '/Comp1']);
add_block('simulink/Continuous/Transfer Fcn',    [model_casc '/R1']);
add_block('simulink/Math Operations/Sum',        [model_casc '/Comp2']);
add_block('simulink/Continuous/Transfer Fcn',    [model_casc '/R2']);
add_block('simulink/Continuous/Transfer Fcn',    [model_casc '/HEE']);
add_block('simulink/Continuous/Transfer Fcn',    [model_casc '/HIT2']);
add_block('simulink/Sources/Step',               [model_casc '/p2']);
add_block('simulink/Math Operations/Sum',        [model_casc '/SumP2']);
add_block('simulink/Continuous/Transfer Fcn',    [model_casc '/HIT1']);
add_block('simulink/Sources/Step',               [model_casc '/p1']);
add_block('simulink/Math Operations/Sum',        [model_casc '/SumP1']);
add_block('simulink/Continuous/Transfer Fcn',    [model_casc '/HTM1']);
add_block('simulink/Continuous/Transfer Fcn',    [model_casc '/HTM2']);
add_block('simulink/Sinks/Scope',                [model_casc '/Scope_y']);
add_block('simulink/Sinks/To Workspace',         [model_casc '/y_out']);
add_block('simulink/Sinks/To Workspace',         [model_casc '/c1_out']);
add_block('simulink/Sinks/To Workspace',         [model_casc '/c2_out']);

% Parametri
set_param([model_casc '/w'],    'Time','0','Before','0','After','0.1','Position',[20,215,80,245]);
set_param([model_casc '/Comp1'],'Inputs','+-','Position',[130,210,170,250]);
set_param([model_casc '/R1'],   'Numerator',mat2str(num_R1_mod),'Denominator',mat2str(den_R1_mod),'Position',[210,200,320,260]);
set_param([model_casc '/Comp2'],'Inputs','+-','Position',[360,210,400,250]);
set_param([model_casc '/R2'],   'Numerator',mat2str(num_R2_mod),'Denominator',mat2str(den_R2_mod),'Position',[440,200,550,260]);
set_param([model_casc '/HEE'],  'Numerator',mat2str(num_EE),'Denominator',mat2str(den_EE),'Position',[590,200,680,260]);
set_param([model_casc '/HIT2'], 'Numerator',mat2str(num_IT2),'Denominator',mat2str(den_IT2),'Position',[720,200,810,260]);
set_param([model_casc '/p2'],   'Time','80','Before','0','After','1','Position',[720,100,800,130]);
set_param([model_casc '/SumP2'],'Inputs','++','Position',[840,200,900,260]);
set_param([model_casc '/HIT1'], 'Numerator',mat2str(num_IT1),'Denominator',mat2str(den_IT1),'Position',[940,200,1030,260]);
set_param([model_casc '/p1'],   'Time','0','Before','0','After','0','Position',[940,100,1020,130]);
set_param([model_casc '/SumP1'],'Inputs','++','Position',[1060,200,1120,260]);
set_param([model_casc '/HTM1'], 'Numerator',mat2str(num_TM1),'Denominator',mat2str(den_TM1),'Position',[940,340,1030,380]);
set_param([model_casc '/HTM2'], 'Numerator',mat2str(num_TM2),'Denominator',mat2str(den_TM2),'Position',[720,340,810,380]);
set_param([model_casc '/Scope_y'],'Position',[1160,210,1230,260]);
set_param([model_casc '/y_out'],'VariableName','y_casc','SaveFormat','Array','Position',[1160,280,1260,310]);
set_param([model_casc '/c1_out'],'VariableName','c1_casc','SaveFormat','Array','Position',[210,280,310,310]);
set_param([model_casc '/c2_out'],'VariableName','c2_casc','SaveFormat','Array','Position',[440,280,540,310]);

% Conexiuni
add_line(model_casc,'w/1','Comp1/1','autorouting','on');
add_line(model_casc,'Comp1/1','R1/1','autorouting','on');
add_line(model_casc,'R1/1','Comp2/1','autorouting','on');
add_line(model_casc,'R1/1','c1_out/1','autorouting','on');
add_line(model_casc,'Comp2/1','R2/1','autorouting','on');
add_line(model_casc,'R2/1','HEE/1','autorouting','on');
add_line(model_casc,'R2/1','c2_out/1','autorouting','on');
add_line(model_casc,'HEE/1','HIT2/1','autorouting','on');
add_line(model_casc,'HIT2/1','SumP2/1','autorouting','on');
add_line(model_casc,'p2/1','SumP2/2','autorouting','on');
add_line(model_casc,'SumP2/1','HIT1/1','autorouting','on');
add_line(model_casc,'SumP2/1','HTM2/1','autorouting','on');
add_line(model_casc,'HIT1/1','SumP1/1','autorouting','on');
add_line(model_casc,'p1/1','SumP1/2','autorouting','on');
add_line(model_casc,'SumP1/1','Scope_y/1','autorouting','on');
add_line(model_casc,'SumP1/1','y_out/1','autorouting','on');
add_line(model_casc,'SumP1/1','HTM1/1','autorouting','on');
add_line(model_casc,'HTM1/1','Comp1/2','autorouting','on');
add_line(model_casc,'HTM2/1','Comp2/2','autorouting','on');

set_param(model_casc,'StopTime',num2str(t_stop),'Solver','ode45');
save_system(model_casc,[model_casc '.slx']);
fprintf('Model salvat: %s.slx\n', model_casc);

%% =========================================================
%% RULSIMULARI SI GRAFICE
%% =========================================================
fprintf('\nRulare simulari Simulink...\n');
try
    sim_m = sim(model_mono,'StopTime',num2str(t_stop));
    sim_c = sim(model_casc,'StopTime',num2str(t_stop));

    y_m = sim_m.y_mono;
    y_c = sim_c.y_casc;
    c_m = sim_m.c_mono;
    c2_c= sim_c.c2_casc;
    t_v = linspace(0, t_stop, length(y_m));

    figure(10);
    plot(t_v, y_m, 'b--','LineWidth',2,'DisplayName','Monocontur');
    hold on;
    plot(t_v, y_c, 'r-', 'LineWidth',2,'DisplayName','Cascada (R2 modul)');
    yline(0.1,'k:','LineWidth',1,'HandleVisibility','off');
    xline(80,'m:','LineWidth',1,'HandleVisibility','off');
    text(82, 0.02, 'p_2 apare', 'Color','m');
    grid on; xlabel('Timp [s]'); ylabel('y [bar sau u.r.]');
    title('Simulink - Fig. 5.6: Raspuns referinta + perturbatie treapta p_2');
    legend('Location','northeast'); xlim([0 t_stop]);

    figure(11);
    plot(t_v, c_m,  'b--','LineWidth',2,'DisplayName','c (monocontur)');
    hold on;
    plot(t_v, c2_c, 'r-', 'LineWidth',2,'DisplayName','c_2 (cascada)');
    grid on; xlabel('Timp [s]'); ylabel('Comanda [u.r.]');
    title('Simulink - Fig. 5.7: Semnalele de comanda');
    legend; xlim([0 t_stop]);

    fprintf('Figurile 10 si 11 generate cu succes.\n');
catch ME
    fprintf('Eroare simulare Simulink: %s\n', ME.message);
    fprintf('Verificati instalarea Simulink si rulati manual modelele.\n');
end

fprintf('\nModele Simulink disponibile:\n');
fprintf('  %s.slx  - Schema monocontur (fig. 5.4)\n', model_mono);
fprintf('  %s.slx  - Schema cascada    (fig. 5.5)\n', model_casc);
fprintf('\nPentru a testa alte tipuri de perturbatii:\n');
fprintf('  - Perturbatie treapta:   bloc p2: After=1, Time=80\n');
fprintf('  - Perturbatie rampa:     inlocuiti blocul Step cu Ramp\n');
fprintf('  - Perturbatie sinus:     inlocuiti cu Sine Wave (A=1, freq=0.1/2pi Hz)\n');
fprintf('  - Perturbatie p1!=0:     bloc p1: After=valoare_dorita, Time=moment\n');
fprintf('\nPentru R2 criteriul simetriei: modificati blocul R2:\n');
fprintf('  Numerator: %s\n', mat2str(num_R2_sim));
fprintf('  Denominator: %s\n', mat2str(den_R2_sim));
