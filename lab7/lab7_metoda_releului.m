%% LABORATOR NR. 7 - Metoda releului pentru calculul parametrilor regulatorului
%%
%% Schema fig. 7.6: Releu bipozitional -> Bloc generare Ua/Ub -> Model Motor
%% Rampele de variatie cu histerezis a = ±50 rot/min
%% Iesirea releului b = ±1 (scala frecventa)
%% ua = 220*sqrt(2)*sin(2*pi*f*t + pi/2),  f = b*220*sqrt(2)*sin(2*pi*fn*t)/fn
%%
%% Din oscilatii intretinute se citesc: A0, T0
%% Apoi: K0 = 4*b/(pi*A0), iar parametrii PI din Tabelul 7.1



%% Parametri motor
J=0.4; Kf=0.1115; Rr=0.156; Rs=0.294;
Lr=0.0417; Ls=0.0424; LM=0.041; MR=0;
alpha=Rr/Lr; beta=LM/(Ls*Lr); gamma=1-LM^2/(Ls*Lr);
fn=50; U_amp=220*sqrt(2);

%% =========================================================
%% SIMULARE METODA RELEULUI (fig. 7.6 si 7.7)
%% Releu bipozitional cu histerezis a = ±50 rot/min
%% =========================================================
a_hyst = 50;    % [rot/min] banda histerezis ±50
b_val  = 1;     % amplitudinea iesirii releului (frecventa normalizata)
w_ref  = 0;     % [rot/min] referinta (w=0 pentru metoda releului)

fprintf('=== METODA RELEULUI ===\n');
fprintf('Histerezis: a = +/-%.0f rot/min\n', a_hyst);
fprintf('Iesire releu: b = +/-%.1f\n\n', b_val);

% Functia model motor cu releu bipozitional
% Starea releului: +1 sau -1 (determinata de iesire si histerezis)
b_releu = 1;    % stare initiala releu
b_arr   = [];   % istoric stare releu
t_arr   = [];   % timp

% Simulam pas cu pas (dt mic pentru a surprinde comutarile releului)
dt    = 1e-4;
t_end = 10;     % [s]
t_sim = 0:dt:t_end;
N     = length(t_sim);

x_state = [0; 0; 0; 0; 0];   % [phi_a, phi_b, ia, ib, omega]
n_hist  = zeros(N, 1);
b_hist  = zeros(N, 1);
omega_hist = zeros(N, 1);

fprintf('Simulare metoda releului (0-%.0fs, dt=%.0e)...\n', t_end, dt);

for k = 1:N
    t_k = t_sim(k);
    omega_k = x_state(5);
    n_k = (30/pi) * omega_k;
    n_hist(k) = n_k;
    b_hist(k) = b_releu;
    omega_hist(k) = omega_k;

    % Logica releu bipozitional cu histerezis (in rot/min)
    % w_ref = 0, abatere = w_ref - n
    abatere = w_ref - n_k;
    if b_releu > 0
        if abatere < -a_hyst
            b_releu = -b_val;
        end
    else
        if abatere > a_hyst
            b_releu = b_val;
        end
    end

    % Frecventa instantanee = b_releu * fn
    f_inst = b_releu * fn;

    % Tensiunile statorice cu frecventa controlata de releu
    ua_k = U_amp * sin(2*pi*f_inst*t_k + pi/2);
    ub_k = U_amp * sin(2*pi*f_inst*t_k);

    % Pas RK4 pentru ecuatiile motorului
    k1 = motor_ode_relay(t_k,      x_state,         alpha, beta, gamma, J, Kf, LM, Lr, Rs, Ls, MR, ua_k, ub_k);
    k2 = motor_ode_relay(t_k+dt/2, x_state+dt/2*k1, alpha, beta, gamma, J, Kf, LM, Lr, Rs, Ls, MR, ua_k, ub_k);
    k3 = motor_ode_relay(t_k+dt/2, x_state+dt/2*k2, alpha, beta, gamma, J, Kf, LM, Lr, Rs, Ls, MR, ua_k, ub_k);
    k4 = motor_ode_relay(t_k+dt,   x_state+dt*k3,   alpha, beta, gamma, J, Kf, LM, Lr, Rs, Ls, MR, ua_k, ub_k);
    x_state = x_state + (dt/6)*(k1 + 2*k2 + 2*k3 + k4);
end

%% =========================================================
%% ANALIZA OSCILATII INTRETINUTE (din t=2.5s pana la sfarsit)
%% =========================================================
idx_start = find(t_sim >= 2.5, 1);
n_osc = n_hist(idx_start:end);
t_osc = t_sim(idx_start:end);

% Amplitudinea A0 (jumatate din domeniu de variatie)
A0 = (max(n_osc) - min(n_osc)) / 2;

% Perioada T0: detectam perioadele din zero-crossing-uri
zero_cross = find(diff(sign(n_osc)) > 0);  % treceri ascendente prin 0
if length(zero_cross) >= 2
    T0 = mean(diff(t_osc(zero_cross))) * 2;  % perioada completa
else
    T0 = 0.12;  % valoare din exemplul lucrarii
    fprintf('ATENTIE: Perioade insuficiente detectate, folosim T0=%.3fs din lucrare\n', T0);
end

% Factorul de amplificare echivalent al releului (ec. 7.8)
K0 = 4 * b_val / (pi * A0);

