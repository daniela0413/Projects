%% LABORATOR NR. 1 - Notiuni introductive
%% Sarcina 1: Identificarea experimentala prin metoda tangentei (Seturile 1 si 2)
% Setul 1: Proces ordinul I fara timp mort
% Setul 2: Proces ordinul I cu timp mort


%% =========================================================
%% DATE EXPERIMENTALE
%% =========================================================

% Setul 1
t1 = [0, 0.2000, 0.4000, 0.6000, 0.8000, 1.0000, 1.2000, 1.4000, 1.6000, 1.8000, ...
      2.0000, 2.2000, 2.4000, 2.6000, 2.8000, 3.0000, 3.2000, 3.4000, 3.6000, 3.8000, ...
      4.0000, 4.2000, 4.4000, 4.6000, 4.8000, 5.0000];
y1 = [0, 0.5652, 1.0365, 1.4294, 1.7570, 2.0302, 2.2579, 2.4478, 2.6061, 2.7381, ...
      2.8481, 2.9399, 3.0163, 3.0801, 3.1333, 3.1776, 3.2146, 3.2454, 3.2711, 3.2926, ...
      3.3104, 3.3253, 3.3377, 3.3481, 3.3567, 3.3639];

% Setul 2
t2 = [0, 0.2000, 0.4000, 0.6000, 0.8000, 1.0000, 1.2000, 1.4000, 1.6000, 1.8000, ...
      2.0000, 2.2000, 2.4000, 2.6000, 2.8000, 3.0000, 3.2000, 3.4000, 3.6000, 3.8000, ...
      4.0000, 4.2000, 4.4000, 4.6000, 4.8000, 5.0000];
y2 = [0, 0, 0, 0.5262, 1.0291, 1.4232, 1.7320, 1.9740, 2.1636, 2.3121, ...
      2.4285, 2.5198, 2.5912, 2.6472, 2.6911, 2.7255, 2.7525, 2.7736, 2.7901, 2.8031, ...
      2.8132, 2.8212, 2.8274, 2.8323, 2.8361, 2.8391];

% Semnalul de executie (treapta unitara: m0=0, mst=1)
m0 = 0;
mst = 1;

%% =========================================================
%% SETUL 1 - Proces ordinul I FARA timp mort
%% =========================================================
fprintf('=== SETUL 1: Proces Ordinul I fara timp mort ===\n');

y0_1 = y1(1);       % valoarea initiala
yst_1 = y1(end);    % valoarea stationara
fprintf('y0 = %.4f,  yst = %.4f\n', y0_1, yst_1);

% Constanta de proportionalitate
K_IT1 = (yst_1 - y0_1) / (mst - m0);
fprintf('K_IT = (yst - y0)/(mst - m0) = %.4f\n', K_IT1);

% Metoda tangentei: trasa in originea raspunsului (t=0, y=y0)
% Panta tangentei = (yst - y0) / T1
% Gasim T1 grafic: intersectia tangentei cu y = yst
% Panta initiala aproximata din primele puncte
slope1 = (y1(2) - y1(1)) / (t1(2) - t1(1));
fprintf('Panta initiala a raspunsului (aprox): %.4f\n', slope1);
% T1 = (yst - y0) / panta
T1_est = (yst_1 - y0_1) / slope1;
fprintf('Constanta de timp T1 estimata (din panta initiala): %.4f s\n', T1_est);

% Determinare mai precisa a T1 prin fitare
% Raspunsul teoretic al procesului ord I fara timp mort: y(t)=yst*(1-exp(-t/T1))
% Minimizare eroare patratica
T1_vals = 0.1:0.01:5;
err1 = zeros(size(T1_vals));
for i = 1:length(T1_vals)
    y_model = y0_1 + (yst_1 - y0_1) * (1 - exp(-t1/T1_vals(i)));
    err1(i) = sum((y_model - y1).^2);
end
[~, idx1] = min(err1);
T1_fit = T1_vals(idx1);
fprintf('Constanta de timp T1 (fitare numerica): %.4f s\n', T1_fit);

% Functia de transfer identificata - Setul 1
fprintf('\nFunctia de transfer Setul 1:\n');
fprintf('H_IT1(s) = %.4f / (1 + %.4f*s)\n', K_IT1, T1_fit);

% Simulare raspuns identificat - Setul 1
sys1_id = tf(K_IT1, [T1_fit 1]);
t_sim = 0:0.01:5;
y1_sim = step(sys1_id, t_sim);

% Plot Setul 1
figure(1);
plot(t1, y1, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 5, 'DisplayName', 'Raspuns experimental'); hold on;
plot(t_sim, y1_sim, 'r-', 'LineWidth', 2, 'DisplayName', sprintf('Model: K=%.3f, T1=%.3f s', K_IT1, T1_fit));

% Tangenta in origine
t_tang = [0, T1_fit*1.5];
y_tang = y0_1 + slope1 * t_tang;
plot(t_tang, y_tang, 'g--', 'LineWidth', 1.5, 'DisplayName', 'Tangenta in origine');
% Linie stationara
yline(yst_1, 'k--', 'LineWidth', 1, 'DisplayName', sprintf('yst = %.4f', yst_1));
% Marcam T1 pe grafic
plot([T1_fit T1_fit], [0 yst_1], 'm:', 'LineWidth', 1.5);
text(T1_fit, 0.05, sprintf('T_1=%.3fs', T1_fit), 'Color', 'm', 'FontSize', 10);

