%% LABORATOR NR. 3 - Sisteme de Reglare Numerice
%% 3.2 Metoda Dahlin
% Functia de transfer a partii fixate:
%   H_f1(s) = 4.3 / ((1+5s)(1+23s)) * e^(-2.5s)
%
% Perioada de esantionare: T_E = T_m/3 = 2.5/3 ~ 0.833 min
% Se rotunjeste la T_E = 0.5 min (recomandat submultiplu al timpului mort)
clearvars -except cd_old; clc; close all;

%% Parametrii partii fixate
Kf  = 4.3;
T1  = 5;    % [min]
T2  = 23;   % [min]
Tm  = 2.5;  % [min] - timp mort

% Perioada de esantionare (T_E = T_m / 3)
TE  = 0.5;  % [min]

fprintf('=== METODA DAHLIN ===\n');
fprintf('Parametrii:\n');
fprintf('  Kf = %.4f\n', Kf);
fprintf('  T1 = %.1f min\n', T1);
fprintf('  T2 = %.1f min\n', T2);
fprintf('  Tm = %.1f min\n', Tm);
fprintf('  TE = %.2f min (TE = Tm/%.0f)\n', TE, Tm/TE);

%% Pasul 1: Functia de transfer discretizata a partii fixate (cu EOZ)
% Definire sistem continuu (fara timp mort)
num_c = Kf;
den_c = conv([T1 1], [T2 1]);   % (T1*s+1)(T2*s+1)
sys_c = tf(num_c, den_c);

% Numarul de perioade corespunzator timpului mort
nd = round(Tm / TE);   % numar delay-uri intregi
fprintf('\nNumar perioade timp mort: nd = %d\n', nd);

% Discretizare cu ZOH
sys_d = c2d(sys_c, TE, 'zoh');
[Bn, An] = tfdata(sys_d, 'v');

fprintf('\nFunctia de transfer discreta a partii fixate (fara timp mort):\n');
disp_tf_z(Bn, An, 'H_f(z)');

% Introducere timp mort: inmultire cu z^(-nd)
fprintf('Cu timp mort z^(-%d):\n', nd);
fprintf('  Numarator: [');
fprintf(' %.4f', Bn);
fprintf(repmat(' 0', 1, nd));
fprintf(' ]\n');

%% Pasul 2: Functia de transfer H0(z) - sistem in bucla inchisa impusa
T01 = 3;   % [min] - constanta de timp impusa (< T1=5)
fprintf('\nConstanta de timp impusa T01 = %.1f min\n', T01);

% Sistem in bucla inchisa impusa (continuu, fara timp mort)
sys_0c = tf(1, [T01 1]);
sys_0d = c2d(sys_0c, TE, 'zoh');
[B0n, A0n] = tfdata(sys_0d, 'v');

fprintf('\nFunctia de transfer discreta H0(z) (fara timp mort):\n');
disp_tf_z(B0n, A0n, 'H0(z)');

%% Pasul 3: Functia de transfer a regulatorului
% Numarator regulator (inainte de aplicarea delay-ului)
num_R_nodelay = conv(An, B0n);

% Numitor regulator: B_f * (A0 - B0)
A0_minus_B0 = A0n;
A0_minus_B0(1:length(B0n)) = A0_minus_B0(1:length(B0n)) - B0n;
den_R = conv(Bn, A0_minus_B0);

% Zerouri la STANGA = deplasare spre puteri mai mici = intarziere corecta
num_R = [zeros(1, nd), num_R_nodelay];

% --- FIX pentru NaN / Inf (eliminare zerouri conducatoare) ---
% Cautam primul element non-zero din numitor
idx_den = find(abs(den_R) > 1e-10, 1, 'first');
if idx_den > 1
    shift_val = idx_den - 1;
    % Trunchiem zerourile initiale atat de la numitor cat si de la numarator
    den_R = den_R(shift_val+1:end);
    num_R = num_R(shift_val+1:end);
end

% Acum putem normaliza in siguranta
num_R = num_R / den_R(1);
den_R = den_R / den_R(1);

% --- FIX pentru functie de transfer proprie (cauzala) ---
% Asiguram lungimi compatibile intre numitor si numarator adaugand poli in origine
grad_num = length(num_R) - 1;
grad_den = length(den_R) - 1;

if grad_num > grad_den
    den_R = [den_R, zeros(1, grad_num - grad_den)];
elseif grad_den > grad_num
    num_R = [zeros(1, grad_den - grad_num), num_R];
end

fprintf('\nFunctia de transfer a regulatorului numeric H_R(z):\n');
disp_tf_z(num_R, den_R, 'H_R(z)');

%% Simulare sistem in bucla inchisa
fprintf('\n=== SIMULARE ===\n');
t_sim = 0:TE:80;   % vector timp [min]
N = length(t_sim);
w  = ones(1, N);   % semnal referinta treapta unitara
p  = zeros(1, N);  % perturbatie nula
y  = zeros(1, N);
c  = zeros(1, N);
e  = zeros(1, N);

% Ordine polinoame
na = length(An) - 1;
nb = length(Bn) - 1;
nR_num = length(num_R) - 1;
nR_den = length(den_R) - 1;

for k = (max(nR_den, nd) + 2):N
    % Eroarea de reglare
    e(k) = w(k) - y(k);
    
    % Calculul comenzii (regulator)
    c_k = 0;
    for i = 0:nR_num
        if k-i >= 1
            c_k = c_k + num_R(i+1) * e(k-i);
        end
    end
    for i = 1:nR_den
        if k-i >= 1
            c_k = c_k - den_R(i+1) * c(k-i);
        end
    end
    c(k) = c_k;
    
    % Iesirea partii fixate (cu timp mort nd perioade)
    y_k = 0;
    for i = 0:nb
        if k-i-nd >= 1
            y_k = y_k + Bn(i+1) * c(max(1, k-i-nd));
        end
    end
    for i = 1:na
        if k-i >= 1
            y_k = y_k - An(i+1) * y(k-i);
        end
    end
    y(k) = y_k;
