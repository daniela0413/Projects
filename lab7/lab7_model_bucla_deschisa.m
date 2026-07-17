%% LABORATOR NR. 7 - Controlul turatiei unui motor asincron
%%
%% 7.1. Modelul procesului - Simulare in bucla deschisa
%%
%% Parametri motor (37kW, 2940 rot/min, 50Hz, 1 pereche poli):
%%   J  = 0.4    [Kg*m^2]  - moment de inertie
%%   Kf = 0.1115           - coeficient frecare
%%   Rr = 0.156  [Ohm]     - rezistenta rotorica
%%   Rs = 0.294  [Ohm]     - rezistenta statorica
%%   Lr = 0.0417 [H]       - inductanta rotorica
%%   Ls = 0.0424 [H]       - inductanta statorica
%%   LM = 0.041  [H]       - inductanta mutuala
%%   MR = 0               - cuplu rezistent (neglijat)
%%
%% Modelul matematic: sistem de 5 ecuatii diferentiale (ec. 7.1)
%% Intrari: ua(t), ub(t) - tensiunile statorice pe axele a si b
%% Stari:   phi_a, phi_b, ia, ib, omega
%% Iesire:  n [rot/min] = (30/pi)*omega



%% =========================================================
%% PARAMETRI MOTOR ASINCRON (din lucrare, subcap. 7.1)
%% =========================================================
J   = 0.4;       % [Kg*m^2]  moment de inertie
Kf  = 0.1115;    % [-]       coeficient frecare
Rr  = 0.156;     % [Ohm]     rezistenta rotorica
Rs  = 0.294;     % [Ohm]     rezistenta statorica
Lr  = 0.0417;    % [H]       inductanta rotorica
Ls  = 0.0424;    % [H]       inductanta statorica
LM  = 0.041;     % [H]       inductanta mutuala
MR  = 0;         % [Nm]      cuplu rezistent (0 in simulari initiale)

% Parametri derivati (din lucrare)
alpha = Rr / Lr;                          % [1/s]
beta  = (1/1) * LM / (Ls * Lr);          % [-]  (gamma=1 pt simplif.)
gamma = 1 - LM^2 / (Ls * Lr);            % [-]

fprintf('=== PARAMETRI MOTOR ASINCRON ===\n');
fprintf('J=%.2f kg*m2, Kf=%.4f, Rr=%.3f Ohm, Rs=%.3f Ohm\n', J, Kf, Rr, Rs);
fprintf('Lr=%.4f H, Ls=%.4f H, LM=%.4f H\n', Lr, Ls, LM);
fprintf('\nParametri derivati:\n');
fprintf('  alpha = Rr/Lr = %.4f [1/s]\n', alpha);
fprintf('  beta  = LM/(Ls*Lr) = %.4f\n', beta);
fprintf('  gamma = 1 - LM^2/(Ls*Lr) = %.4f\n\n', gamma);

% Verificare alunecare la turatie nominala
fn = 50;         % [Hz]  frecventa nominala
p  = 1;          % perechi de poli
n0 = 60*fn/p;    % [rot/min]  turatie sincronism
n_nom = 2940;    % [rot/min]  turatie nominala
s = (n0 - n_nom)/n0;
fprintf('Turatie sincronism n0 = %.0f rot/min\n', n0);
fprintf('Turatie nominala  n_n = %.0f rot/min\n', n_nom);
fprintf('Alunecare nominala s = %.4f (%.1f%%)\n\n', s, s*100);

%% =========================================================
%% SEMNALE DE INTRARE (tensiunile statorice sinusoidale)
%% ec. 7.3 si 7.4:
%%   ua = 220*sqrt(2)*sin(2*pi*fn*t + pi/2)
%%   ub = 220*sqrt(2)*sin(2*pi*fn*t)
%% =========================================================
U_amp = 220 * sqrt(2);   % [V] amplitudine tensiune

%% =========================================================
%% SIMULARE ODE - Modelul motorului asincron (ec. 7.1)
%% =========================================================
% Sistemul de ecuatii diferentiale:
% d(phi_a)/dt = -alpha*phi_a - omega*phi_b + LM*alpha*ia
% d(phi_b)/dt = -alpha*phi_b + omega*phi_a + LM*alpha*ib
% d(ia)/dt    = -beta*(d(phi_a)/dt) + (1/(gamma*Ls))*(ua - Rs*ia)
% d(ib)/dt    = -beta*(d(phi_b)/dt) + (1/(gamma*Ls))*(ub - Rs*ib)
% d(omega)/dt = (1/J)*(LM/Lr)*(phi_a*ib - phi_b*ia) - (Kf/J)*omega - MR/J

