%% LABORATOR NR. 6 - Construire modele Simulink
%% Schema a) Putere activa + frecventa (fig. 6.3)
%% Schema b) Tensiunea la bornele generatorului (fig. 6.12)
%% Necesita Simulink instalat.

clear; clc; close all;

s = tf('s');

%% =========================================================
%% PARAMETRI COMUNI
%% =========================================================
% --- SISTEM a) ---
K_SMH=0.01; T_SMH=20;
K_V=10667.51;
K_TG=0.337; T_TG=10;
K_S=0.139; T1S=1; T2S=2;
K_Pup=0.027; K_fuf=0.2;
K_R=10; T_D=10; T_f=0.2;
K_ST=125;

% Regulatorul RP (PD cu filtru): K_R*(1+TD*s)/(1+Tf*s)
num_RP = K_R*[T_D, 1]; den_RP = [T_f, 1];
% SMH: (K_SMH*T_SMH*s+1)/(T_SMH*s)
num_SMH = [K_SMH*T_SMH, 1]; den_SMH = [T_SMH, 0];
num_V   = K_V;  den_V  = 1;
num_TG  = K_TG; den_TG = [T_TG, 1];
num_S   = K_S;  den_S  = conv([T1S,1],[T2S,1]);
num_Pup = K_Pup; den_Pup = 1;
num_fuf = K_fuf; den_fuf = 1;
% Filtre "intarziere"
num_REF1  = 1; den_REF1  = conv([5,1],[8,1]);
num_PERT1 = 1; den_PERT1 = conv([1,1],[1,1]);

% --- SISTEM b) ---
K_EE_b=1.388; T_EE_b=0.1;
K_E=3.6;      T_E=0.5;
K_EG=13.888;
K_G=0.403;    T_G=4;
K_CCG_PC=45;
K_TUE=0.02; K_TIE=0.0055; K_TUG=4e-4; K_TIG=4.96e-5;
K_RUE=4;    T_I_RUE=0.1;
K_RIE=26;   T_I_RIE=0.52; T_D_RIE=0.019; T_f2=0.05;
K_RUG=212;  T_I_RUG=4.02; T_D_RUG=0.198; T_f3=4.2;

num_RUE = K_RUE*[T_I_RUE,1]; den_RUE = [T_I_RUE,0];
num_RIE_b = K_RIE*[(T_I_RIE*T_f2+T_I_RIE*T_D_RIE),(T_I_RIE+T_f2),1];
den_RIE_b = [T_I_RIE*T_f2, T_I_RIE, 0];
num_RUG_b = K_RUG*[(T_I_RUG*T_f3+T_I_RUG*T_D_RUG),(T_I_RUG+T_f3),1];
den_RUG_b = [T_I_RUG*T_f3, T_I_RUG, 0];
num_REF2  = 1; den_REF2  = conv([5,1],[8,1]);
num_PERT2 = 1; den_PERT2 = conv([1,1],[1,1]);

%% =========================================================
%% MODEL SIMULINK a) - Putere activa si frecventa (fig. 6.3)
%% =========================================================
model_a = 'lab6_putere_frecventa';
if bdIsLoaded(model_a); close_system(model_a,0); end
new_system(model_a); open_system(model_a);

% Blocuri schema a)
add_block('simulink/Sources/Step',              [model_a '/uP_ref']);
add_block('simulink/Sources/Step',              [model_a '/uf_ref']);
add_block('simulink/Math Operations/Sum',        [model_a '/EC2']);
add_block('simulink/Continuous/Transfer Fcn',    [model_a '/HRP']);
add_block('simulink/Continuous/Transfer Fcn',    [model_a '/HSMH']);
add_block('simulink/Continuous/Transfer Fcn',    [model_a '/HV']);
add_block('simulink/Continuous/Transfer Fcn',    [model_a '/HTG']);
add_block('simulink/Continuous/Transfer Fcn',    [model_a '/HS']);
add_block('simulink/Sources/Step',               [model_a '/pf']);
add_block('simulink/Math Operations/Sum',        [model_a '/SumPf']);
add_block('simulink/Continuous/Transfer Fcn',    [model_a '/HPup']);
add_block('simulink/Continuous/Transfer Fcn',    [model_a '/Hfuf']);
add_block('simulink/Math Operations/Gain',       [model_a '/KST']);
add_block('simulink/Math Operations/Sum',        [model_a '/EC1']);
add_block('simulink/Continuous/Transfer Fcn',    [model_a '/HREF1']);
add_block('simulink/Continuous/Transfer Fcn',    [model_a '/HPERT1']);
add_block('simulink/Sinks/Scope',                [model_a '/Scope_f']);
add_block('simulink/Sinks/To Workspace',         [model_a '/f_out']);
add_block('simulink/Sinks/To Workspace',         [model_a '/P_out']);
add_block('simulink/Sinks/To Workspace',         [model_a '/cqabv_out']);

