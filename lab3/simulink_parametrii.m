%% LABORATOR NR. 3 - Parametrii pentru modelul Simulink
%% (conform Figurii 3.3 din laborator)
%
% Acest script calculeaza toti parametrii necesari pentru a configura
% manual modelul Simulink descris in Figura 3.3:
%
%  w --> [+/-] --> [RN] --> [EOZ] --> [Tm] --> [H_f(s)] --> y
%                                                  |
%                                     [TM] <-------+
%
% unde:
%   RN  = regulatorul numeric (Discrete Transfer Function in z^-1)
%   EOZ = extrapolator ordin zero (Zero-Order-Hold)
%   Tm  = timp mort (Transport Delay)
%   H_f = partea fixa (Transfer Function)
%   TM  = traductor de masura (in acest caz = 1)

clear; clc;
addpath('../common');

fprintf('=== PARAMETRII SIMULINK - LABORATOR 3 ===\n\n');

%% ---- SISTEM 1: Metoda Dahlin ----
fprintf('--- SISTEM 1 (Metoda Dahlin) ---\n');
Kf1 = 4.3; T11 = 5; T21 = 23; Tm1 = 2.5; TE1 = 0.5;
T01  = 3;  % constanta de timp impusa

sys1_c = tf(Kf1, conv([T11 1],[T21 1]));
nd1    = round(Tm1/TE1);
sys1_d = c2d(sys1_c, TE1, 'zoh');
[B1,A1] = tfdata(sys1_d,'v');

fprintf('Parametrii bloc "Transfer Function" (parte fixa):\n');
fprintf('  Numerator: %s\n', mat2str(Kf1));
fprintf('  Denominator: %s\n', mat2str(conv([T11 1],[T21 1])));
fprintf('  (in continuu: Kf/(T1*s+1)/(T2*s+1))\n\n');

fprintf('Parametrii bloc "Transport Delay" (timp mort):\n');
fprintf('  Time delay: %.2f min\n\n', Tm1);

fprintf('Parametrii bloc "Zero-Order-Hold":\n');
fprintf('  Sample time: %.2f min\n\n', TE1);

fprintf('Functia de transfer discreta a partii fixate:\n');
disp_tf_z(B1, A1, 'H_f1(z)');
fprintf('  (cu timp mort z^-%d)\n\n', nd1);

% Calcul regulator Dahlin
sys0_1 = tf(1,[T01 1]);
sys0_1d = c2d(sys0_1, TE1, 'zoh');
[B01,A01] = tfdata(sys0_1d,'v');

num_R1 = conv(A1, B01);
A01_mB01 = A01; A01_mB01(1:length(B01)) = A01_mB01(1:length(B01)) - B01;
den_R1_nd = [zeros(1,nd1), conv(B1, A01_mB01)];
scale1 = den_R1_nd(1);
num_R1 = num_R1/scale1;
den_R1 = den_R1_nd/scale1;

fprintf('Parametrii bloc "Discrete Transfer Function" (regulator Dahlin):\n');
fprintf('  Numerator (in z^-1): %s\n', mat2str(num_R1, 4));
fprintf('  Denominator (in z^-1): %s\n', mat2str(den_R1, 4));
fprintf('  Sample time: %.2f min\n\n', TE1);

%% ---- SISTEM 2: Metoda Kalman ----
fprintf('--- SISTEM 2 (Metoda Kalman) ---\n');
Kf2 = 1.25; T12 = 9; T22 = 14; Tm2 = 3; TE2 = 1;

sys2_c = tf(Kf2, conv([T12 1],[T22 1]));
nd2    = round(Tm2/TE2);
sys2_d = c2d(sys2_c, TE2, 'zoh');
[B2,A2] = tfdata(sys2_d,'v');

fprintf('Parametrii bloc "Transfer Function" (parte fixa):\n');
fprintf('  Numerator: %s\n', mat2str(Kf2));
fprintf('  Denominator: %s\n', mat2str(conv([T12 1],[T22 1])));
fprintf('\n');

fprintf('Parametrii bloc "Transport Delay":\n');
fprintf('  Time delay: %.2f min\n\n', Tm2);

fprintf('Parametrii bloc "Zero-Order-Hold":\n');
fprintf('  Sample time: %.2f min\n\n', TE2);

fprintf('Functia de transfer discreta a partii fixate:\n');
disp_tf_z(B2, A2, 'H_f2(z)');
fprintf('  (cu timp mort z^-%d)\n\n', nd2);

% Calcul regulator Kalman
S2 = sum(B2);
K2 = 1/S2;
P2 = K2 * B2;
Q2 = K2 * A2;

P2_del = [P2, zeros(1,nd2)];
one_mP2 = -P2_del; one_mP2(1) = one_mP2(1) + 1;
scale2 = one_mP2(1);
num_R2 = Q2/scale2;
den_R2 = one_mP2/scale2;

fprintf('K (constanta amplificare Kalman) = %.4f\n\n', K2);
fprintf('Parametrii bloc "Discrete Transfer Function" (regulator Kalman):\n');
fprintf('  Numerator (in z^-1): %s\n', mat2str(num_R2, 4));
fprintf('  Denominator (in z^-1): %s\n', mat2str(den_R2, 4));
fprintf('  Sample time: %.2f min\n\n', TE2);

fprintf('\n=== SFARSIT PARAMETRII SIMULINK ===\n');
fprintf('Copiati valorile de mai sus in blocurile corespunzatoare din Simulink.\n');
