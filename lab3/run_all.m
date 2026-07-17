%% LABORATOR NR. 3 - Script Principal
%% Ruleaza ambele metode si centralizeaza rezultatele
%
% INSTRUCTIUNI:
%   1. Adauga folderul 'common' in path-ul MATLAB inainte de rulare
%   2. Ruleaza acest script din folderul 'lab3'
%   3. Rezultatele sunt afisate in Command Window si salvate in fisiere .png

clear; clc; close all;

% Adauga common la path
addpath(fullfile(fileparts(mfilename('fullpath')), 'common'));

fprintf('============================================================\n');
fprintf('   LABORATOR NR. 3 - Sisteme de Reglare Numerice\n');
fprintf('============================================================\n\n');

%% === METODA DAHLIN ===
fprintf('>>> Rulare Metoda Dahlin...\n\n');
cd_old = cd;
cd(fullfile(fileparts(mfilename('fullpath')), 'dahlin'));
addpath(fullfile(fileparts(mfilename('fullpath')), 'common'));
run('metoda_dahlin.m');
cd(cd_old);

fprintf('\n============================================================\n\n');

%% === METODA KALMAN ===
fprintf('>>> Rulare Metoda Kalman...\n\n');
cd(fullfile(fileparts(mfilename('fullpath')), 'kalman'));
addpath(fullfile(fileparts(mfilename('fullpath')), 'common'));
run('metoda_kalman.m');
cd(cd_old);

fprintf('\n============================================================\n');
fprintf('   FINALIZAT - verificati graficele si tabelele de mai sus\n');
fprintf('============================================================\n');
