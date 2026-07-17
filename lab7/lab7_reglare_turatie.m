%% LABORATOR NR. 7 - Simularea sistemului de reglare a turatiei (fig. 7.8)
%%
%% Schema bucla inchisa cu regulator PI si blocuri VCO:
%%   w (referinta turatie) -> [Σ] -> [R_PI] -> c (frecventa) -> [VCO1,VCO2]
%%                                   |                              |
%%   n (turatie) <-- [Model Motor Asincron] <-- ua, ub ←──────────┘
%%                      |
%%                      └── n -> [Σ]
%%
%% Blocurile VCO genereaza:
%%   ua = U1 * f/fn,  ub = U2 * f/fn
%% unde U1, U2 sunt amplitudinile sinusoidale si f = c (frecventa comandata)
%%
%% Semnalul de referinta: trepte multiple (fig. 7.9)
%%   0-5s:   0   -> 1000 rot/min
%%   5-10s:  1000 -> 2000 rot/min
%%   10-15s: 2000 -> 1500 rot/min



%% Incarcare parametri
if ~exist('lab7_params.mat','file')
    fprintf('Rulati mai intai lab7_metoda_releului.m!\n');
    return;
end
load('lab7_params.mat');

%% =========================================================
%% PARAMETRI REGULATOR PI (din lucrare, ec. 7.12)
%% =========================================================
% Regulatorul PI modificat (K redus de 4x):
KR = KR2;    % = 0.0027
TI = TI2;    % = 0.096 s

fprintf('=== REGULATOR PI (ec. 7.12) ===\n');
fprintf('K_R = %.6f,  T_I = %.4f s\n\n', KR, TI);

%% =========================================================
%% SEMNALUL DE REFERINTA (fig. 7.9) - trepte multiple
%% =========================================================
t_end = 15;    % [s]
dt    = 1e-4;  % [s]

% REZOLVARE EROARE: Adaugarea apostrofului pentru a genera vector COLOANA
t_sim = (0:dt:t_end)';  
N     = length(t_sim);

% Semnal referinta [rot/min]
w_ref_arr = zeros(N, 1);
w_ref_arr(t_sim >= 0  & t_sim < 5)  = 1000;
w_ref_arr(t_sim >= 5  & t_sim < 10) = 2000;
w_ref_arr(t_sim >= 10)               = 1500;

fprintf('Semnalul de referinta (fig. 7.9):\n');
fprintf('  0-5s:   w = 1000 rot/min\n');
fprintf('  5-10s:  w = 2000 rot/min\n');
fprintf('  10-15s: w = 1500 rot/min\n\n');

%% =========================================================
%% SIMULARE IN BUCLA INCHISA
%% =========================================================
fprintf('Simulare bucla inchisa cu PI (0-%.0fs, dt=%.0e)...\n', t_end, dt);

% Stare initiala
x_state  = [0; 0; 0; 0; 0];    % [phi_a, phi_b, ia, ib, omega]
c_integ  = 0;                   % starea integratoare a regulatorului PI

% Frecventa initiala a VCO (corespunde turatie 0)
c_out    = 1e-6;                 % frecventa comandata [Hz] (evitam 0)

% Istorice
n_hist   = zeros(N, 1);
c_hist   = zeros(N, 1);
ua_hist  = zeros(N, 1);
ub_hist  = zeros(N, 1);

% Limite VCO (frecventa trebuie sa fie pozitiva)
c_min = 0.1;    % [Hz]
c_max = 60;     % [Hz]

for k = 1:N
    t_k   = t_sim(k);
    w_k   = w_ref_arr(k);          % referinta curenta [rot/min]
    
    omega_k = x_state(5);
    n_k   = (30/pi) * omega_k;    % turatie curenta [rot/min]
    
    % Abatere
    e_k = w_k - n_k;
    
    % Regulator PI (forma incrementala pentru integrare numerica)
    c_prop = KR * e_k;
    c_integ = c_integ + KR * (dt / TI) * e_k;
    
    % Comanda frecventa (semnalul c in Hz)
    c_out = c_prop + c_integ;
    c_out = max(c_min, min(c_max, c_out));   % saturatie
    
    % Blocuri VCO: ua = U_amp*sin(2*pi*c_out*t), ub defazat pi/2
    U1 = U_amp * c_out / fn;   % amplitudine proportionala cu frecventa
    ua_k = U1 * sin(2*pi*c_out*t_k + pi/2);
    ub_k = U1 * sin(2*pi*c_out*t_k);
    
    n_hist(k)  = n_k;
    c_hist(k)  = c_out;
    ua_hist(k) = ua_k;
    
    % Pas RK4 pentru ecuatiile motorului
    k1 = motor_rk4(t_k,      x_state,         alpha, beta, gamma, J, Kf, LM, Lr, Rs, Ls, MR, ua_k, ub_k);
    k2 = motor_rk4(t_k+dt/2, x_state+dt/2*k1, alpha, beta, gamma, J, Kf, LM, Lr, Rs, Ls, MR, ua_k, ub_k);
    k3 = motor_rk4(t_k+dt/2, x_state+dt/2*k2, alpha, beta, gamma, J, Kf, LM, Lr, Rs, Ls, MR, ua_k, ub_k);
    k4 = motor_rk4(t_k+dt,   x_state+dt*k3,   alpha, beta, gamma, J, Kf, LM, Lr, Rs, Ls, MR, ua_k, ub_k);
    x_state = x_state + (dt/6)*(k1 + 2*k2 + 2*k3 + k4);
