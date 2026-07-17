%% LABORATOR NR. 3 - Sisteme de Reglare Numerice
%% 3.3 Metoda Kalman
% Functia de transfer a partii fixate:
%   H_f2(s) = 1.25 / ((1+9s)(1+14s)) * e^(-3s)
%
% Perioada de esantionare: T_E = T_m/4 = 3/4 = 0.75 ~ 1 min (rotunjire)

clearvars -except cd_old; clc; close all;

%% Parametrii partii fixate
Kf  = 1.25;
T12 = 9;    % [min]
T22 = 14;   % [min]
Tm  = 3;    % [min] - timp mort

% Perioada de esantionare
TE  = 1;    % [min]  (T_E = T_m/4 conform teoriei)

fprintf('=== METODA KALMAN ===\n');
fprintf('Parametrii:\n');
fprintf('  Kf  = %.4f\n', Kf);
fprintf('  T12 = %.1f min\n', T12);
fprintf('  T22 = %.1f min\n', T22);
fprintf('  Tm  = %.1f min\n', Tm);
fprintf('  TE  = %.2f min (TE = Tm/%.0f)\n', TE, Tm/TE);

%% Pasul 1: Discretizare parte fixa cu EOZ
num_c = Kf;
den_c = conv([T12 1], [T22 1]);
sys_c = tf(num_c, den_c);

nd = round(Tm / TE);
fprintf('\nNumar perioade timp mort: nd = %d\n', nd);

sys_d = c2d(sys_c, TE, 'zoh');
[Bn, An] = tfdata(sys_d, 'v');

fprintf('\nFunctia de transfer discreta H_f(z) (fara timp mort):\n');
disp_tf_z(Bn, An, 'H_f(z)');

% Forma generala H_f(z) = B(z)/A(z) * z^(-nd)
% B(z) = b0 + b1*z^-1 + ... + bm*z^-m
% A(z) = a0 + a1*z^-1 + ... + an*z^-n
fprintf('Cu timp mort z^(-%d)\n', nd);

%% Pasul 2: Verificare suma coeficienti numarator
S = sum(Bn);
fprintf('\nSuma coeficientilor numaratorului S = %.6f\n', S);

if abs(S - 1) > 1e-4
    K = 1/S;
    fprintf('S ≠ 1 => K = 1/S = %.4f\n', K);
else
    K = 1;
    fprintf('S = 1 => K = 1 (nu e necesara amplificarea)\n');
end

%% Pasul 3: Amplificare cu K
% P(z)/Q(z) = K*B(z) / (K*A(z))
Pn = K * Bn;
Qn = K * An;

fprintf('\nDupa amplificare:\n');
disp_tf_z(Pn, Qn, 'K*H_f(z) = P(z)/Q(z)');
fprintf('  Suma coeficienti B dupa amplificare: %.4f\n', sum(Pn));

%% Pasul 4: Functia de transfer a regulatorului
% H_R(z) = Q(z) / (1 - P(z))  [cu delay z^(-nd) la P]

% 1 - P(z) (cu delay): numaratorul P are z^(-nd)
% In implementare: (A(z)*K - B(z)*K * z^(-nd))
% dar uzual se lucreaza direct cu coeficientii

% Numitor regulator: den_R = Q * (1 - P*z^-nd)
% Pentru z^(-nd) in P: adaugam nd zerouri la coada lui P
P_delayed = [Pn, zeros(1, nd)];
Q_delayed = [Qn, zeros(1, nd)];

% 1 - P(z)*z^(-nd): polinom de gradul (m+nd)
one_minus_P = -P_delayed;
one_minus_P(1) = one_minus_P(1) + 1;  % adauga 1 la coef z^0

% Numaratorul regulatorului = Q(z)
% Numitorul regulatorului = 1 - P(z)
num_R = Qn;
den_R = one_minus_P;

% Normalizare
den_R = den_R / den_R(1);
num_R = num_R / den_R(1);
% Recalculeaza dupa normalizare
scale = one_minus_P(1);
num_R = Qn / scale;
den_R = one_minus_P / scale;

fprintf('\nFunctia de transfer a regulatorului H_R(z) = Q(z)/(1-P(z)):\n');
disp_tf_z(num_R, den_R, 'H_R(z)');

%% Verificare poli si zerouri
[z_R, p_R, k_R] = tf2zp(num_R, den_R);
fprintf('\nPolii regulatorului:\n');
disp(p_R);
fprintf('Zerourile regulatorului:\n');
disp(z_R);

%% Simulare sistem in bucla inchisa
fprintf('\n=== SIMULARE ===\n');

t_sim = 0:TE:120;
N = length(t_sim);
w = ones(1, N);

y  = zeros(1, N);
c  = zeros(1, N);
e  = zeros(1, N);

