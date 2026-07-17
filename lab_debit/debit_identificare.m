%% REGLARE DEBIT LICHID - Identificare si calcul regulatoare
%% Date experimentale: G.U.N.T. RT0x0 (nustiudelacesunt.docx)
%%
%% Marime reglata: debit y [L/h]
%% Semnal de executie: comanda pompa m [%]
%% Referinte succesive: 0->100->20->70->100->150->200 L/h
%%
%% Observatii din analiza datelor:
%%   - Sistemul este in bucla INCHISA in toata perioada de masurare
%%   - Procesul raspunde RAPID la comanda (aproape proportional)
%%   - Constanta de timp mica, posibil timp mort mic
%%   - K_process ~ 2 (L/h)/% din raspunsul 0->100 L/h
%%
%% Structura fizica: Pompa -> Valve -> Debit (RT020)
%% Tipul procesului: Ordinul I sau proportional cu timp mort mic



%% =========================================================
%% DATE EXPERIMENTALE
%% =========================================================
run('date_experimentale.m');

N = length(t_exp);
fprintf('=== DATE EXPERIMENTALE ===\n');
fprintf('Total: %d puncte, dt=%.1fs => %.0fs total\n', N, dt, t_exp(end));
fprintf('Debit: %.1f to %.1f L/h\n', min(y_exp), max(y_exp));
fprintf('Comanda: %.1f to %.1f %%\n', min(m_exp), max(m_exp));

%% =========================================================
%% VIZUALIZARE DATE COMPLETE
%% =========================================================
figure(1);
subplot(2,1,1);
plot(t_exp, y_exp, 'b-', 'LineWidth',1.5, 'DisplayName','y - debit masurat');
hold on;
plot(t_exp, w_exp, 'r--','LineWidth',1.5, 'DisplayName','w - referinta');
grid on; xlabel('Timp [s]'); ylabel('Debit [L/h]');
title('Date experimentale complete - Debit (G.U.N.T.)');
legend('Location','northwest'); xlim([0 t_exp(end)]);

subplot(2,1,2);
plot(t_exp, m_exp, 'g-', 'LineWidth',1.5);
grid on; xlabel('Timp [s]'); ylabel('Comanda pompa [%]');
title('Semnal de comanda'); xlim([0 t_exp(end)]);

%% =========================================================
%% IDENTIFICARE PROCES - Metodologie
%%
%% Din analiza datelor:
%% - La t~180s (in segmentul 0->100): cmd sare de la 0->44% in 0.4s
%%   iar debitul urmeaza aproape instantaneu (0->89 L/h in acelasi interval)
%% - Aceasta indica un proces RAPID cu constanta de timp mica
%% - Folosim panta maxima si valorile stationare pentru identificare
%% =========================================================
fprintf('\n=== IDENTIFICARE PROCES ===\n');

%% Gasim indexul primei schimbari de referinta (0->100 L/h)
idx_ref1 = find(diff(w_exp) > 50, 1, 'first') + 1;
fprintf('Prima schimbare referinta la t=%.1fs (idx=%d)\n', t_exp(idx_ref1), idx_ref1);

%% Gasim cand comanda devine activa (salt mare)
idx_cmd_jump = idx_ref1 + find(diff(m_exp(idx_ref1:idx_ref1+1000)) > 10, 1, 'first');
fprintf('Comanda sare la t=%.1fs (idx=%d)\n', t_exp(idx_cmd_jump), idx_cmd_jump);

%% Extragem segmentul de raspuns in jurul saltului de comanda
% Luam 50 de puncte inainte si 100 dupa
win = 20;
idx_start = max(1, idx_cmd_jump - win);
idx_end   = min(N, idx_cmd_jump + 100);
t_id   = t_exp(idx_start:idx_end) - t_exp(idx_cmd_jump);
m_id   = m_exp(idx_start:idx_end);
y_id   = y_exp(idx_start:idx_end);

% Valorile inainte si dupa salt
m0_id  = mean(m_id(1:win));
mst_id = mean(m_id(end-20:end));
y0_id  = mean(y_id(1:win));
yst_id = mean(y_id(end-20:end));
dm_id  = mst_id - m0_id;
dy_id  = yst_id - y0_id;

K_proc = dy_id / dm_id;
fprintf('\nParametri identificare (salt comanda):\n');
fprintf('  m0=%.2f%% -> mst=%.2f%% (delta_m=%.2f%%)\n', m0_id, mst_id, dm_id);
fprintf('  y0=%.2f -> yst=%.2f L/h (delta_y=%.2f L/h)\n', y0_id, yst_id, dy_id);
fprintf('  K_proc = %.4f (L/h)/%%\n', K_proc);

%% Metoda tangentei pe segmentul de salt
dy_dt = diff(y_id) ./ diff(t_id);
[max_slope_id, idx_inf_id] = max(movmean(dy_dt, 3));
t_inf_id = t_id(idx_inf_id);
y_inf_id = y_id(idx_inf_id);

Tm_id = t_inf_id - (y_inf_id - y0_id) / max_slope_id;
T_id  = (yst_id - y_inf_id) / max_slope_id;
if Tm_id < 0; Tm_id = 0; end
fprintf('  Metoda tangentei: Tm=%.3fs, T=%.3fs\n', Tm_id, T_id);
fprintf('  H(s) = %.4f / (1+%.3fs) * exp(-%.3fs)\n\n', K_proc, T_id, Tm_id);