% Pozitii si parametri
set_param([model_a '/uP_ref'],  'Time','0','Before','0','After','10','Position',[20,200,80,230]);
set_param([model_a '/uf_ref'],  'Time','0','Before','0','After','10','Position',[20,80,80,110]);
set_param([model_a '/EC2'],     'Inputs','+++-','Position',[200,140,240,300]);
set_param([model_a '/HREF1'],   'Numerator',mat2str(num_REF1),'Denominator',mat2str(den_REF1),'Position',[100,190,180,240]);
set_param([model_a '/HRP'],     'Numerator',mat2str(num_RP),'Denominator',mat2str(den_RP),'Position',[280,180,380,250]);
set_param([model_a '/HSMH'],    'Numerator',mat2str(num_SMH),'Denominator',mat2str(den_SMH),'Position',[420,180,520,250]);
set_param([model_a '/HV'],      'Numerator',mat2str(num_V),'Denominator',mat2str(den_V),'Position',[560,180,640,250]);
set_param([model_a '/HTG'],     'Numerator',mat2str(num_TG),'Denominator',mat2str(den_TG),'Position',[680,180,780,250]);
set_param([model_a '/HS'],      'Numerator',mat2str(num_S),'Denominator',mat2str(den_S),'Position',[820,180,920,250]);
set_param([model_a '/pf'],      'Time','150','Before','0','After','-5','Position',[820,80,900,110]);
set_param([model_a '/HPERT1'],  'Numerator',mat2str(num_PERT1),'Denominator',mat2str(den_PERT1),'Position',[820,60,900,90]);
set_param([model_a '/SumPf'],   'Inputs','++','Position',[940,170,1000,260]);
set_param([model_a '/HPup'],    'Numerator',mat2str(num_Pup),'Denominator',mat2str(den_Pup),'Position',[820,330,920,370]);
set_param([model_a '/Hfuf'],    'Numerator',mat2str(num_fuf),'Denominator',mat2str(den_fuf),'Position',[820,420,920,460]);
set_param([model_a '/KST'],     'Gain',num2str(K_ST),'Position',[650,80,730,120]);
set_param([model_a '/EC1'],     'Inputs','+-','Position',[580,75,620,115]);
set_param([model_a '/Scope_f'], 'Position',[1060,190,1130,250]);
set_param([model_a '/f_out'],   'VariableName','f_sim','SaveFormat','Array','Position',[1060,270,1150,300]);
set_param([model_a '/P_out'],   'VariableName','P_sim','SaveFormat','Array','Position',[820,460,920,490]);
set_param([model_a '/cqabv_out'],'VariableName','cqabv_sim','SaveFormat','Array','Position',[280,270,380,300]);

% Conexiuni schema a)
add_line(model_a,'uP_ref/1','HREF1/1','autorouting','on');
add_line(model_a,'HREF1/1','EC2/1','autorouting','on');
add_line(model_a,'EC2/1','HRP/1','autorouting','on');
add_line(model_a,'HRP/1','HSMH/1','autorouting','on');
add_line(model_a,'HRP/1','cqabv_out/1','autorouting','on');
add_line(model_a,'HSMH/1','HV/1','autorouting','on');
add_line(model_a,'HV/1','HTG/1','autorouting','on');
add_line(model_a,'HTG/1','HS/1','autorouting','on');
add_line(model_a,'HS/1','SumPf/1','autorouting','on');
add_line(model_a,'HPERT1/1','SumPf/2','autorouting','on');
add_line(model_a,'pf/1','HPERT1/1','autorouting','on');
add_line(model_a,'SumPf/1','Scope_f/1','autorouting','on');
add_line(model_a,'SumPf/1','f_out/1','autorouting','on');
add_line(model_a,'SumPf/1','HPup/1','autorouting','on');
add_line(model_a,'SumPf/1','Hfuf/1','autorouting','on');
add_line(model_a,'HPup/1','EC2/3','autorouting','on');
add_line(model_a,'HPup/1','P_out/1','autorouting','on');
add_line(model_a,'Hfuf/1','EC1/1','autorouting','on');
add_line(model_a,'uf_ref/1','EC1/2','autorouting','on');
add_line(model_a,'EC1/1','KST/1','autorouting','on');
add_line(model_a,'KST/1','EC2/2','autorouting','on');
add_line(model_a,'EC2/4','EC2/4','autorouting','on');

set_param(model_a,'StopTime','300','Solver','ode45');
save_system(model_a,[model_a '.slx']);
fprintf('Model a) salvat: %s.slx\n', model_a);