fprintf('\n=== REZULTATE METODA RELEULUI ===\n');
fprintf('A0 = %.4f rot/min (amplitudinea oscilatiilor)\n', A0);
fprintf('T0 = %.4f s      (perioada oscilatiilor)\n', T0);
fprintf('K0 = 4*b/(pi*A0) = %.6f\n\n', K0);

% Comparatie cu valorile din lucrare
fprintf('Valori din exemplul lucrarii: A0=52.6 rot/min, T0=0.12s, K0=0.0242\n\n');

%% =========================================================
%% CALCUL PARAMETRI REGULATOARE (Tabelul 7.1 - Ziegler-Nichols releu)
%% =========================================================
fprintf('=== PARAMETRI REGULATOARE (Tabelul 7.1) ===\n');

% Regulator P
KR_P = 0.5 * K0;
fprintf('P:   K_R = 0.5*K0 = %.6f\n', KR_P);

% Regulator PI
KR_PI = 0.45 * K0;
TI_PI = 0.8 * T0;
fprintf('PI:  K_R = 0.45*K0 = %.6f,  T_I = 0.8*T0 = %.5f s\n', KR_PI, TI_PI);

% Regulator PID
KR_PID = 0.6 * K0;
TI_PID = 0.5 * T0;
TD_PID = 0.12 * T0;
fprintf('PID: K_R = 0.6*K0 = %.6f,  T_I = %.5f s,  T_D = %.5f s\n', KR_PID, TI_PID, TD_PID);

% Regulatorul PI initial (ec. 7.11) - valori din lucrare
KR1 = 0.0109;
TI1 = 0.096;
fprintf('\nRegulator PI initial (ec. 7.11): K_R1=%.4f, T_I1=%.4f s\n', KR1, TI1);

% Regulatorul PI modificat (ec. 7.12) - KR redus de 4 ori pentru stabilitate
KR2 = KR1 / 4;
TI2 = TI1;
fprintf('Regulator PI modificat (ec. 7.12): K_R2=%.6f, T_I2=%.4f s\n', KR2, TI2);
fprintf('  (KR redus de 4x pentru a respecta constrangerile sistemului neliniar)\n\n');

%% =========================================================
%% SALVARE PARAMETRI
%% =========================================================
save('lab7_params.mat', 'K0','T0','A0','b_val','a_hyst', ...
    'KR_PI','TI_PI','KR_PID','TI_PID','TD_PID','KR1','TI1','KR2','TI2', ...
    'J','Kf','Rr','Rs','Lr','Ls','LM','MR','alpha','beta','gamma','fn','U_amp');
fprintf('Parametri salvati in lab7_params.mat\n');

%% =========================================================
%% GRAFICE
%% =========================================================
% Figura 7.5 / 7.7 - Oscilatii intretinute ale turatiei
figure(3);
plot(t_sim, n_hist, 'b-', 'LineWidth', 0.8);
hold on;
yline(w_ref + a_hyst, 'r--', 'LineWidth', 1, 'DisplayName', sprintf('+a = +%.0f rot/min', a_hyst));
yline(w_ref - a_hyst, 'g--', 'LineWidth', 1, 'DisplayName', sprintf('-a = -%.0f rot/min', a_hyst));
yline(0, 'k:', 'LineWidth', 1);
grid on;
xlabel('Timp [s]');
ylabel('n [rot/min]');
title(sprintf('Fig. 7.7 - Oscilatiile sistemului (metoda releului cu histerezis a=±%.0f)\nA_0=%.2f rot/min, T_0=%.4f s, K_0=%.5f', a_hyst, A0, T0, K0));
legend('n(t)', sprintf('+a=+%.0f', a_hyst), sprintf('-a=-%.0f', a_hyst), 'Location','northeast');
xlim([0 t_end]);

% Zoom pe oscilatii intretinute (ultimele 2 secunde)
figure(4);
idx_zoom = find(t_sim >= t_end - 2);
plot(t_sim(idx_zoom), n_hist(idx_zoom), 'b-', 'LineWidth', 1.5);
hold on;
yline(A0, 'r--', 'LineWidth', 1, 'DisplayName', sprintf('A_0 = %.2f rot/min', A0));
yline(-A0, 'r--', 'LineWidth', 1, 'HandleVisibility','off');
grid on;
xlabel('Timp [s]');
ylabel('n [rot/min]');
title(sprintf('Fig. 7.5 echiv. - Oscilatii intretinute\nA_0=%.2f rot/min, T_0=%.4f s', A0, T0));
legend('Location','northeast');

%% =========================================================
%% FUNCTIA MODEL MOTOR (pentru pas cu pas)
%% =========================================================
function dxdt = motor_ode_relay(~, x, alpha, beta, gamma, J, Kf, LM, Lr, Rs, Ls, MR, ua, ub)
    phi_a=x(1); phi_b=x(2); ia=x(3); ib=x(4); omega=x(5);
    dphi_a = -alpha*phi_a - omega*phi_b + LM*alpha*ia;
    dphi_b = -alpha*phi_b + omega*phi_a + LM*alpha*ib;
    dia    = -beta*dphi_a + (1/(gamma*Ls))*(ua - Rs*ia);
    dib    = -beta*dphi_b + (1/(gamma*Ls))*(ub - Rs*ib);
    domega = (1/J)*(LM/Lr)*(phi_a*ib - phi_b*ia) - (Kf/J)*omega - MR/J;
    dxdt   = [dphi_a; dphi_b; dia; dib; domega];
end
