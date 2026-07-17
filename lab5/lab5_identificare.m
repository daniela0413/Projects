%% LABORATOR NR. 5 - Structuri de reglare in cascada
%% Date experimentale: Presiune (G.U.N.T. RT0x0)
%%
%% Procesul fizic: Pompa → Debit (IT2) → Presiune (IT1)
%% Variabila de iesire principala:    y  = presiune [bar]
%% Variabila intermediara (modelata): y2 = debit    [L/h sau %]
%% Semnal de executie:                m  = comanda pompa [%]
%%
%% Nota: Setul de date contine masuratori in bucla inchisa.
%% Datele sunt utilizate pentru identificarea procesului global (IT)
%% si pentru validarea simularii. Descompunerea in subprocese se face
%% conform teoriei din subcapitolul 5.3.
%%
%% PASUL 1: Identificare proces global (metoda tangentei)
%% PASUL 2: Descompunere in subprocese IT1 si IT2
%% PASUL 3: Calcul regulator R2 (bucla interioara)
%% PASUL 4: Calcul regulator R1 (bucla exterioara)
%% PASUL 5: Salvare parametri pentru simulare



%% =========================================================
%% DATE EXPERIMENTALE
%% =========================================================
run('date_experimentale.m');

% Identificam segmentul cel mai util: primul pas de referinta 0->0.5 bar
% Sistemul porneste de la repaus (p=0) si ajunge la ~0.5 bar
% Comanda creste aproape liniar => raspunsul procesului e aproximativ
% raspunsul la un semnal rampa, dar il tratam ca raspuns la treapta
% normalizat (la valoarea stationara)

% Gasim indexul primei schimbari de referinta
w_change_idx = find(diff(w_exp) > 0.1, 1, 'first') + 1;
fprintf('Prima schimbare referinta la indexul %d, t=%.1fs\n', w_change_idx, t_exp(w_change_idx));

% Gasim cand comanda devine semnificativa (>2%)
cmd_start = w_change_idx + find(m_exp(w_change_idx:w_change_idx+500) > 2, 1, 'first') - 1;
fprintf('Comanda devine activa la indexul %d, t=%.1fs\n', cmd_start, t_exp(cmd_start));

% Gasim sfarsitul primului segment (urmatoarea schimbare de referinta)
w_change2 = find(w_exp(w_change_idx+100:end) > 0.6, 1, 'first') + w_change_idx + 100;
if isempty(w_change2); w_change2 = length(t_exp); end

% Extragem raspunsul procesului
t_step = t_exp(cmd_start:w_change2) - t_exp(cmd_start);
y_step = y_exp(cmd_start:w_change2);
m_step = m_exp(cmd_start:w_change2);

% Valorile initiala si stationara
y0  = y_step(1);
yst = max(y_step(end-50:end));   % media ultimelor puncte
m0  = m_step(1);
mst = max(m_step(end-50:end));
dm  = mst - m0;
dy  = yst - y0;

fprintf('\n=== DATE IDENTIFICARE PROCES GLOBAL ===\n');
fprintf('y0 = %.4f bar, yst = %.4f bar, delta_y = %.4f bar\n', y0, yst, dy);
fprintf('m0 = %.2f %%, mst = %.2f %%, delta_m = %.2f %%\n', m0, mst, dm);

% Constanta de proportionalitate globala
K_IT = dy / dm;
fprintf('K_IT (global) = %.6f bar/%%\n\n', K_IT);

%% =========================================================
%% METODA TANGENTEI pe raspunsul global
%% =========================================================
fprintf('--- METODA TANGENTEI (proces global) ---\n');

% Derivata pentru punct de inflexiune
dy_dt = diff(y_step) ./ diff(t_step);
[max_slope, idx_inf] = max(movmean(dy_dt, 5));
t_inf = t_step(idx_inf);
y_inf = y_step(idx_inf);
fprintf('Punct inflexiune: t_inf=%.2fs, y_inf=%.4fbar, panta=%.6f\n', t_inf, y_inf, max_slope);

Tm_global = t_inf - (y_inf - y0) / max_slope;
T_global  = (yst - y_inf) / max_slope;
if Tm_global < 0; Tm_global = 0; end
fprintf('Tm_global = %.3f s\n', Tm_global);
fprintf('T_global  = %.3f s\n', T_global);
fprintf('H_IT(s) = %.6f / (1 + %.3f*s) * exp(-%.3f*s)\n\n', K_IT, T_global, Tm_global);

%% =========================================================
%% DESCOMPUNEREA IN SUBPROCESE (conform teoriei Lab 5)
%% =========================================================
% Procesul fizic: Pompa -> Debit (IT2) -> Presiune (IT1)
% H_IT(s) = H_IT2(s) * H_IT1(s)
%
% Decomposition strategy (as per section 5.3):
% - IT2: subproces rapid (pompa -> debit)   constanta de timp T2 mica
% - IT1: subproces lent  (debit -> presiune) constanta de timp T1 mare
%
% Din raspunsul global: T_global = T1 + T2 (aproximativ)
% Alegem impartirea astfel incat T1 >> T2 (respecta rec. 1 si 3 din 5.1)