%% =========================================================
%% MODEL SIMULINK b) - Tensiunea la bornele generatorului (fig. 6.12)
%% =========================================================
model_b = 'lab6_tensiune_generator';
if bdIsLoaded(model_b); close_system(model_b,0); end
new_system(model_b); open_system(model_b);

% Blocuri schema b) - cascada 3 bucle
add_block('simulink/Sources/Step',              [model_b '/uG_ref']);
add_block('simulink/Continuous/Transfer Fcn',    [model_b '/HREF2']);
add_block('simulink/Math Operations/Sum',        [model_b '/CompUG']);
add_block('simulink/Continuous/Transfer Fcn',    [model_b '/HRUG']);
add_block('simulink/Math Operations/Sum',        [model_b '/CompUE']);
add_block('simulink/Continuous/Transfer Fcn',    [model_b '/HRUE']);
add_block('simulink/Math Operations/Sum',        [model_b '/CompIE']);
add_block('simulink/Continuous/Transfer Fcn',    [model_b '/HRIE']);
add_block('simulink/Continuous/Transfer Fcn',    [model_b '/HCCG']);
add_block('simulink/Continuous/Transfer Fcn',    [model_b '/HEE']);
add_block('simulink/Continuous/Transfer Fcn',    [model_b '/HE']);
add_block('simulink/Continuous/Transfer Fcn',    [model_b '/HEG']);
add_block('simulink/Continuous/Transfer Fcn',    [model_b '/HG']);
add_block('simulink/Sources/Step',               [model_b '/pU']);
add_block('simulink/Continuous/Transfer Fcn',    [model_b '/HPERT2']);
add_block('simulink/Math Operations/Sum',        [model_b '/SumPU']);
add_block('simulink/Math Operations/Gain',       [model_b '/HTUE']);
add_block('simulink/Math Operations/Gain',       [model_b '/HTIE']);
add_block('simulink/Math Operations/Gain',       [model_b '/HTUG']);
add_block('simulink/Math Operations/Gain',       [model_b '/HTIG']);
add_block('simulink/Math Operations/Sum',        [model_b '/SumCompund']);
add_block('simulink/Sinks/Scope',                [model_b '/Scope_UG']);
add_block('simulink/Sinks/To Workspace',         [model_b '/UG_out']);
add_block('simulink/Sinks/To Workspace',         [model_b '/cUE_out']);
add_block('simulink/Sinks/To Workspace',         [model_b '/cIE_out']);

% Parametri blocuri b)
set_param([model_b '/uG_ref'],   'Time','0','Before','0','After','9.5','Position',[20,200,80,230]);
set_param([model_b '/HREF2'],    'Numerator',mat2str(num_REF2),'Denominator',mat2str(den_REF2),'Position',[110,190,190,240]);
set_param([model_b '/CompUG'],   'Inputs','+-','Position',[220,190,260,250]);
set_param([model_b '/HRUG'],     'Numerator',mat2str(num_RUG_b),'Denominator',mat2str(den_RUG_b),'Position',[300,185,420,255]);
set_param([model_b '/CompUE'],   'Inputs','+-','Position',[450,190,490,250]);
set_param([model_b '/HRUE'],     'Numerator',mat2str(num_RUE),'Denominator',mat2str(den_RUE),'Position',[520,185,620,255]);
set_param([model_b '/CompIE'],   'Inputs','+-','Position',[650,190,690,250]);
set_param([model_b '/HRIE'],     'Numerator',mat2str(num_RIE_b),'Denominator',mat2str(den_RIE_b),'Position',[720,185,840,255]);
set_param([model_b '/HCCG'],     'Numerator',num2str(K_CCG_PC),'Denominator','1','Position',[880,185,960,255]);
set_param([model_b '/HEE'],      'Numerator',num2str(K_EE_b),'Denominator',mat2str([T_EE_b,1]),'Position',[1000,185,1080,255]);
set_param([model_b '/HE'],       'Numerator',num2str(K_E),'Denominator',mat2str([T_E,1]),'Position',[1120,185,1200,255]);
set_param([model_b '/HEG'],      'Numerator',num2str(K_EG),'Denominator','1','Position',[1240,185,1320,255]);
set_param([model_b '/HG'],       'Numerator',num2str(K_G),'Denominator',mat2str([T_G,1]),'Position',[1360,185,1440,255]);
set_param([model_b '/pU'],       'Time','70','Before','0','After','-1000','Position',[1360,80,1440,110]);
set_param([model_b '/HPERT2'],   'Numerator',mat2str(num_PERT2),'Denominator',mat2str(den_PERT2),'Position',[1360,55,1440,85]);
set_param([model_b '/SumPU'],    'Inputs','++','Position',[1470,180,1530,260]);
set_param([model_b '/HTUG'],     'Gain',num2str(K_TUG),'Position',[1360,330,1440,370]);
set_param([model_b '/HTIG'],     'Gain',num2str(K_TIG*0.05),'Position',[1360,400,1440,430]);
set_param([model_b '/SumCompund'],'Inputs','+-','Position',[1290,320,1330,450]);
set_param([model_b '/HTUE'],     'Gain',num2str(K_TUE),'Position',[1120,330,1200,370]);
set_param([model_b '/HTIE'],     'Gain',num2str(K_TIE),'Position',[720,330,800,370]);
set_param([model_b '/Scope_UG'], 'Position',[1570,195,1640,255]);
set_param([model_b '/UG_out'],   'VariableName','UG_sim','SaveFormat','Array','Position',[1570,270,1660,300]);
set_param([model_b '/cUE_out'],  'VariableName','cUE_sim','SaveFormat','Array','Position',[520,270,620,300]);
set_param([model_b '/cIE_out'],  'VariableName','cIE_sim','SaveFormat','Array','Position',[720,270,820,300]);

