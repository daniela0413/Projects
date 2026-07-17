%% LABORATOR NR. 7 - Construire modele Simulink
%% Schema metoda releului (fig. 7.6) si schema reglare turatie (fig. 7.8)
%% Necesita Simulink instalat + modelul motorului asincron
clear; clc; close all;

if ~exist('lab7_params.mat','file')
    error('Rulati mai intai lab7_metoda_releului.m!');
end
load('lab7_params.mat');

%% =========================================================
%% CREAZA SUBSISTEMUL MODEL MOTOR ASINCRON (Level-2 S-Function)
%% =========================================================
fprintf('=== CONSTRUIRE MODELE SIMULINK ===\n\n');

% Definim codul ca un cell array de linii (folosim punct si virgula 
% pentru a forta un vector coloana si a evita erorile de concatenare)
sfunc_lines = {
    'function motor_asincron_sfunc(block)';
    '    setup(block);';
    'end';
    '';
    'function setup(block)';
    '    % 2 Intrari: ua, ub';
    '    block.NumInputPorts  = 1;';
    '    block.InputPort(1).Dimensions = 2;';
    '    block.InputPort(1).DirectFeedthrough = false;';
    '    ';
    '    % 1 Iesire: n [rot/min]';
    '    block.NumOutputPorts = 1;';
    '    block.OutputPort(1).Dimensions = 1;';
    '    ';
    '    % 5 Stari continue: [phi_a, phi_b, ia, ib, omega]';
    '    block.NumContStates = 5;';
    '    ';
    '    block.SampleTimes = [0 0]; % Continuu';
    '    ';
    '    block.RegBlockMethod(''InitializeConditions'', @InitializeConditions);';
    '    block.RegBlockMethod(''Derivatives'',          @Derivatives);';
    '    block.RegBlockMethod(''Outputs'',              @Outputs);';
    'end';
    '';
    'function InitializeConditions(block)';
    '    block.ContStates.Data = zeros(5,1);';
    'end';
    '';
    'function Outputs(block)';
    '    x = block.ContStates.Data;';
    '    omega = x(5);';
    '    block.OutputPort(1).Data = (30/pi) * omega;';
    'end';
    '';
    'function Derivatives(block)';
    '    J=0.4; Kf=0.1115; Rr=0.156; Rs=0.294;';
    '    Lr=0.0417; Ls=0.0424; LM=0.041; MR=0;';
    '    alpha=Rr/Lr; beta=LM/(Ls*Lr); gamma=1-LM^2/(Ls*Lr);';
    '    ';
    '    x = block.ContStates.Data;';
    '    u = block.InputPort(1).Data;';
    '    ';
    '    phi_a=x(1); phi_b=x(2); ia=x(3); ib=x(4); omega=x(5);';
    '    ua=u(1); ub=u(2);';
    '    ';
    '    dphi_a = -alpha*phi_a - omega*phi_b + LM*alpha*ia;';
    '    dphi_b = -alpha*phi_b + omega*phi_a + LM*alpha*ib;';
    '    dia    = -beta*dphi_a + (1/(gamma*Ls))*(ua - Rs*ia);';
    '    dib    = -beta*dphi_b + (1/(gamma*Ls))*(ub - Rs*ib);';
    '    domega = (1/J)*(LM/Lr)*(phi_a*ib - phi_b*ia) - (Kf/J)*omega - MR/J;';
    '    ';
    '    block.Derivatives.Data = [dphi_a; dphi_b; dia; dib; domega];';
    'end'
};

% Scriem fisierul linie cu linie, fortand carriage return corect (\r\n)
fid = fopen('motor_asincron_sfunc.m', 'w');
for i = 1:length(sfunc_lines)
    fprintf(fid, '%s\r\n', sfunc_lines{i});
end
fclose(fid);
fprintf('S-Function Level-2 salvata cu succes: motor_asincron_sfunc.m\n\n');

%% =========================================================
%% MODEL 1: SCHEMA METODA RELEULUI (fig. 7.6)
%% =========================================================
model_releu = 'lab7_metoda_releului_slx';
if bdIsLoaded(model_releu); close_system(model_releu,0); end
new_system(model_releu); open_system(model_releu);

% Blocuri
add_block('simulink/Sources/Constant',                  [model_releu '/w']);
add_block('simulink/Math Operations/Sum',                [model_releu '/Comp']);
add_block('simulink/Discontinuities/Relay',              [model_releu '/Releu']);
add_block('simulink/User-Defined Functions/Level-2 MATLAB S-Function', [model_releu '/MotorA']);
add_block('simulink/User-Defined Functions/Level-2 MATLAB S-Function', [model_releu '/MotorB']);
add_block('simulink/Sources/Clock',                      [model_releu '/Clock']);
add_block('simulink/Math Operations/Product',            [model_releu '/Prod_ua']);
add_block('simulink/Math Operations/Product',            [model_releu '/Prod_ub']);
add_block('simulink/Sinks/Scope',                        [model_releu '/Scope_n']);
add_block('simulink/Sinks/To Workspace',                 [model_releu '/n_out']);
add_block('simulink/Sinks/To Workspace',                 [model_releu '/b_out']);

% Parametri
set_param([model_releu '/w'],     'Value','0','Position',[20,170,70,200]);
set_param([model_releu '/Comp'],  'Inputs','+-','Position',[130,160,170,210]);
set_param([model_releu '/Releu'], ...
    'OnSwitchValue',num2str(50),'OffSwitchValue',num2str(-50),...
    'OnOutputValue','1','OffOutputValue','-1',...
    'Position',[220,155,300,215]);

