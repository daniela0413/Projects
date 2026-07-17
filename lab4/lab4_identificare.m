%% LABORATOR NR. 4 - Structuri de reglare bazate pe principiul compensarii perturbatiei
%% Date experimentale: Bazin/Rezervor (G.U.N.T. RT0x0)
%% Marime reglata: nivel lichid y [cm]
%% Semnal de executie: comanda pompa m [%]
%% Perturbatie: schimbare de referinta / debit exterior
%%
%% PASUL 1: Identificare experimentala (metoda tangentei)
%% PASUL 2: Calcul regulatoare (criteriul modulului + simetriei)
%% PASUL 3: Calcul bloc de compensare H_BC(s)
%% PASUL 4: Simulare sistem monocontur vs feedforward (figurile 4.2, 4.3)



%% =========================================================
%% DATE EXPERIMENTALE
%% =========================================================
run('date_experimentale.m');

% Normalizam datele pentru identificare:
% Folosim pasul de treapta de la setpoint 0 -> 17 cm (ultimul segment)
% Acesta corespunde raspunsului indicial al procesului (in bucla deschisa)
% m trece de la ~2.8% la ~90% (delta_m ~ 87.2%)
% y trece de la 0.6 cm la 18.1 cm (delta_y ~ 17.5 cm)

% Extragem segmentul: indexul 504 pana la sfarsit (cronologic)
idx_start = 505;    % idx in vectorii de mai sus (1-based, dupa reset la 0.6cm)
t_step = t_exp(idx_start:end) - t_exp(idx_start);
m_step = m_exp(idx_start:end);
y_step = y_exp(idx_start:end);

% Valorile initiala si stationara
m0   = m_step(1);    % ~2.8 %
mst  = m_step(end);  % ~90.2 %
y0   = y_step(1);    % ~0.6 cm
yst  = y_step(end);  % ~18.05 cm
dm   = mst - m0;
dy   = yst - y0;

fprintf('=== DATE IDENTIFICARE (pas treapta 0->17 cm) ===\n');
fprintf('m0 = %.2f %%, mst = %.2f %%, delta_m = %.2f %%\n', m0, mst, dm);
fprintf('y0 = %.2f cm, yst = %.2f cm, delta_y = %.2f cm\n', y0, yst, dy);

% Constanta de proportionalitate a procesului (IT)
K_IT = dy / dm;
fprintf('K_IT = delta_y / delta_m = %.4f cm/%%\n\n', K_IT);

%% =========================================================
%% METODA TANGENTEI
%% =========================================================
fprintf('--- METODA TANGENTEI ---\n');

% Derivata pentru punct de inflexiune
dy_dt = diff(y_step) ./ diff(t_step);
[max_slope, idx_inf] = max(dy_dt);
t_inf = t_step(idx_inf);
y_inf = y_step(idx_inf);
fprintf('Punct inflexiune: t_inf = %.2f s, y_inf = %.3f cm\n', t_inf, y_inf);
fprintf('Panta maxima: %.4f cm/s\n', max_slope);

% Timp mort si constanta de timp
Tm = t_inf - (y_inf - y0) / max_slope;
T  = (yst  - y_inf) / max_slope;
if Tm < 0; Tm = 0; end
fprintf('Tm (timp mort) = %.3f s\n', Tm);
fprintf('T  (constanta de timp) = %.3f s\n', T);
fprintf('H_IT(s) = %.4f / (1 + %.3f*s) * exp(-%.3f*s)\n\n', K_IT, T, Tm);

%% =========================================================
%% MODELE ELEMENTE SISTEM (presupuse / estimate)
%% =========================================================
% Conform structurii din figura 4.2:
%  - H_IT(s) = procesul tehnologic (bazin)  -> identificat
%  - H_EE(s) = elementul de executie (pompa) -> aproximat ordinul I
%  - H_TM1(s) = traductorul de masura nivel  -> aproximat ordinul I
%  - H_TM2(s) = traductorul de masura perturbatie -> aproximat ordinul I
%
% Pentru identificare, raspunsul masurat include EE + IT + TM1
% Aproximam: H_EE si H_TM1 cu constante de timp mici (neglijabile comparativ cu T)
% => H_f(s) ~ K_f / ((1+Ty*s)*(1+T*s))  unde Ty = suma constante mici

