%% LABORATOR NR. 1 - Creare modele Simulink
%% Schema de simulare din figura 1.8 (folosind functia de transfer a partii fixate)
%% Schema de simulare din figura 1.9 (cu toate elementele separate)

% Acest script creeaza modelele Simulink programatic.
% Daca Simulink nu este disponibil, utilizati task2_acordare_PID.m
% care realizeaza simularea echivalenta folosind Control System Toolbox.

%% Parametri sistem
K_P  = 0.1;
Ty   = 0.4;
T    = 6;

% Regulator PI - criteriul modulului
K_R_modul  = T / (2 * K_P * Ty);
T_I_modul  = T;

% Regulator PID - criteriul simetriei
K_R_sim   = 59.375;
T_I_sim   = 7.6;
T_D_sim   = 1.263;

% Functii de transfer elemente (pentru schema fig. 1.9)
K_IT_val  = 5;      % din exemplul numeric al lucrarii
T_IT_val  = 6;      % constanta de timp dominanta proces

K_EE_val  = 5;
T_EE_val  = 0.2;

K_TM_val  = 0.01;
T_TM_val  = 0.1;

fprintf('=== PARAMETRI PENTRU SIMULINK ===\n\n');
fprintf('--- Schema fig. 1.8 (parte fixata) ---\n');
fprintf('H_F(s) = %.3f / ((1+%.2fs)*(1+%.2fs))\n', K_P, Ty, T);
fprintf('\nRegulator PI (criteriul modulului):\n');
fprintf('  Numerator:   [%.4f*%.4f,  %.4f]\n', K_R_modul, T_I_modul, K_R_modul);
fprintf('  Numitor (PI): [%.4f, 0]\n', T_I_modul);
fprintf('\nRegulator PID (criteriul simetriei) - forma paralela:\n');
fprintf('  K_R = %.4f\n  T_I = %.4f s\n  T_D = %.4f s\n', K_R_sim, T_I_sim, T_D_sim);

fprintf('\n--- Schema fig. 1.9 (elemente separate) ---\n');
fprintf('H_IT(s) = %.3f / (1+%.2fs)\n',  K_IT_val, T_IT_val);
fprintf('H_EE(s) = %.3f / (1+%.2fs)\n',  K_EE_val, T_EE_val);
fprintf('H_TM(s) = %.4f / (1+%.2fs)\n',  K_TM_val, T_TM_val);

%% Creare model Simulink fig. 1.8
model1 = 'schema_fig18';
try
    % Deschide / creaza model
    if bdIsLoaded(model1)
        close_system(model1, 0);
    end
    new_system(model1);
    open_system(model1);

    % Blocuri
    add_block('simulink/Sources/Step',          [model1 '/w']);
    add_block('simulink/Math Operations/Sum',   [model1 '/Sum']);
    add_block('simulink/Continuous/Transfer Fcn',[model1 '/HR']);
    add_block('simulink/Continuous/Transfer Fcn',[model1 '/HF']);
    add_block('simulink/Sources/Step',          [model1 '/Perturbatie']);
    add_block('simulink/Math Operations/Sum',   [model1 '/Sum_pert']);
    add_block('simulink/Sinks/Scope',           [model1 '/Scope']);

    % Parametri blocuri
    set_param([model1 '/w'], 'Time', '0', 'Before', '0', 'After', '1');
    set_param([model1 '/Perturbatie'], 'Time', '0', 'Before', '0', 'After', '0');

    % HR - regulator PI (criteriul modulului) implicit
    num_PI = [K_R_modul*T_I_modul, K_R_modul];
    den_PI = [T_I_modul, 0];
    set_param([model1 '/HR'], 'Numerator', mat2str(num_PI), 'Denominator', mat2str(den_PI));

    % HF - parte fixata
    num_HF = K_P;
    den_HF = conv([Ty 1], [T 1]);
    set_param([model1 '/HF'], 'Numerator', mat2str(num_HF), 'Denominator', mat2str(den_HF));

    % Sum - comparator (w - y)
    set_param([model1 '/Sum'], 'Inputs', '+-');

    % Sum_pert - adaugare perturbatie
    set_param([model1 '/Sum_pert'], 'Inputs', '++');

    % Conexiuni
    add_line(model1, 'w/1', 'Sum/1');
    add_line(model1, 'Sum/1', 'HR/1');
    add_line(model1, 'HR/1', 'Sum_pert/1');
    add_line(model1, 'Perturbatie/1', 'Sum_pert/2');
    add_line(model1, 'Sum_pert/1', 'HF/1');
    add_line(model1, 'HF/1', 'Scope/1');
    add_line(model1, 'HF/1', 'Sum/2');

    % Layout automat
    set_param(model1, 'StopTime', '100');
    Simulink.BlockDiagram.arrangeSystem(model1);
    save_system(model1, [model1 '.slx']);
    fprintf('\nModelul Simulink fig. 1.8 creat: %s.slx\n', model1);
catch ME
    fprintf('\nNu s-a putut crea modelul Simulink automat: %s\n', ME.message);
    fprintf('Utilizati parametrii afisati mai sus pentru a construi manual schema in Simulink.\n');
    fprintf('Sau rulati task2_acordare_PID.m pentru simulare cu Control Toolbox.\n');
end

fprintf('\n=== INSTRUCTIUNI MANUALE SIMULINK ===\n');
fprintf('Schema fig. 1.8:\n');
fprintf('  w --> [Sumator(+/-)] --> [HR] --> [Sumator(+/+)] <-- [p]\n');
fprintf('                                         |\n');
fprintf('                                        [HF] --> y\n');
fprintf('         ^---------------------------------|\n');
fprintf('         (bucla de reactie: r = y)\n\n');
fprintf('Schema fig. 1.9:\n');
fprintf('  w --> [Sumator(+/-)] --> [HR] --> [HEE] --> [Sumator(+/+)] <-- [p]\n');
fprintf('                                                    |\n');
fprintf('                                                  [HIT] --> y\n');
fprintf('         ^---------[HTM]---------------------------|');