end

fprintf('Simulare finalizata.\n\n');

%% =========================================================
%% ANALIZA PERFORMANTE
%% =========================================================
% Subdomeniu 1: 0-5s -> referinta 1000 rot/min
idx1 = (t_sim >= 0) & (t_sim < 5);
n_st1 = mean(n_hist(t_sim >= 4.5 & t_sim < 5));
tr1_idx = find( (t_sim < 5) & (n_hist >= 0.97*1000), 1, 'first');
tr1 = t_sim(tr1_idx);

% Subdomeniu 2: 5-10s -> referinta 2000 rot/min
n_st2 = mean(n_hist(t_sim >= 9.5 & t_sim < 10));
idx_start2 = find(t_sim >= 5, 1, 'first');
tr2_idx = find( (t_sim >= 5) & (t_sim < 10) & (n_hist >= 0.97*2000), 1, 'first');
tr2 = t_sim(tr2_idx) - 5;

% Subdomeniu 3: 10-15s -> referinta 1500 rot/min
n_st3 = mean(n_hist(t_sim >= 14.5 & t_sim < 15));
tr3_idx = find( (t_sim >= 10) & (n_hist >= 0.97*1500) & (n_hist <= 1.03*1500), 1, 'first');
tr3 = t_sim(tr3_idx) - 10;

% Frecventele de regim stationar (Corectat redundanta "find")
f_st1 = mean(c_hist(t_sim >= 4.5 & t_sim < 5));
f_st2 = mean(c_hist(t_sim >= 9.5 & t_sim < 10));
f_st3 = mean(c_hist(t_sim >= 14.5 & t_sim < 15));

fprintf('=== PERFORMANTE SISTEM REGLARE ===\n');
fprintf('Subdomeniu 1 (ref=1000 rot/min):\n');
fprintf('  n_stationar = %.2f rot/min,  tr = %.3f s\n', n_st1, tr1);
fprintf('  f_stationar = %.4f Hz (sincronism: %.2f rot/min)\n', f_st1, 60*f_st1);
fprintf('Subdomeniu 2 (ref=2000 rot/min):\n');
fprintf('  n_stationar = %.2f rot/min,  tr = %.3f s\n', n_st2, tr2);
fprintf('  f_stationar = %.4f Hz\n', f_st2);
fprintf('Subdomeniu 3 (ref=1500 rot/min):\n');
fprintf('  n_stationar = %.2f rot/min,  tr = %.3f s\n', n_st3, tr3);
fprintf('  f_stationar = %.4f Hz\n\n', f_st3);
fprintf('Frecventele stationare din lucrare: 17.005 Hz, 34.01 Hz, 25.512 Hz\n');
fprintf('(diferenta datorata alunecarii motorului)\n\n');

%% =========================================================
%% GRAFICE
%% =========================================================
% Figura 7.9 - Semnalul de referinta
figure(5);
plot(t_sim, w_ref_arr, 'r-', 'LineWidth', 2.5);
grid on;
xlabel('Timp [s]');
ylabel('w [rot/min]');
title('Fig. 7.9 - Semnalul de referinta (trepte multiple)');
xlim([0 15]);
ylim([-100 2500]);

% Figura 7.10 - Turatia motorului in bucla inchisa
figure(6);
plot(t_sim, n_hist, 'b-', 'LineWidth', 1.5, 'DisplayName', 'n(t) - turatie');
hold on;
plot(t_sim, w_ref_arr, 'r--', 'LineWidth', 1.5, 'DisplayName', 'w(t) - referinta');
grid on;
xlabel('Timp [s]');
ylabel('n [rot/min]');
title('Fig. 7.10 - Turatia motorului asincron in bucla inchisa');
legend('Location', 'southeast');
xlim([0 15]);

% Figura 7.11 - Evolutia semnalului de comanda (frecventa)
figure(7);
plot(t_sim, c_hist, 'g-', 'LineWidth', 1.5);
hold on;
yline(f_st1, 'r:', 'LineWidth', 1, 'DisplayName', sprintf('f_{1}=%.2fHz', f_st1));
yline(f_st2, 'm:', 'LineWidth', 1, 'DisplayName', sprintf('f_{2}=%.2fHz', f_st2));
yline(f_st3, 'c:', 'LineWidth', 1, 'DisplayName', sprintf('f_{3}=%.2fHz', f_st3));
grid on;
xlabel('Timp [s]');
ylabel('c [Hz]');
title('Fig. 7.11 - Evolutia semnalului de comanda (frecventa tensiunii)');
legend('c(t)','','','','Location','southeast');
xlim([0 15]);