% Estimari rezonabile pentru instalatia G.U.N.T.:
T_EE  = 0.5;    % s - timp raspuns pompa
T_TM1 = 0.3;    % s - timp raspuns traductor nivel
T_TM2 = 0.3;    % s - timp raspuns traductor perturbatie
K_EE  = 1.0;    % adimensional (inclus in K_IT)
K_TM1 = 1.0;    % adimensional
K_TM2 = 1.0;    % adimensional

% Suma constante mici
Ty = T_EE + T_TM1;
fprintf('=== MODELE ELEMENTE ===\n');
fprintf('H_IT(s)  = %.4f / (1 + %.3f*s)   [identificat]\n', K_IT, T);
fprintf('H_EE(s)  = %.3f / (1 + %.3f*s)   [estimat]\n', K_EE, T_EE);
fprintf('H_TM1(s) = %.3f / (1 + %.3f*s)   [estimat]\n', K_TM1, T_TM1);
fprintf('H_TM2(s) = %.3f / (1 + %.3f*s)   [estimat - traductorul perturbatiei]\n\n', K_TM2, T_TM2);

% Functia de transfer a partii fixate (ec. 4.11 / 4.12):
% H_f(s) = H_EE * H_IT * H_TM1
% Forma simplificata (criteriul modulului):
% H_f(s) = K_f / ((1+Ty*s)*(1+T*s))
K_f = K_IT * K_EE * K_TM1;
fprintf('Parte fixata simplificata:\n');
fprintf('H_f(s) = %.4f / ((1+%.3f*s)*(1+%.3f*s))\n', K_f, Ty, T);
fprintf('Ty (suma constante mici) = %.3f s, T (dominanta) = %.3f s\n\n', Ty, T);

%% =========================================================
%% CALCUL REGULATOR PRINCIPAL R1 (criteriul modulului - PI)
%% =========================================================
fprintf('=== CALCUL REGULATOR PRINCIPAL R1 ===\n');
fprintf('(Criteriul modulului - varianta Kessler)\n');

% H_R(s) = 1 / (2*Ty*s*(1+Ty*s)) / H_f(s)
% => H_R_PI(s) = K_R*(1 + 1/(T_I*s))
K_R_modul = T / (2 * K_f * Ty);
T_I_modul = T;
fprintf('Regulator PI:\n');
fprintf('  K_R = T / (2*K_f*Ty) = %.4f\n', K_R_modul);
fprintf('  T_I = T = %.3f s\n\n', T_I_modul);

%% =========================================================
%% CALCUL BLOC DE COMPENSARE H_BC(s) (ec. 4.7)
%% =========================================================
fprintf('=== CALCUL BLOC COMPENSARE H_BC(s) ===\n');
fprintf('(Schema fig. 4.2 - perturbatia actioneaza asupra iesirii IT)\n');
fprintf('H_BC(s) = 1 / (H_IT(s)*H_EE(s)*H_TM2(s))\n');

% H_BC_ideal(s) = 1 / (H_IT * H_EE * H_TM2)
% = (1+T*s)*(1+T_EE*s)*(1+T_TM2*s) / K_IT
% Forma ideala (nerealizabila - grad numarator > numitor)
fprintf('\nForma ideala (nerealizabila):\n');
fprintf('H_BC(s) = (1+%.3fs)*(1+%.3fs)*(1+%.3fs) / %.4f\n', T, T_EE, T_TM2, K_IT);