na = length(An) - 1;
nb = length(Bn) - 1;
nR_num = length(num_R) - 1;
nR_den = length(den_R) - 1;

for k = (max(nR_den, nd) + 2):N
    e(k) = w(k) - y(k);
    
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

%% Performante
a_stp = abs(w(end) - y(end));
[y_max, ~] = max(y);
sigma = max(0, (y_max - 1)/1 * 100);
tr = NaN;
for k = 1:N
    if all(abs(y(k:end) - 1) <= 0.03)
        tr = t_sim(k);
        break;
    end
end

fprintf('Abaterea stationara: a_stp = %.4f\n', a_stp);
fprintf('Suprareglaj: sigma = %.2f %%\n', sigma);
fprintf('Timp raspuns (banda 3%%): tr = %.2f min\n', tr);
fprintf('Domeniu comanda: [%.4f, %.4f]\n', min(c), max(c));

%% Grafice - regulator initial
figure('Name', 'Metoda Kalman - Regulator initial', 'Position', [100 100 900 600]);
subplot(2,1,1);
plot(t_sim, y, 'b-', 'LineWidth', 1.5); hold on;
plot(t_sim, w, 'r--', 'LineWidth', 1);
xlabel('Timp [min]'); ylabel('y');
title('Raspunsul sistemului - Metoda Kalman (regulator initial)');
legend('y (iesire)', 'w (referinta)');
grid on;

subplot(2,1,2);
plot(t_sim, c, 'b-', 'LineWidth', 1.5);
xlabel('Timp [min]'); ylabel('c');
title('Evolutia semnalului de comanda - Kalman (regulator initial)');
grid on;

saveas(gcf, 'kalman_regulator_initial.png');

%% Regulator modificat (eliminare pol nedorit aproape de cerc unitate)
fprintf('\n=== REGULATOR MODIFICAT ===\n');

% Gasim polul cel mai apropiat de z=1 (exceptand integratorul z=1)
p_real = p_R(abs(imag(p_R)) < 1e-8);  % poli reali
p_real_no_int = p_real(abs(p_real - 1) > 1e-6);
[~, idx] = min(abs(p_real_no_int - 1));

if ~isempty(p_real_no_int)
    p_elim = p_real_no_int(idx);
    fprintf('Polul eliminat: z2 = %.4f\n', p_elim);
    factor_val = 1 + p_elim;  % (1 + p*z^-1) evaluate la z^-1=1 => 1 + p
    fprintf('Valoarea factorului (1 + %.4f*z^-1) la z^-1=1: %.4f\n', -p_elim, factor_val);
    
    % Construim regulatorul modificat
    % Impartim numitorul la (1 - p_elim*z^-1) si inmultim cu valoarea sa la z=1
    factor_poly = [1, -p_elim];
    [num_Rm, rem_n] = deconv(num_R, 1);  % placeholder
    
    % Metoda directa: den_R_m = den_R / (1 - p_elim*z^-1) * factor_val
    % Deconvolutie
    if length(den_R) >= length(factor_poly)
        [quot, rem_d] = deconv(den_R, factor_poly);
        if max(abs(rem_d)) < 1e-6
            den_Rm = quot * factor_val;
            num_Rm = num_R * factor_val;
            fprintf('\nRegulator modificat H_Rm(z):\n');
            disp_tf_z(num_Rm, den_Rm, 'H_Rm(z)');
        else
            fprintf('Impartirea exacta nu e posibila, se foloseste regulatorul initial modificat.\n');
            den_Rm = den_R;
            num_Rm = num_R;
        end
    else
        den_Rm = den_R;
        num_Rm = num_R;
    end
else
    fprintf('Nu s-a gasit pol real de eliminat.\n');
    den_Rm = den_R;
    num_Rm = num_R;
end

%% Simulare cu regulator modificat
y_m  = zeros(1, N);
c_m  = zeros(1, N);
e_m  = zeros(1, N);

nRm_num = length(num_Rm) - 1;
nRm_den = length(den_Rm) - 1;

for k = (max(nRm_den, nd) + 2):N
    e_m(k) = w(k) - y_m(k);
    
    c_k = 0;
    for i = 0:nRm_num
        if k-i >= 1
            c_k = c_k + num_Rm(i+1) * e_m(k-i);
        end
    end
    for i = 1:nRm_den
        if k-i >= 1
            c_k = c_k - den_Rm(i+1) * c_m(k-i);
        end
    end
    c_m(k) = c_k;
    
    y_k = 0;
    for i = 0:nb
        if k-i-nd >= 1
            y_k = y_k + Bn(i+1) * c_m(max(1, k-i-nd));
        end
    end
    for i = 1:na
        if k-i >= 1
            y_k = y_k - An(i+1) * y_m(k-i);
        end
    end
    y_m(k) = y_k;
end