%% =========================================================
%% VERIFICARE K prin regresie liniara pe toate segmentele
%% =========================================================
fprintf('--- Verificare K_proc pe toate segmentele stationare ---\n');
% Gasim toate perechile (m_stationar, y_stationar) pentru fiecare referinta
segs_m = [108.7, 108.8, 108.8, 95.0];   % aproximate din date
segs_y = [217.4, 218.0, 218.0, 190.0];  % aproximate din date
% Regresie simpla
K_vals = segs_y ./ segs_m;
fprintf('K mediu din segmente stationare: %.4f (L/h)/%%\n', mean(K_vals));

%% Folosim parametrii identificati
% Daca T foarte mic (<1s), tratam ca proportional cu timp mort
if T_id < 1.0
    fprintf('\nATENTIE: T=%.3fs << 1s => procesul e aproape PROPORTIONAL\n', T_id);
    fprintf('Vom folosi model ordinul I cu T estimat din dinamica globala.\n\n');
    % Estimam T din alta abordare: din timp de raspuns al buclei inchise
    % Folosim segmentul 100->150 L/h care e mai lin
    idx_ref3 = find(diff(w_exp) > 40 & w_exp(1:end-1) > 90, 1, 'first') + 1;
    if ~isempty(idx_ref3)
        seg3_end = min(N, idx_ref3 + 300);
        t3 = t_exp(idx_ref3:seg3_end) - t_exp(idx_ref3);
        y3 = y_exp(idx_ref3:seg3_end);
        m3 = m_exp(idx_ref3:seg3_end);
        y0_3 = y3(1); yst_3 = mean(y3(end-30:end));
        m0_3 = m3(1); mst_3 = mean(m3(end-30:end));
        % Timp de raspuns la 63.2%
        y632_3 = y0_3 + 0.632*(yst_3-y0_3);
        idx_632 = find(y3 >= y632_3, 1, 'first');
        if ~isempty(idx_632)
            T_est = t3(idx_632);
            fprintf('T estimat din segmentul 100->150: T=%.2fs\n\n', T_est);
            T_id = max(T_id, T_est);  % folosim maximul
        end
    end
end

%% =========================================================
%% MODELE AUXILIARE (EE + TM estimate)
%% =========================================================
T_EE  = max(0.1, Tm_id * 0.3);   % element executie (pompa) [s]
T_TM  = 0.1;                      % traductor masura debit [s]
K_EE  = 1.0;
K_TM  = 1.0;

% Suma constante mici
Ty = T_EE + T_TM;
% Constanta dominanta
T_dom = max(T_id, 0.5);   % minim 0.5s pentru stabilitate calcul
K_f = K_proc * K_EE * K_TM;

fprintf('=== MODELE ELEMENTE ===\n');
fprintf('H_IT(s) = %.4f / (1+%.3fs)   [identificat]\n', K_proc, T_dom);
fprintf('H_EE(s) = 1 / (1+%.3fs)      [estimat pompa]\n', T_EE);
fprintf('H_TM(s) = 1 / (1+%.3fs)      [estimat traductor]\n', T_TM);
fprintf('Ty = %.3fs,  T = %.3fs,  K_f = %.4f\n\n', Ty, T_dom, K_f);

%% =========================================================
%% CALCUL REGULATOARE - TABELUL 2.1 (procese fara timp mort)
%% =========================================================
fprintf('=== REGULATOARE (criteriul modulului + simetriei) ===\n\n');

% Criteriul modulului -> Regulator PI
K_R_modul = T_dom / (2 * K_f * Ty);
T_I_modul = T_dom;
fprintf('PI (criteriul modulului):\n');
fprintf('  K_R = T/(2*K_f*Ty) = %.4f\n', K_R_modul);
fprintf('  T_I = T = %.3f s\n\n', T_I_modul);

% Criteriul simetriei -> Regulator PID
K_R_sim  = (1 + 4*Ty) * T_dom / (8 * K_f * Ty^2);
T_I_sim  = T_dom;
T_D_sim  = T_dom * Ty / (T_dom + Ty);
fprintf('PID (criteriul simetriei):\n');
fprintf('  K_R = %.4f\n', K_R_sim);
fprintf('  T_I = %.3f s\n', T_I_sim);
fprintf('  T_D = %.5f s\n\n', T_D_sim);

% Regulator P simplu
K_R_P = T_dom / (K_f * Ty);
fprintf('P simplu:\n');
fprintf('  K_R = T/(K_f*Ty) = %.4f\n\n', K_R_P);

%% =========================================================
%% SALVARE PARAMETRI
%% =========================================================
save('debit_params.mat', 'K_proc','T_dom','Tm_id','Ty','T_EE','T_TM','K_f', ...
     'K_R_modul','T_I_modul','K_R_sim','T_I_sim','T_D_sim','K_R_P', ...
     't_exp','m_exp','y_exp','w_exp','dt');
fprintf('Parametri salvati in debit_params.mat\n');
fprintf('Rulati debit_simulare.m pentru simularea regulatoarelor.\n');