% Forma realizabila: adaugam constante de timp de filtrare Tf la numitor
% (procedeu din lucrare, ec. 4.15)
Tf = 0.1;    % s - constanta de filtrare (mai mica decat Ty)
fprintf('\nForma realizabila (cu %d filtre Tf=%.2fs):\n', 3, Tf);
fprintf('H_BC(s) = (1+%.3fs)*(1+%.3fs)*(1+%.3fs) / (%.4f*(1+%.2fs)^3)\n', ...
    T, T_EE, T_TM2, K_IT, Tf);

% Forma simplificata (ec. 4.16) - retinem doar termenul dominant
% H_BC_simpl(s) = (1+T*s)*(1+T_EE*s) / (K_IT * (1+Tf*s)^2)
fprintf('\nForma simplificata (retinem termenii dominanti):\n');
fprintf('H_BC_simpl(s) = (1+%.3fs)*(1+%.3fs) / (%.4f*(1+%.2fs)^2)\n', ...
    T, T_EE, K_IT, Tf);

% Forma proportionala (cea mai simpla):
K_BC_prop = 1 / K_IT;
fprintf('\nForma proportionala (cea mai simpla):\n');
fprintf('H_BC_prop(s) = %.4f\n\n', K_BC_prop);

%% =========================================================
%% SALVARE PARAMETRI
%% =========================================================
save('lab4_params.mat', 'K_IT','T','Tm','Ty','K_f','T_EE','T_TM1','T_TM2', ...
     'K_R_modul','T_I_modul','Tf','K_BC_prop', ...
     't_step','m_step','y_step','y0','yst','m0','mst', ...
     't_exp','m_exp','y_exp','w_exp');

fprintf('Parametri salvati in lab4_params.mat\n');
fprintf('Rulati acum: lab4_simulare.m\n');

%% =========================================================
%% GRAFIC DATE EXPERIMENTALE
%% =========================================================
figure(1);
subplot(2,1,1);
plot(t_exp, y_exp, 'b-', 'LineWidth', 1.5);
hold on;
plot(t_exp, w_exp, 'r--', 'LineWidth', 1.5);
grid on; xlabel('Timp [s]'); ylabel('Nivel [cm]');
title('Date experimentale - Nivel lichid (Bazin/Rezervor G.U.N.T.)');
legend('y - nivel masurat', 'w - referinta', 'Location','northwest');
xlim([0 t_exp(end)]);

subplot(2,1,2);
plot(t_exp, m_exp, 'g-', 'LineWidth', 1.5);
grid on; xlabel('Timp [s]'); ylabel('Comanda pompa [%]');
title('Semnal de comanda (element de executie)');
xlim([0 t_exp(end)]);

figure(2);
plot(t_step, y_step, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 3, 'DisplayName', 'Raspuns experimental');
hold on;
% Raspuns model identificat
t_sim_id = 0:0.2:t_step(end);
y_model = y0 + (yst-y0)*(1 - exp(-(t_sim_id - Tm)/T));
y_model(t_sim_id < Tm) = y0;
plot(t_sim_id, y_model, 'r-', 'LineWidth', 2, 'DisplayName', ...
    sprintf('Model: K=%.3f, T=%.2fs, Tm=%.2fs', K_IT, T, Tm));
% Tangenta
t_tang = [max(0, Tm-0.5), Tm + T*1.2];
y_tang = y_inf + max_slope*(t_tang - t_inf);
plot(t_tang, y_tang, 'g--', 'LineWidth', 1.5, 'DisplayName', 'Tangenta');
yline(yst, 'k:', 'LineWidth', 1, 'DisplayName', sprintf('yst=%.2fcm', yst));
xline(Tm, 'm:', 'LineWidth', 1.5);
text(Tm+0.2, y0+0.5, sprintf('Tm=%.2fs', Tm), 'Color', 'm');
grid on; xlabel('Timp [s]'); ylabel('Nivel [cm]');
title(sprintf('Identificare experimentala - Metoda tangentei\nH_{IT}(s) = %.4f / (1 + %.3f s) * e^{-%.3f s}', K_IT, T, Tm));
legend('Location','southeast');
xlim([-1 t_step(end)]);