[y_max_m, ~] = max(y_m);
sigma_m = max(0, (y_max_m - 1)/1 * 100);
tr_m = NaN;
for k = 1:N
    if all(abs(y_m(k:end) - 1) <= 0.03)
        tr_m = t_sim(k);
        break;
    end
end
fprintf('Regulator modificat:\n');
fprintf('  Suprareglaj: sigma = %.2f %%\n', sigma_m);
fprintf('  Timp raspuns: tr = %.2f min\n', tr_m);
fprintf('  Domeniu comanda: [%.4f, %.4f]\n', min(c_m), max(c_m));

figure('Name', 'Metoda Kalman - Regulator modificat', 'Position', [150 150 900 600]);
subplot(2,1,1);
plot(t_sim, y_m, 'b-', 'LineWidth', 1.5); hold on;
plot(t_sim, w, 'r--', 'LineWidth', 1);
xlabel('Timp [min]'); ylabel('y');
title('Raspunsul sistemului - Kalman (regulator modificat)');
legend('y (iesire)', 'w (referinta)');
grid on;

subplot(2,1,2);
plot(t_sim, c_m, 'b-', 'LineWidth', 1.5);
xlabel('Timp [min]'); ylabel('c');
title('Evolutia semnalului de comanda - Kalman (regulator modificat)');
grid on;

saveas(gcf, 'kalman_regulator_modificat.png');

%% Simulare cu saturatie
fprintf('\n=== SIMULARE CU SATURATIE [0,1] ===\n');

y_ms = zeros(1, N);
c_ms = zeros(1, N);
e_ms = zeros(1, N);

for k = (max(nRm_den, nd) + 2):N
    e_ms(k) = w(k) - y_ms(k);
    c_k = 0;
    for i = 0:nRm_num
        if k-i >= 1, c_k = c_k + num_Rm(i+1) * e_ms(k-i); end
    end
    for i = 1:nRm_den
        if k-i >= 1, c_k = c_k - den_Rm(i+1) * c_ms(k-i); end
    end
    c_ms(k) = max(0, min(1, c_k));
    
    y_k = 0;
    for i = 0:nb
        if k-i-nd >= 1
            y_k = y_k + Bn(i+1) * c_ms(max(1, k-i-nd));
        end
    end
    for i = 1:na
        if k-i >= 1, y_k = y_k - An(i+1) * y_ms(k-i); end
    end
    y_ms(k) = y_k;
end

[y_max_ms, ~] = max(y_ms);
sigma_ms = max(0, (y_max_ms - 1)/1 * 100);
tr_ms = NaN;
for k = 1:N
    if all(abs(y_ms(k:end) - 1) <= 0.03)
        tr_ms = t_sim(k);
        break;
    end
end
fprintf('Cu saturatie c in [0,1]:\n');
fprintf('  Suprareglaj: sigma = %.2f %%\n', sigma_ms);
fprintf('  Timp raspuns: tr = %.2f min\n', tr_ms);
fprintf('  Domeniu comanda: [%.4f, %.4f]\n', min(c_ms), max(c_ms));

figure('Name', 'Metoda Kalman - Cu saturatie', 'Position', [200 200 900 600]);
subplot(2,1,1);
plot(t_sim, y_ms, 'b-', 'LineWidth', 1.5); hold on;
plot(t_sim, w, 'r--', 'LineWidth', 1);
xlabel('Timp [min]'); ylabel('y');
title('Raspunsul sistemului - Kalman cu saturatie [0,1]');
legend('y (iesire)', 'w (referinta)');
grid on;

subplot(2,1,2);
plot(t_sim, c_ms, 'b-', 'LineWidth', 1.5);
xlabel('Timp [min]'); ylabel('c');
title('Evolutia semnalului de comanda cu saturatie');
grid on;

saveas(gcf, 'kalman_cu_saturatie.png');

%% Centralizare rezultate
fprintf('\n=== TABEL CENTRALIZARE REZULTATE ===\n');
fprintf('%-50s | %8s | %10s | %10s | %20s\n', ...
    'Cazul tratat', 'a_stp', 'sigma [%]', 'tr [min]', '[c_min, c_max]');
fprintf('%s\n', repmat('-', 1, 115));
fprintf('%-50s | %8.4f | %10.2f | %10.2f | [%8.4f, %8.4f]\n', ...
    'Kalman, regulator initial', a_stp, sigma, tr, min(c), max(c));
fprintf('%-50s | %8.4f | %10.2f | %10.2f | [%8.4f, %8.4f]\n', ...
    'Kalman, regulator modificat', abs(1-y_m(end)), sigma_m, tr_m, min(c_m), max(c_m));
fprintf('%-50s | %8.4f | %10.2f | %10.2f | [%8.4f, %8.4f]\n', ...
    'Kalman, reg. modif. + saturatie [0,1]', abs(1-y_ms(end)), sigma_ms, tr_ms, min(c_ms), max(c_ms));
