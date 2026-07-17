%% LABORATOR NR. 3 - Creare modele Simulink
%% Schema de simulare din figura 3.3 pentru ambele sisteme:
%%   - Sistem 1: Metoda Dahlin  -> H_f1(s) = 4.3/((1+5s)(1+23s)) * e^(-2.5s)
%%   - Sistem 2: Metoda Kalman  -> H_f2(s) = 1.25/((1+9s)(1+14s)) * e^(-3s)
%%
%% Schema (Fig. 3.3):
%%   w --> [+/-] --> [RN(z)] --> [EOZ] --> [Tm] --> [H_f(s)] --> y
%%                                                        |
%%                                              <---------+  (r = y, TM=1)

addpath('../common');

%% =========================================================
%% SISTEM 1 - METODA DAHLIN
%% =========================================================
fprintf('=== SISTEM 1: Metoda Dahlin ===\n');

Kf1 = 4.3;  T11 = 5;  T21 = 23;  Tm1 = 2.5;  TE1 = 0.5;  T01 = 3;

% Discretizare parte fixa
sys1_c = tf(Kf1, conv([T11 1],[T21 1]));
nd1    = round(Tm1/TE1);
sys1_d = c2d(sys1_c, TE1, 'zoh');
[B1,A1] = tfdata(sys1_d,'v');

% Calcul regulator Dahlin
sys0_1d = c2d(tf(1,[T01 1]), TE1, 'zoh');
[B01,A01] = tfdata(sys0_1d,'v');
A01_mB01 = A01; A01_mB01(1:length(B01)) = A01_mB01(1:length(B01)) - B01;
den_R1_nd = [zeros(1,nd1), conv(B1, A01_mB01)];
scale1 = den_R1_nd(1);
num_R1 = conv(A1,B01) / scale1;
den_R1 = den_R1_nd / scale1;

fprintf('Regulator Dahlin H_R1(z):\n');
disp_tf_z(num_R1, den_R1, 'H_R1(z)');
fprintf('Parte fixa: Kf=%.2f, T1=%.0f, T2=%.0f, Tm=%.1f, TE=%.2f\n\n', Kf1,T11,T21,Tm1,TE1);

%% =========================================================
%% SISTEM 2 - METODA KALMAN
%% =========================================================
fprintf('=== SISTEM 2: Metoda Kalman ===\n');

Kf2 = 1.25;  T12 = 9;  T22 = 14;  Tm2 = 3;  TE2 = 1;

sys2_c = tf(Kf2, conv([T12 1],[T22 1]));
nd2    = round(Tm2/TE2);
sys2_d = c2d(sys2_c, TE2, 'zoh');
[B2,A2] = tfdata(sys2_d,'v');

% Calcul regulator Kalman
S2  = sum(B2);  K2 = 1/S2;
P2  = K2*B2;    Q2 = K2*A2;
P2d = [P2, zeros(1,nd2)];
omP2 = -P2d;  omP2(1) = omP2(1)+1;
sc2  = omP2(1);
num_R2 = Q2/sc2;
den_R2 = omP2/sc2;

fprintf('K (Kalman) = %.4f\n', K2);
fprintf('Regulator Kalman H_R2(z):\n');
disp_tf_z(num_R2, den_R2, 'H_R2(z)');
fprintf('Parte fixa: Kf=%.4f, T1=%.0f, T2=%.0f, Tm=%.0f, TE=%.0f\n\n', Kf2,T12,T22,Tm2,TE2);