% Conexiuni schema b)
add_line(model_b,'uG_ref/1','HREF2/1','autorouting','on');
add_line(model_b,'HREF2/1','CompUG/1','autorouting','on');
add_line(model_b,'CompUG/1','HRUG/1','autorouting','on');
add_line(model_b,'HRUG/1','CompUE/1','autorouting','on');
add_line(model_b,'CompUE/1','HRUE/1','autorouting','on');
add_line(model_b,'HRUE/1','CompIE/1','autorouting','on');
add_line(model_b,'HRUE/1','cUE_out/1','autorouting','on');
add_line(model_b,'CompIE/1','HRIE/1','autorouting','on');
add_line(model_b,'HRIE/1','HCCG/1','autorouting','on');
add_line(model_b,'HRIE/1','cIE_out/1','autorouting','on');
add_line(model_b,'HCCG/1','HEE/1','autorouting','on');
add_line(model_b,'HEE/1','HE/1','autorouting','on');
add_line(model_b,'HE/1','HTUE/1','autorouting','on');
add_line(model_b,'HTUE/1','CompUE/2','autorouting','on');
add_line(model_b,'HE/1','HEG/1','autorouting','on');
add_line(model_b,'HEG/1','HG/1','autorouting','on');
add_line(model_b,'HG/1','HTIE/1','autorouting','on');
add_line(model_b,'HTIE/1','CompIE/2','autorouting','on');
add_line(model_b,'HG/1','SumPU/1','autorouting','on');
add_line(model_b,'HPERT2/1','SumPU/2','autorouting','on');
add_line(model_b,'pU/1','HPERT2/1','autorouting','on');
add_line(model_b,'SumPU/1','HTUG/1','autorouting','on');
add_line(model_b,'SumPU/1','HTIG/1','autorouting','on');
add_line(model_b,'HTUG/1','SumCompund/1','autorouting','on');
add_line(model_b,'HTIG/1','SumCompund/2','autorouting','on');
add_line(model_b,'SumCompund/1','CompUG/2','autorouting','on');
add_line(model_b,'SumPU/1','Scope_UG/1','autorouting','on');
add_line(model_b,'SumPU/1','UG_out/1','autorouting','on');

set_param(model_b,'StopTime','100','Solver','ode45');
save_system(model_b,[model_b '.slx']);
fprintf('Model b) salvat: %s.slx\n', model_b);

%% =========================================================
%% RULSIMULAR
%% =========================================================
fprintf('\nRulare simulari Simulink...\n');

try
    sim_a = sim(model_a,'StopTime','300');
    f_slx = sim_a.f_sim;
    t_a   = linspace(0,300,length(f_slx));
    figure(10);
    plot(t_a, f_slx, 'b-', 'LineWidth',2);
    grid on; xlabel('Timp [s]'); ylabel('f [V]');
    title('Simulink - Fig. 6.4: Evolutia frecventei');
    fprintf('Schema a) simulata cu succes.\n');
catch ME
    fprintf('Eroare schema a): %s\n', ME.message);
end

try
    sim_b = sim(model_b,'StopTime','100');
    UG_slx = sim_b.UG_sim;
    t_b    = linspace(0,100,length(UG_slx));
    figure(11);
    plot(t_b, UG_slx/K_TUG/1000, 'b-', 'LineWidth',2);
    grid on; xlabel('Timp [s]'); ylabel('U_G [kV]');
    title('Simulink - Fig. 6.13: Tensiunea la bornele generatorului');
    fprintf('Schema b) simulata cu succes.\n');
catch ME
    fprintf('Eroare schema b): %s\n', ME.message);
end

fprintf('\nModele Simulink disponibile:\n');
fprintf('  %s.slx  - Putere activa si frecventa (fig. 6.3)\n', model_a);
fprintf('  %s.slx  - Tensiunea la bornele generatorului (fig. 6.12)\n', model_b);