% Proportia de impartire: T2 = 10-20% din T_global
% (subprocesul rapid in bucla interioara)
frac_T2 = 0.15;   % 15% pentru bucla interioara
T2 = frac_T2 * T_global;
T1 = T_global - T2;

% Constante de proportionalitate (impartite proportional)
% K_IT = K_IT1 * K_IT2 (pentru cascada)
% Alegem K_IT2 = 1 (adimensional) si K_IT1 = K_IT
K_IT2 = 1.0;       % pompa -> debit (adimensional daca y2 in %)
K_IT1 = K_IT;      % debit -> presiune [bar/%]

fprintf('=== DESCOMPUNERE IN SUBPROCESE ===\n');
fprintf('H_IT2(s) = %.4f / (1 + %.3f*s)   [subproces rapid: pompa->debit]\n', K_IT2, T2);
fprintf('H_IT1(s) = %.6f / (1 + %.3f*s)   [subproces lent:  debit->presiune]\n', K_IT1, T1);
fprintf('Verificare: T1+T2 = %.3f s (T_global = %.3f s)\n\n', T1+T2, T_global);

%% =========================================================
%% ELEMENTE AUXILIARE (estimate pentru instalatia G.U.N.T.)
%% =========================================================
T_EE   = max(0.1, Tm_global * 0.5);   % element executie [s]
T_TM1  = 0.1;    % traductor masura presiune [s]
T_TM2  = 0.1;    % traductor masura debit (variabila intermediara) [s]
K_EE   = 1.0;
K_TM1  = 1.0;
K_TM2  = 1.0;

fprintf('=== ELEMENTE AUXILIARE (estimate) ===\n');
fprintf('H_EE(s)  = 1 / (1 + %.3f*s)\n', T_EE);
fprintf('H_TM1(s) = 1 / (1 + %.3f*s)\n', T_TM1);
fprintf('H_TM2(s) = 1 / (1 + %.3f*s)\n\n', T_TM2);

%% =========================================================
%% PASUL 1: CALCUL REGULATOR R2 (bucla interioara - criteriul modulului)
%% =========================================================
fprintf('=== REGULATOR R2 (bucla interioara) ===\n');
fprintf('Criteriul modulului aplicat buclei interioare\n');

% Parte fixata bucla interioara: H_f2 = H_IT2 * H_EE * H_TM2
% Suma constante mici bucla interioara:
T_Sigma2 = T_EE + T_TM2;
% Constanta dominanta bucla interioara: T2
K_f2 = K_IT2 * K_EE * K_TM2;

fprintf('H_f2(s) = %.4f / ((1+%.3f*s)*(1+%.3f*s))   [Ty2=%.3f, T2=%.3f]\n', ...
    K_f2, T_Sigma2, T2, T_Sigma2, T2);

% Criteriul modulului => Regulator PI
K_R2 = T2 / (2 * K_f2 * T_Sigma2);
T_I2 = T2;
fprintf('Regulator R2 (PI):\n');
fprintf('  K_R2 = T2/(2*K_f2*T_Sigma2) = %.4f\n', K_R2);
fprintf('  T_I2 = T2 = %.3f s\n\n', T_I2);

%% =========================================================
%% PASUL 2: FUNCTIA DE TRANSFER BUCLA INTERIOARA INCHISA H_02
%% =========================================================
fprintf('=== FUNCTIA DE TRANSFER BUCLA INTERIOARA (H_02) ===\n');
% H_02(s) = L{y2}/L{c1} in bucla inchisa
% Formula simplificata (ec. 5.5):
% H_02(s) ≈ 1/(2*T_Sigma2*s + 1) * 1/H_TM2
T_02 = 2 * T_Sigma2;
K_02 = 1 / K_TM2;   % = 1
fprintf('H_02(s) ≈ %.4f / (1 + %.3f*s)   [forma simplificata ec. 5.5]\n', K_02, T_02);
fprintf('(Constanta timp bucla inchisa interioara: 2*T_Sigma2 = %.3f s)\n\n', T_02);

%% =========================================================
%% PASUL 3: CALCUL REGULATOR R1 (bucla exterioara - criteriul modulului)
%% =========================================================
fprintf('=== REGULATOR R1 (bucla exterioara) ===\n');

% Parte fixata bucla exterioara:
% H_f1(s) = H_IT1(s) * H_02(s) * H_TM1(s)
% Suma constante mici bucla exterioara:
T_Sigma1 = T_02 + T_TM1;
% Constanta dominanta: T1
K_f1 = K_IT1 * K_02 * K_TM1;

fprintf('H_f1(s) ≈ %.6f / ((1+%.3f*s)*(1+%.3f*s))   [Ty1=%.3f, T1=%.3f]\n', ...
    K_f1, T_Sigma1, T1, T_Sigma1, T1);

% Criteriul modulului => Regulator PI
K_R1 = T1 / (2 * K_f1 * T_Sigma1);
T_I1 = T1;
fprintf('Regulator R1 (PI) - criteriul modulului:\n');
fprintf('  K_R1 = T1/(2*K_f1*T_Sigma1) = %.4f\n', K_R1);
fprintf('  T_I1 = T1 = %.3f s\n\n', T_I1);