%% =========================================================
%% CREARE MODEL SIMULINK - SISTEM 1 (DAHLIN)
%% =========================================================
model1 = 'lab3_dahlin';
fprintf('--- Creare model Simulink: %s ---\n', model1);
try
    if bdIsLoaded(model1), close_system(model1,0); end
    new_system(model1);
    open_system(model1);

    %% Blocuri
    add_block('simulink/Sources/Step',                        [model1 '/w']);
    add_block('simulink/Math Operations/Sum',                 [model1 '/Sumator']);
    add_block('simulink/Discrete/Discrete Transfer Fcn',      [model1 '/RN']);
    add_block('simulink/Discrete/Zero-Order Hold',            [model1 '/EOZ']);
    add_block('simulink/Continuous/Transport Delay',          [model1 '/Timp_mort']);
    add_block('simulink/Continuous/Transfer Fcn',             [model1 '/HF']);
    add_block('simulink/Sources/Step',                        [model1 '/Perturbatie']);
    add_block('simulink/Math Operations/Sum',                 [model1 '/Sum_pert']);
    add_block('simulink/Sinks/Scope',                         [model1 '/Scope_y']);
    add_block('simulink/Sinks/Scope',                         [model1 '/Scope_c']);

    %% Parametri blocuri
    % Referinta - treapta unitara la t=0
    set_param([model1 '/w'], 'Time','0', 'Before','0', 'After','1');

    % Perturbatie - zero (p=0)
    set_param([model1 '/Perturbatie'], 'Time','0', 'Before','0', 'After','0');

    % Sumator comparator: w - y
    set_param([model1 '/Sumator'], 'Inputs','+-');

    % Regulator numeric (Discrete Transfer Fcn in z^-1)
    set_param([model1 '/RN'], ...
        'Numerator',   mat2str(num_R1, 6), ...
        'Denominator', mat2str(den_R1, 6), ...
        'SampleTime',  num2str(TE1));

    % EOZ - Zero Order Hold
    set_param([model1 '/EOZ'], 'SampleTime', num2str(TE1));

    % Timp mort
    set_param([model1 '/Timp_mort'], 'DelayTime', num2str(Tm1));

    % Parte fixa H_f1(s)
    set_param([model1 '/HF'], ...
        'Numerator',   mat2str(Kf1), ...
        'Denominator', mat2str(conv([T11 1],[T21 1])));

    % Sumator perturbatie: iesire_HF + p
    set_param([model1 '/Sum_pert'], 'Inputs','++');

    %% Conexiuni
    add_line(model1, 'w/1',           'Sumator/1',    'autorouting','on');
    add_line(model1, 'Sumator/1',     'RN/1',         'autorouting','on');
    add_line(model1, 'RN/1',          'EOZ/1',        'autorouting','on');
    add_line(model1, 'RN/1',          'Scope_c/1',    'autorouting','on');
    add_line(model1, 'EOZ/1',         'Timp_mort/1',  'autorouting','on');
    add_line(model1, 'Timp_mort/1',   'HF/1',         'autorouting','on');
    add_line(model1, 'HF/1',          'Sum_pert/1',   'autorouting','on');
    add_line(model1, 'Perturbatie/1', 'Sum_pert/2',   'autorouting','on');
    add_line(model1, 'Sum_pert/1',    'Scope_y/1',    'autorouting','on');
    add_line(model1, 'Sum_pert/1',    'Sumator/2',    'autorouting','on');

    %% Configurare simulare
    set_param(model1, 'StopTime','80', 'Solver','ode45');

    %% Aranjare automata si salvare
    Simulink.BlockDiagram.arrangeSystem(model1);
    save_system(model1, [model1 '.slx']);
    fprintf('  Model creat cu succes: %s.slx\n', model1);

catch ME
    fprintf('  EROARE la creare model Dahlin: %s\n', ME.message);
    fprintf('  Folositi parametrii afisati mai sus pentru constructie manuala.\n');
end