end

%% Calcul performante
a_stp = abs(w(end) - y(end));
fprintf('Abaterea stationara la pozitie: a_stp = %.4f\n', a_stp);

[y_max, ~] = max(y);
sigma = max(0, (y_max - w(end)) / w(end) * 100);
fprintf('Suprareglajul: sigma = %.2f %%\n', sigma);

y_st = w(end);
banda = 0.03 * y_st;
tr = NaN;
for k = 1:N
    if all(abs(y(k:end) - y_st) <= banda)
        tr = t_sim(k);
        break;
    end
end
fprintf('Timpul de raspuns (banda 3%%): tr = %.2f min\n', tr);
fprintf('Domeniu comanda: [%.4f, %.4f]\n', min(c), max(c));

%% Grafice
figure('Name', 'Metoda Dahlin - Regulator initial', 'Position', [100 100 900 600]);
subplot(2,1,1);
plot(t_sim, y, 'b-', 'LineWidth', 1.5); hold on;
plot(t_sim, w, 'r--', 'LineWidth', 1);
xlabel('Timp [min]'); ylabel('y');
title('Raspunsul sistemului - Metoda Dahlin (regulator initial)');
legend('y (iesire)', 'w (referinta)');
grid on;

subplot(2,1,2);
plot(t_sim, c, 'b-', 'LineWidth', 1.5);
xlabel('Timp [min]'); ylabel('c');
title('Evolutia semnalului de comanda - Metoda Dahlin (regulator initial)');
grid on;
saveas(gcf, 'dahlin_regulator_initial.png');

%% Regulator modificat - eliminare pol nedorit
fprintf('\n=== REGULATOR MODIFICAT (eliminare pol) ===\n');

% Calculam polii si zerourile regulatorului
[z_R, p_R, k_R] = tf2zp(num_R, den_R);
fprintf('Polii regulatorului:\n');
disp(p_R);
fprintf('Zerourile regulatorului:\n');
disp(z_R);

p_sorted = sort(abs(p_R - 1));
fprintf('\nAplicati regulatorul modificat conform teoriei (substitutie z=1 in factorul polului nedorit)\n');

%% Simulare cu saturatie comanda c in [0,1]
fprintf('\n=== SIMULARE CU SATURATIE [0,1] ===\n');
y_sat  = zeros(1, N);
c_sat  = zeros(1, N);
e_sat  = zeros(1, N);

for k = (max(nR_den, nd) + 2):N
    e_sat(k) = w(k) - y_sat(k);
    
    c_k = 0;
    for i = 0:nR_num
        if k-i >= 1
            c_k = c_k + num_R(i+1) * e_sat(k-i);
        end
    end
    for i = 1:nR_den
        if k-i >= 1
            c_k = c_k - den_R(i+1) * c_sat(k-i);
        end
    end
    
    % Saturatie
    c_sat(k) = max(0, min(1, c_k));
    
    y_k = 0;
    for i = 0:nb
        if k-i-nd >= 1
            y_k = y_k + Bn(i+1) * c_sat(max(1, k-i-nd));
        end
    end
    for i = 1:na
        if k-i >= 1
            y_k = y_k - An(i+1) * y_sat(k-i);
        end
    end
    y_sat(k) = y_k;
end

[y_max_sat, ~] = max(y_sat);
sigma_sat = max(0, (y_max_sat - 1) / 1 * 100);

tr_sat = NaN;
for k = 1:N
    if all(abs(y_sat(k:end) - 1) <= 0.03)
        tr_sat = t_sim(k);
        break;
    end
end

fprintf('Cu saturatie c in [0,1]:\n');
fprintf('  Suprareglaj: sigma = %.2f %%\n', sigma_sat);
fprintf('  Timp raspuns: tr = %.2f min\n', tr_sat);
fprintf('  Domeniu comanda: [%.4f, %.4f]\n', min(c_sat), max(c_sat));

figure('Name', 'Metoda Dahlin - Cu saturatie', 'Position', [200 200 900 600]);
subplot(2,1,1);
plot(t_sim, y_sat, 'b-', 'LineWidth', 1.5); hold on;
plot(t_sim, w, 'r--', 'LineWidth', 1);
xlabel('Timp [min]'); ylabel('y');
title('Raspunsul sistemului - Dahlin cu saturatie comanda [0,1]');
legend('y (iesire)', 'w (referinta)');
grid on;

subplot(2,1,2);
plot(t_sim, c_sat, 'b-', 'LineWidth', 1.5);
xlabel('Timp [min]'); ylabel('c');
title('Evolutia semnalului de comanda cu saturatie [0,1]');
grid on;
saveas(gcf, 'dahlin_cu_saturatie.png');

%% Centralizare rezultate
fprintf('\n=== TABEL CENTRALIZARE REZULTATE ===\n');
fprintf('%-45s | %8s | %10s | %10s | %20s\n', ...
    'Cazul tratat', 'a_stp', 'sigma [%]', 'tr [min]', '[c_min, c_max]');
fprintf('%s\n', repmat('-', 1, 110));
fprintf('%-45s | %8.4f | %10.2f | %10.2f | [%8.4f, %8.4f]\n', ...
    'Dahlin, regulator initial', a_stp, sigma, tr, min(c), max(c));
fprintf('%-45s | %8.4f | %10.2f | %10.2f | [%8.4f, %8.4f]\n', ...
    'Dahlin, saturatie [0,1]', abs(1-y_sat(end)), sigma_sat, tr_sat, min(c_sat), max(c_sat));