% Figura 7.12 - Tensiunea ua (primele 3s pentru claritate)
idx_ua = t_sim <= 3;
figure(8);
plot(t_sim(idx_ua), ua_hist(idx_ua), 'k-', 'LineWidth', 0.5);
grid on;
xlabel('Timp [s]');
ylabel('u_a [V]');
title('Fig. 7.12 echiv. - Evolutia tensiunii de alimentare u_a (primele 3s)');
fprintf('Figurile 5-8 generate (echivalente fig. 7.9-7.12 din lucrare).\n');

%% =========================================================
%% SIMULARE COMPARATIVA: Referinta cu "intarziere" (cerinta 7.5 pct.2)
%% =========================================================
fprintf('\n=== CERINTA 7.5 pct. 2: Referinta cu intarziere ===\n');
T_int = 1.0;   % [s] constanta de timp filtru intarziere
fprintf('Filtru intarziere ordinul I: T_int = %.1f s\n\n', T_int);

% Simulam referinta filtrata
w_ref_filt = zeros(N, 1);
w_filt_state = 0;
for k = 1:N
    w_filt_state = w_filt_state + dt * (w_ref_arr(k) - w_filt_state) / T_int;
    w_ref_filt(k) = w_filt_state;
end

% Resimulam cu referinta filtrata
x_state2 = [0; 0; 0; 0; 0];
c_integ2  = 0;
c_out2    = 1e-6;
n_hist2   = zeros(N, 1);
c_hist2   = zeros(N, 1);

for k = 1:N
    t_k   = t_sim(k);
    w_k   = w_ref_filt(k);
    omega_k = x_state2(5);
    n_k   = (30/pi) * omega_k;
    e_k = w_k - n_k;
    
    c_prop2  = KR * e_k;
    c_integ2 = c_integ2 + KR * (dt/TI) * e_k;
    c_out2   = max(c_min, min(c_max, c_prop2 + c_integ2));
    
    U1_2  = U_amp * c_out2 / fn;
    ua_k2 = U1_2 * sin(2*pi*c_out2*t_k + pi/2);
    ub_k2 = U1_2 * sin(2*pi*c_out2*t_k);
    
    n_hist2(k) = n_k;
    c_hist2(k) = c_out2;
    
    k1 = motor_rk4(t_k,      x_state2,         alpha,beta,gamma,J,Kf,LM,Lr,Rs,Ls,MR,ua_k2,ub_k2);
    k2 = motor_rk4(t_k+dt/2, x_state2+dt/2*k1, alpha,beta,gamma,J,Kf,LM,Lr,Rs,Ls,MR,ua_k2,ub_k2);
    k3 = motor_rk4(t_k+dt/2, x_state2+dt/2*k2, alpha,beta,gamma,J,Kf,LM,Lr,Rs,Ls,MR,ua_k2,ub_k2);
    k4 = motor_rk4(t_k+dt,   x_state2+dt*k3,   alpha,beta,gamma,J,Kf,LM,Lr,Rs,Ls,MR,ua_k2,ub_k2);
    x_state2 = x_state2 + (dt/6)*(k1+2*k2+2*k3+k4);
end

figure(9);
subplot(2,1,1);
plot(t_sim, n_hist,  'b-',  'LineWidth',1.5, 'DisplayName','Fara intarziere');
hold on;
plot(t_sim, n_hist2, 'r--', 'LineWidth',1.5, 'DisplayName',sprintf('Cu intarziere T_{int}=%.1fs', T_int));
plot(t_sim, w_ref_arr, 'k:', 'LineWidth',1, 'DisplayName','Referinta');
grid on; xlabel('Timp [s]'); ylabel('n [rot/min]');
title('Cerinta 7.5 pct.2 - Comparatie cu/fara intarzierea referintei');
legend('Location','southeast'); xlim([0 15]);

subplot(2,1,2);
plot(t_sim, c_hist,  'b-',  'LineWidth',1.5, 'DisplayName','c fara intarziere');
hold on;
plot(t_sim, c_hist2, 'r--', 'LineWidth',1.5, 'DisplayName','c cu intarziere');
grid on; xlabel('Timp [s]'); ylabel('c [Hz]');
title('Semnalul de comanda c (frecventa) - comparatie');
legend; xlim([0 15]);

%% =========================================================
%% FUNCTIA MODEL MOTOR (RK4 step)
%% =========================================================
function dxdt = motor_rk4(~, x, alpha, beta, gamma, J, Kf, LM, Lr, Rs, Ls, MR, ua, ub)
    phi_a=x(1); phi_b=x(2); ia=x(3); ib=x(4); omega=x(5);
    dphi_a = -alpha*phi_a - omega*phi_b + LM*alpha*ia;
    dphi_b = -alpha*phi_b + omega*phi_a + LM*alpha*ib;
    dia    = -beta*dphi_a + (1/(gamma*Ls))*(ua - Rs*ia);
    dib    = -beta*dphi_b + (1/(gamma*Ls))*(ub - Rs*ib);
    domega = (1/J)*(LM/Lr)*(phi_a*ib - phi_b*ia) - (Kf/J)*omega - MR/J;
    dxdt   = [dphi_a; dphi_b; dia; dib; domega];
end