%% =========================================================
%% CREARE MODEL SIMULINK - SISTEM 2 (KALMAN)
%% =========================================================
model2 = 'lab3_kalman';
fprintf('\n--- Creare model Simulink: %s ---\n', model2);
try
    if bdIsLoaded(model2), close_system(model2,0); end
    new_system(model2);
    open_system(model2);

    %% Blocuri
    add_block('simulink/Sources/Step',                        [model2 '/w']);
    add_block('simulink/Math Operations/Sum',                 [model2 '/Sumator']);
    add_block('simulink/Discrete/Discrete Transfer Fcn',      [model2 '/RN']);
    add_block('simulink/Discrete/Zero-Order Hold',            [model2 '/EOZ']);
    add_block('simulink/Continuous/Transport Delay',          [model2 '/Timp_mort']);
    add_block('simulink/Continuous/Transfer Fcn',             [model2 '/HF']);
    add_block('simulink/Sources/Step',                        [model2 '/Perturbatie']);
    add_block('simulink/Math Operations/Sum',                 [model2 '/Sum_pert']);
    add_block('simulink/Sinks/Scope',                         [model2 '/Scope_y']);
    add_block('simulink/Sinks/Scope',                         [model2 '/Scope_c']);

    %% Parametri blocuri
    set_param([model2 '/w'], 'Time','0', 'Before','0', 'After','1');
    set_param([model2 '/Perturbatie'], 'Time','0', 'Before','0', 'After','0');
    set_param([model2 '/Sumator'], 'Inputs','+-');

    set_param([model2 '/RN'], ...
        'Numerator',   mat2str(num_R2, 6), ...
        'Denominator', mat2str(den_R2, 6), ...
        'SampleTime',  num2str(TE2));

    set_param([model2 '/EOZ'], 'SampleTime', num2str(TE2));
    set_param([model2 '/Timp_mort'], 'DelayTime', num2str(Tm2));

    set_param([model2 '/HF'], ...
        'Numerator',   mat2str(Kf2), ...
        'Denominator', mat2str(conv([T12 1],[T22 1])));

    set_param([model2 '/Sum_pert'], 'Inputs','++');

    %% Conexiuni
    add_line(model2, 'w/1',           'Sumator/1',    'autorouting','on');
    add_line(model2, 'Sumator/1',     'RN/1',         'autorouting','on');
    add_line(model2, 'RN/1',          'EOZ/1',        'autorouting','on');
    add_line(model2, 'RN/1',          'Scope_c/1',    'autorouting','on');
    add_line(model2, 'EOZ/1',         'Timp_mort/1',  'autorouting','on');
    add_line(model2, 'Timp_mort/1',   'HF/1',         'autorouting','on');
    add_line(model2, 'HF/1',          'Sum_pert/1',   'autorouting','on');
    add_line(model2, 'Perturbatie/1', 'Sum_pert/2',   'autorouting','on');
    add_line(model2, 'Sum_pert/1',    'Scope_y/1',    'autorouting','on');
    add_line(model2, 'Sum_pert/1',    'Sumator/2',    'autorouting','on');

    %% Configurare simulare
    set_param(model2, 'StopTime','120', 'Solver','ode45');

    Simulink.BlockDiagram.arrangeSystem(model2);
    save_system(model2, [model2 '.slx']);
    fprintf('  Model creat cu succes: %s.slx\n', model2);

catch ME
    fprintf('  EROARE la creare model Kalman: %s\n', ME.message);
    fprintf('  Folositi parametrii afisati mai sus pentru constructie manuala.\n');
end

%% =========================================================
%% INSTRUCTIUNI FINALE
%% =========================================================
fprintf('\n=== INSTRUCTIUNI ===\n');
fprintf('1. Dupa rularea acestui script, se creeaza:\n');
fprintf('     lab3_dahlin.slx  - schema Simulink Sistem 1 (Dahlin)\n');
fprintf('     lab3_kalman.slx  - schema Simulink Sistem 2 (Kalman)\n\n');
fprintf('2. Pentru a adauga saturatie la comanda (c in [0,1]):\n');
fprintf('   - Introduceti un bloc "Saturation" intre RN si EOZ\n');
fprintf('   - Setati Lower limit=0, Upper limit=1\n\n');
fprintf('3. Pentru regulatorul modificat (pol eliminat):\n');
fprintf('   - Inlocuiti parametrii blocului RN cu cei calculati\n');
fprintf('     de metoda_dahlin.m / metoda_kalman.m\n\n');
fprintf('4. Schema (Fig. 3.3):\n');
fprintf('   w --> [+/-] --> [RN] --> [EOZ] --> [Timp_mort] --> [HF] --> y\n');
fprintf('         ^                                                  |\n');
fprintf('         +--------------------------------------------------+\n');
fprintf('                        (reactie unitara)\n');