grid on; xlabel('Timp [s]'); ylabel('y, m');
title('Setul 1 - Metoda tangentei (Ordinul I fara timp mort)');
legend('Location', 'southeast');
xlim([0 5]); ylim([0 yst_1*1.15]);

%% =========================================================
%% SETUL 2 - Proces ordinul I CU timp mort
%% =========================================================
fprintf('\n=== SETUL 2: Proces Ordinul I cu timp mort ===\n');

y0_2 = y2(1);
yst_2 = y2(end);
fprintf('y0 = %.4f,  yst = %.4f\n', y0_2, yst_2);

K_IT2 = (yst_2 - y0_2) / (mst - m0);
fprintf('K_IT = %.4f\n', K_IT2);

% Detectam timpul mort: primul moment cand y incepe sa creasca
Tm_idx = find(y2 > 0.01, 1, 'first');
Tm2 = t2(Tm_idx);
fprintf('Timp mort Tm2 estimat: %.4f s\n', Tm2);

% Panta tangentei trasata in punctul de inflexiune (dupa timp mort)
% Cautam panta maxima (punctul de inflexiune pentru ord I cu timp mort = chiar la t=Tm)
dy2 = diff(y2) ./ diff(t2);
[max_slope2, idx_slope2] = max(dy2);
fprintf('Panta maxima a raspunsului: %.4f la t = %.4f s\n', max_slope2, t2(idx_slope2));

% T2 = (yst - y0) / panta
T2_est = (yst_2 - y0_2) / max_slope2;
fprintf('Constanta de timp T2 estimata: %.4f s\n', T2_est);

% Fitare pentru T2 si Tm
best_err2 = inf;
T2_fit = T2_est;
Tm2_fit = Tm2;
for Tm_try = 0:0.05:1.5
    for T_try = 0.1:0.05:5
        y_model2 = zeros(size(t2));
        for k = 1:length(t2)
            if t2(k) >= Tm_try
                y_model2(k) = (yst_2 - y0_2) * (1 - exp(-(t2(k)-Tm_try)/T_try));
            end
        end
        err = sum((y_model2 - y2).^2);
        if err < best_err2
            best_err2 = err;
            T2_fit = T_try;
            Tm2_fit = Tm_try;
        end
    end
end
fprintf('Timp mort Tm2 (fitare): %.4f s\n', Tm2_fit);
fprintf('Constanta de timp T2 (fitare): %.4f s\n', T2_fit);
fprintf('\nFunctia de transfer Setul 2:\n');
fprintf('H_IT2(s) = %.4f / (1 + %.4f*s) * exp(-%.4f*s)\n', K_IT2, T2_fit, Tm2_fit);

% Simulare raspuns identificat - Setul 2
sys2_id = tf(K_IT2, [T2_fit 1]);
t_sim2 = 0:0.01:5;
y2_sim_nodelay = step(sys2_id, t_sim2);
% Adaugare timp mort prin shiftare
y2_sim = zeros(size(t_sim2));
delay_idx = round(Tm2_fit / 0.01);
if delay_idx < length(y2_sim)
    y2_sim(delay_idx+1:end) = y2_sim_nodelay(1:end-delay_idx);
end

% Tangenta setul 2
t_tang2_start = Tm2_fit;
t_tang2 = [t_tang2_start, t_tang2_start + T2_fit * 1.5];
y_tang2_start = 0;
y_tang2 = y_tang2_start + max_slope2 * (t_tang2 - t_tang2_start);

% Plot Setul 2
figure(2);
plot(t2, y2, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 5, 'DisplayName', 'Raspuns experimental'); hold on;
plot(t_sim2, y2_sim, 'r-', 'LineWidth', 2, 'DisplayName', sprintf('Model: K=%.3f, T2=%.3f s, Tm=%.3f s', K_IT2, T2_fit, Tm2_fit));
plot(t_tang2, y_tang2, 'g--', 'LineWidth', 1.5, 'DisplayName', 'Tangenta in punctul de inflexiune');
yline(yst_2, 'k--', 'LineWidth', 1, 'DisplayName', sprintf('yst = %.4f', yst_2));
plot([Tm2_fit Tm2_fit], [0 yst_2*0.3], 'm:', 'LineWidth', 1.5);
text(Tm2_fit, -0.07, sprintf('T_m=%.2fs', Tm2_fit), 'Color', 'm', 'FontSize', 10);
plot([Tm2_fit+T2_fit Tm2_fit+T2_fit], [0 yst_2], 'c:', 'LineWidth', 1.5);
text(Tm2_fit+T2_fit, 0.05, sprintf('T_2=%.2fs', T2_fit), 'Color', 'c', 'FontSize', 10);

grid on; xlabel('Timp [s]'); ylabel('y, m');
title('Setul 2 - Metoda tangentei (Ordinul I cu timp mort)');
legend('Location', 'southeast');
xlim([0 5]); ylim([-0.1 yst_2*1.15]);

fprintf('\n--- SUMAR IDENTIFICARE ---\n');
fprintf('Setul 1: H(s) = %.4f / (1 + %.4f*s)\n', K_IT1, T1_fit);
fprintf('Setul 2: H(s) = %.4f / (1 + %.4f*s) * exp(-%.4f*s)\n', K_IT2, T2_fit, Tm2_fit);
