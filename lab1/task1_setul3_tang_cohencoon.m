%% LABORATOR NR. 1 - Sarcina 1 - SETUL 3
%% Identificare prin metoda tangentei SI metoda Cohen-Coon
%% Setul 3: Proces de ordin superior

clear; clc; close all;

%% DATE EXPERIMENTALE - Setul 3
t3 = [0, 0.2000, 0.4000, 0.6000, 0.8000, 1.0000, 1.2000, 1.4000, 1.6000, 1.8000, ...
      2.0000, 2.2000, 2.4000, 2.6000, 2.8000, 3.0000, 3.2000, 3.4000, 3.6000, 3.8000, ...
      4.0000, 4.2000, 4.4000, 4.6000, 4.8000, 5.0000];
y3 = [0, 0.3196, 1.0179, 1.8455, 2.6711, 3.4310, 4.0994, 4.6710, 5.1508, 5.5485, ...
      5.8750, 6.1413, 6.3576, 6.5326, 6.6739, 6.7876, 6.8791, 6.9527, 7.0117, 7.0590, ...
      7.0970, 7.1274, 7.1518, 7.1714, 7.1870, 7.1996];

m0 = 0; mst = 1;

y0_3 = y3(1);
yst_3 = y3(end);
fprintf('=== SETUL 3: Proces de ordin superior ===\n');
fprintf('y0 = %.4f,  yst = %.4f\n', y0_3, yst_3);

% Constanta de proportionalitate
K_IT3 = (yst_3 - y0_3) / (mst - m0);
fprintf('K_IT = %.4f\n', K_IT3);

%% =========================================================
%% METODA TANGENTEI - Punct de inflexiune
%% =========================================================
fprintf('\n--- METODA TANGENTEI ---\n');

% Calculam derivata pentru a gasi punctul de inflexiune
dy3 = diff(y3) ./ diff(t3);
[max_slope3, idx_slope3] = max(dy3);
t_inf3 = t3(idx_slope3);
y_inf3 = y3(idx_slope3);
fprintf('Punct de inflexiune: t_inf = %.4f s, y_inf = %.4f\n', t_inf3, y_inf3);
fprintf('Panta tangentei in punctul de inflexiune: %.4f\n', max_slope3);

% Tangenta in punctul de inflexiune: y = y_inf + slope*(t - t_inf)
% Intersectia cu y=0: t_Tm3 = t_inf - y_inf/slope  => Timp mort
Tm3_tang = t_inf3 - y_inf3 / max_slope3;
fprintf('Timp mort (metoda tangentei) Tm3 = %.4f s\n', Tm3_tang);

% Intersectia cu y=yst: t_T3+Tm3 = t_inf + (yst - y_inf)/slope
T3_tang = (yst_3 - y_inf3) / max_slope3;
fprintf('Constanta de timp T3 (metoda tangentei) = %.4f s\n', T3_tang);

% Model tangenta
sys3_tang = tf(K_IT3, [T3_tang 1]);
t_sim = 0:0.01:5;
y3_tang_nodelay = step(sys3_tang, t_sim);
% Aplicam timp mort
y3_tang_sim = zeros(size(t_sim));
delay_idx = round(Tm3_tang / 0.01);
if delay_idx >= 1 && delay_idx < length(y3_tang_sim)
    y3_tang_sim(delay_idx+1:end) = y3_tang_nodelay(1:end-delay_idx);
end

fprintf('Functia de transfer (metoda tangentei):\n');
fprintf('H_IT3_tang(s) = %.4f / (1 + %.4f*s) * exp(-%.4f*s)\n', K_IT3, T3_tang, Tm3_tang);

%% =========================================================
%% METODA COHEN-COON
%% =========================================================
fprintf('\n--- METODA COHEN-COON ---\n');

% Determinam t28 si t632 (timpii la 0.28*yst si 0.632*yst)
y28_val = 0.28 * yst_3;
y632_val = 0.632 * yst_3;
fprintf('0.28*yst = %.4f,  0.632*yst = %.4f\n', y28_val, y632_val);

% Interpolam t28
t28 = interp1(y3, t3, y28_val);
fprintf('t28 = %.4f s\n', t28);

% Interpolam t632
t632 = interp1(y3, t3, y632_val);
fprintf('t632 = %.4f s\n', t632);