%% Criteriul simetriei pentru R2 (varianta alternativa)
K_R2_sim = (1 + 4*T_Sigma2) * T2 / (8 * K_f2 * T_Sigma2^2);
T_I2_sim  = T2;  % simplificat
fprintf('Regulator R2 (PI) - criteriul simetriei (varianta):\n');
fprintf('  K_R2_sim = %.4f\n', K_R2_sim);
fprintf('  T_I2_sim = %.3f s\n\n', T_I2_sim);

%% =========================================================
%% CALCUL SISTEM MONOCONTUR ECHIVALENT (pentru comparatie)
%% =========================================================
fprintf('=== SISTEM MONOCONTUR (pentru comparatie) ===\n');
% Parte fixata monocontur: H_f_mono = H_IT * H_EE * H_TM1
T_Sigma_mono = T_EE + T_TM1;
K_f_mono = K_IT * K_EE * K_TM1;
fprintf('H_f_mono(s) = %.6f / ((1+%.3f*s)*(1+%.3f*s))\n', K_f_mono, T_Sigma_mono, T_global);

K_R_mono = T_global / (2 * K_f_mono * T_Sigma_mono);
T_I_mono = T_global;
fprintf('Regulator monocontur PI (criteriul modulului):\n');
fprintf('  K_R = %.4f\n', K_R_mono);
fprintf('  T_I = %.3f s\n\n', T_I_mono);

%% =========================================================
%% SALVARE PARAMETRI
%% =========================================================
save('lab5_params.mat', ...
    'K_IT','K_IT1','K_IT2','T_global','T1','T2','Tm_global', ...
    'T_EE','T_TM1','T_TM2','K_EE','K_TM1','K_TM2', ...
    'T_Sigma2','K_f2','K_R2','T_I2','K_R2_sim','T_I2_sim', ...
    'T_02','K_02','T_Sigma1','K_f1','K_R1','T_I1', ...
    'K_f_mono','K_R_mono','T_I_mono','T_Sigma_mono', ...
    't_step','y_step','m_step','y0','yst','m0','mst', ...
    't_exp','m_exp','y_exp','w_exp');

fprintf('Parametri salvati in lab5_params.mat\n');
fprintf('Rulati acum: lab5_simulare.m\n');

%% =========================================================
%% GRAFICE
%% =========================================================
figure(1);
subplot(2,1,1);
plot(t_exp, y_exp, 'b-', 'LineWidth',1.5, 'DisplayName','y - presiune masurata');
hold on;
plot(t_exp, w_exp, 'r--','LineWidth',1.5, 'DisplayName','w - referinta');
grid on; xlabel('Timp [s]'); ylabel('Presiune [bar]');
title('Date experimentale complete - Presiune (G.U.N.T.)');
legend('Location','northwest'); xlim([0 t_exp(end)]);

subplot(2,1,2);
plot(t_exp, m_exp, 'g-', 'LineWidth',1.5);
grid on; xlabel('Timp [s]'); ylabel('Comanda pompa [%]');
title('Semnal de comanda'); xlim([0 t_exp(end)]);

figure(2);
t_sim_id = 0:0.2:t_step(end);
y_model_id = y0 + (yst-y0)*(1 - exp(-(t_sim_id - Tm_global)/T_global));
y_model_id(t_sim_id < Tm_global) = y0;
plot(t_step, y_step, 'bo', 'MarkerSize',2, 'DisplayName','Raspuns experimental');
hold on;
plot(t_sim_id, y_model_id, 'r-', 'LineWidth',2, 'DisplayName', ...
    sprintf('Model: K=%.5f, T=%.2fs, Tm=%.2fs', K_IT, T_global, Tm_global));
% Tangenta
if t_inf > 0
    t_tang = [max(0,Tm_global-0.5), Tm_global + T_global*1.1];
    y_tang = y_inf + max_slope*(t_tang - t_inf);
    plot(t_tang, y_tang, 'g--', 'LineWidth',1.5, 'DisplayName','Tangenta');
end
yline(yst,'k:','LineWidth',1,'HandleVisibility','off');
grid on; xlabel('Timp [s]'); ylabel('Presiune [bar]');
title(sprintf('Identificare proces global - Metoda tangentei\nH_{IT}(s) = %.5f/(1+%.2fs) · e^{-%.2fs}', K_IT, T_global, Tm_global));
legend('Location','southeast');

fprintf('\nSUMAR PARAMETRI:\n');
fprintf('  H_IT2(s) = %.4f / (1+%.3fs)  [bucla interioara]\n', K_IT2, T2);
fprintf('  H_IT1(s) = %.6f / (1+%.3fs) [bucla exterioara]\n', K_IT1, T1);
fprintf('  R2 (PI):  K_R2=%.4f, T_I2=%.3fs\n', K_R2, T_I2);
fprintf('  R1 (PI):  K_R1=%.4f, T_I1=%.3fs\n', K_R1, T_I1);
fprintf('  Monocontur PI: K_R=%.4f, T_I=%.3fs\n', K_R_mono, T_I_mono);