motor_ode = @(t, x) motor_asincron(t, x, alpha, beta, gamma, ...
    J, Kf, LM, Lr, Rs, Ls, MR, U_amp, fn);

% Condititii initiale: toate starile = 0
x0 = [0; 0; 0; 0; 0];   % [phi_a; phi_b; ia; ib; omega]

% Simulare bucla deschisa (fara regulator)
t_span = [0, 7];
opts = odeset('RelTol', 1e-6, 'AbsTol', 1e-9, 'MaxStep', 1e-4);

fprintf('Simulare bucla deschisa (0-7s)...\n');
[t_BO, x_BO] = ode45(motor_ode, t_span, x0, opts);

% Extragem turatia [rot/min]
omega_BO = x_BO(:, 5);
n_BO = (30/pi) * omega_BO;

fprintf('Turatie finala: n = %.2f rot/min (ref: 2940 rot/min)\n', n_BO(end));
fprintf('Diferenta fata de referinta: %.2f rot/min\n\n', n_BO(end) - n_nom);

%% FIGURA 7.2 - Turatia in bucla deschisa
figure(1);
plot(t_BO, n_BO, 'b-', 'LineWidth', 2);
yline(n_nom, 'r--', 'LineWidth', 1, 'DisplayName', sprintf('n_{nom}=%.0f rot/min', n_nom));
yline(n0, 'g:', 'LineWidth', 1, 'DisplayName', sprintf('n_0=%.0f rot/min (sincronism)', n0));
grid on;
xlabel('Timp [s]');
ylabel('n [rot/min]');
title(sprintf('Fig. 7.2 - Turatia motorului asincron in bucla deschisa\n(u_a si u_b la frecventa nominala f_n=%.0fHz)', fn));
legend('n (simulat)', sprintf('n_{nom}=%d rot/min', n_nom), ...
    sprintf('n_0=%d rot/min', n0), 'Location', 'southeast');
xlim([0 7]);
ylim([0 3200]);

%% FIGURA 7.3 - Zoom pentru evidentierea diferentei fata de sincronism
figure(2);
plot(t_BO, n_BO, 'b-', 'LineWidth', 2);
yline(n_nom, 'r--', 'LineWidth', 1.5, 'DisplayName', sprintf('n_{nom}=%d rot/min', n_nom));
yline(n0, 'g:', 'LineWidth', 1.5, 'DisplayName', sprintf('n_0=%d rot/min', n0));
grid on;
xlabel('Timp [s]');
ylabel('n [rot/min]');
title(sprintf('Fig. 7.3 - Turatia in bucla deschisa (alunecare s=%.2f%%)', s*100));
legend('Location', 'southeast');
xlim([0 7]);
ylim([2800 3050]);

fprintf('Figurile 1 (fig 7.2) si 2 (fig 7.3) generate.\n');
fprintf('Rulati lab7_metoda_releului.m pentru determinarea parametrilor regulatorului.\n');
fprintf('Rulati lab7_reglare_turatie.m pentru simularea in bucla inchisa.\n');

%% =========================================================
%% FUNCTIA MODEL MOTOR ASINCRON (ec. 7.1)
%% =========================================================
function dxdt = motor_asincron(t, x, alpha, beta, gamma, ...
    J, Kf, LM, Lr, Rs, Ls, MR, U_amp, fn)

    phi_a = x(1);
    phi_b = x(2);
    ia    = x(3);
    ib    = x(4);
    omega = x(5);

    % Tensiunile statorice sinusoidale (ec. 7.3, 7.4)
    ua = U_amp * sin(2*pi*fn*t + pi/2);
    ub = U_amp * sin(2*pi*fn*t);

    % Derivatele fluxului rotoric (primele 2 ecuatii din 7.1)
    dphi_a = -alpha*phi_a - omega*phi_b + LM*alpha*ia;
    dphi_b = -alpha*phi_b + omega*phi_a + LM*alpha*ib;

    % Derivatele curentilor statorici (ec. 3 si 4 din 7.1)
    dia = -beta*dphi_a + (1/(gamma*Ls))*(ua - Rs*ia);
    dib = -beta*dphi_b + (1/(gamma*Ls))*(ub - Rs*ib);

    % Derivata vitezei unghiulare (ec. 5 din 7.1)
    domega = (1/J) * (LM/Lr) * (phi_a*ib - phi_b*ia) - (Kf/J)*omega - MR/J;

    dxdt = [dphi_a; dphi_b; dia; dib; domega];
end