% Relatii Cohen-Coon (ec. 1.17, 1.18, 1.19)
T_cc = 1.5 * (t632 - t28);          % (1.17) constanta de timp
Tm_cc = 1.5 * (t28 - (1/3)*t632);   % (1.18) timp mort
alpha_cc = T_cc / Tm_cc;             % (1.19) parametru acordare
fprintf('T (Cohen-Coon) = %.4f s\n', T_cc);
fprintf('Tm (Cohen-Coon) = %.4f s\n', Tm_cc);
fprintf('alpha = T/Tm = %.4f\n', alpha_cc);

% Model Cohen-Coon
sys3_cc = tf(K_IT3, [T_cc 1]);
y3_cc_nodelay = step(sys3_cc, t_sim);
y3_cc_sim = zeros(size(t_sim));
delay_idx_cc = round(Tm_cc / 0.01);
if delay_idx_cc >= 1 && delay_idx_cc < length(y3_cc_sim)
    y3_cc_sim(delay_idx_cc+1:end) = y3_cc_nodelay(1:end-delay_idx_cc);
end

fprintf('Functia de transfer (Cohen-Coon):\n');
fprintf('H_IT3_cc(s) = %.4f / (1 + %.4f*s) * exp(-%.4f*s)\n', K_IT3, T_cc, Tm_cc);

%% =========================================================
%% PLOT - Comparatie cele 3 raspunsuri pe acelasi grafic
%% =========================================================
figure(3);
plot(t3, y3, 'bo-', 'LineWidth', 2, 'MarkerSize', 5, 'DisplayName', 'Raspuns experimental');
hold on;
plot(t_sim, y3_tang_sim, 'r-', 'LineWidth', 2, ...
    'DisplayName', sprintf('Metoda tangentei: K=%.3f, T=%.3f, Tm=%.3f', K_IT3, T3_tang, Tm3_tang));
plot(t_sim, y3_cc_sim, 'g--', 'LineWidth', 2, ...
    'DisplayName', sprintf('Cohen-Coon: K=%.3f, T=%.3f, Tm=%.3f', K_IT3, T_cc, Tm_cc));

% Marcam punctul de inflexiune
plot(t_inf3, y_inf3, 'kx', 'MarkerSize', 12, 'LineWidth', 2, 'DisplayName', 'Punct de inflexiune');

% Tangenta in punctul de inflexiune
t_tang_range = max(0, Tm3_tang - 0.2) : 0.01 : min(5, Tm3_tang + T3_tang + 0.5);
y_tang_line = y_inf3 + max_slope3 * (t_tang_range - t_inf3);
plot(t_tang_range, y_tang_line, 'm-.', 'LineWidth', 1.5, 'DisplayName', 'Tangenta (metoda tang.)');

% Marcam t28, t632
yline(y28_val, ':k', 'LineWidth', 1);
yline(y632_val, ':k', 'LineWidth', 1);
xline(t28, ':b', 'LineWidth', 1);
xline(t632, ':b', 'LineWidth', 1);
text(t28+0.05, 0.2, sprintf('t_{28}=%.2fs', t28), 'FontSize', 9, 'Color', 'b');
text(t632+0.05, 0.2, sprintf('t_{632}=%.2fs', t632), 'FontSize', 9, 'Color', 'b');
yline(yst_3, 'k--', 'LineWidth', 1, 'DisplayName', sprintf('yst = %.4f', yst_3));

grid on;
xlabel('Timp [s]');
ylabel('y, m');
title('Setul 3 - Comparatie: Experimental, Metoda Tangentei, Cohen-Coon');
legend('Location', 'southeast');
xlim([0 5]);
ylim([-0.2 yst_3 * 1.15]);

%% =========================================================
%% SUMAR REZULTATE
%% =========================================================
fprintf('\n========== SUMAR SETUL 3 ==========\n');
fprintf('Metoda Tangentei:\n');
fprintf('  H(s) = %.4f / (1 + %.4f*s) * exp(-%.4f*s)\n', K_IT3, T3_tang, Tm3_tang);
fprintf('Cohen-Coon:\n');
fprintf('  H(s) = %.4f / (1 + %.4f*s) * exp(-%.4f*s)\n', K_IT3, T_cc, Tm_cc);
fprintf('  alpha = %.4f\n', alpha_cc);