% Atribuire functie Level-2
set_param([model_releu '/MotorA'],'FunctionName','motor_asincron_sfunc','Position',[500,140,620,230]);
set_param([model_releu '/MotorB'],'FunctionName','motor_asincron_sfunc','Position',[500,260,620,350]);
set_param([model_releu '/Scope_n'],'Position',[700,165,770,215]);
set_param([model_releu '/n_out'], 'VariableName','n_releu','SaveFormat','Array','Position',[700,240,800,270]);
set_param([model_releu '/b_out'], 'VariableName','b_releu','SaveFormat','Array','Position',[350,240,450,270]);
set_param([model_releu '/Clock'], 'Position',[20,260,70,290]);

% Conexiuni
add_line(model_releu,'w/1','Comp/1','autorouting','on');
add_line(model_releu,'Comp/1','Releu/1','autorouting','on');
add_line(model_releu,'Releu/1','b_out/1','autorouting','on');
add_line(model_releu,'MotorA/1','Scope_n/1','autorouting','on');
add_line(model_releu,'MotorA/1','n_out/1','autorouting','on');
add_line(model_releu,'MotorA/1','Comp/2','autorouting','on');

set_param(model_releu,'StopTime','50','Solver','ode45','RelTol','1e-5');
save_system(model_releu,[model_releu '.slx']);
fprintf('Model metoda releului salvat corect: %s.slx\n', model_releu);

%% =========================================================
%% MODEL 2: SCHEMA REGLARE TURATIE (fig. 7.8)
%% =========================================================
model_reg = 'lab7_reglare_turatie_slx';
if bdIsLoaded(model_reg); close_system(model_reg,0); end
new_system(model_reg); open_system(model_reg);

% Numerator/numitor regulator PI
num_PI = KR2 * [TI2, 1];
den_PI = [TI2, 0];

% Blocuri schema reglare (Folosind Level-2 S-Function pentru Motor)
add_block('simulink/Sources/Signal Builder',             [model_reg '/w_ref']);
add_block('simulink/Math Operations/Sum',                 [model_reg '/Comp']);
add_block('simulink/Continuous/Transfer Fcn',             [model_reg '/HR_PI']);
add_block('simulink/Math Operations/Gain',                [model_reg '/VCO1_gain']);
add_block('simulink/Math Operations/Gain',                [model_reg '/VCO2_gain']);
add_block('simulink/Sources/Clock',                       [model_reg '/Clock']);
add_block('simulink/Math Operations/Product',             [model_reg '/Prod_phase1']);
add_block('simulink/Math Operations/Product',             [model_reg '/Prod_phase2']);
% REZOLVARE EROARE: Schimbat din 'simulink/Trigonometry/...' in 'simulink/Math Operations/...'
add_block('simulink/Math Operations/Trigonometric Function', [model_reg '/Sin_ua']);
add_block('simulink/Math Operations/Trigonometric Function', [model_reg '/Sin_ub']);
add_block('simulink/Math Operations/Product',             [model_reg '/Scale_ua']);
add_block('simulink/Math Operations/Product',             [model_reg '/Scale_ub']);
add_block('simulink/User-Defined Functions/Level-2 MATLAB S-Function', [model_reg '/Motor']);
add_block('simulink/Sinks/Scope',                         [model_reg '/Scope_n']);
add_block('simulink/Sinks/To Workspace',                  [model_reg '/n_out_reg']);
add_block('simulink/Sinks/To Workspace',                  [model_reg '/c_out_reg']);

% Parametri blocuri
set_param([model_reg '/Comp'],       'Inputs','+-','Position',[200,185,240,225]);
set_param([model_reg '/HR_PI'],      'Numerator',mat2str(num_PI),'Denominator',mat2str(den_PI),'Position',[280,180,380,230]);
set_param([model_reg '/VCO1_gain'], 'Gain',sprintf('2*pi'),'Position',[420,180,480,220]);
set_param([model_reg '/Sin_ua'],    'Operator','sin','Position',[600,155,660,195]);
set_param([model_reg '/Sin_ub'],    'Operator','sin','Position',[600,240,660,280]);
set_param([model_reg '/Motor'],      'FunctionName','motor_asincron_sfunc','Position',[800,175,920,265]);
set_param([model_reg '/Scope_n'],   'Position',[980,190,1050,240]);
set_param([model_reg '/n_out_reg'], 'VariableName','n_reg','SaveFormat','Array','Position',[980,265,1080,295]);
set_param([model_reg '/c_out_reg'], 'VariableName','c_reg','SaveFormat','Array','Position',[420,265,520,295]);

% Conexiuni principale
add_line(model_reg,'Comp/1','HR_PI/1','autorouting','on');
add_line(model_reg,'HR_PI/1','VCO1_gain/1','autorouting','on');
add_line(model_reg,'HR_PI/1','c_out_reg/1','autorouting','on');
add_line(model_reg,'Motor/1','Scope_n/1','autorouting','on');
add_line(model_reg,'Motor/1','n_out_reg/1','autorouting','on');
add_line(model_reg,'Motor/1','Comp/2','autorouting','on');

set_param(model_reg,'StopTime','15','Solver','ode45','RelTol','1e-5','MaxStep','1e-3');
save_system(model_reg,[model_reg '.slx']);
fprintf('Model reglare turatie salvat corect: %s.slx\n', model_reg);

%% =========================================================
%% FINALIZARE
%% =========================================================
fprintf('\nNota: Modelele Simulink au fost construite fara erori.\n');
fprintf('Parametri regulatori au fost incarcati automat:\n');
fprintf('  K_R = %.6f\n', KR2);
fprintf('  T_I = %.4f s\n', TI2);