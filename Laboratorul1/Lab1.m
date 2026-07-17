clear
clc
close all

load trace3_36.mat

k = time;
x_hat = val;

% vector initial de parametri
x0 = [1 1 1];

% optimizare
x_opt = fminsearch(@eroare_totala3, x0, [], k, x_hat);
%x_opt = fminunc(@eroare_totala3, x0, [], k, x_hat);

% calculul curbei aproximative
y_aprox = functie(x_opt, k);

% afisare parametri
disp('Parametrii optimi sunt:')
disp(x_opt)

% grafic
plot(k, x_hat, 'x')
hold on
plot(k, y_aprox, 'r-', 'LineWidth', 2)
grid on
xlabel('Timp')
ylabel('Valoare')
title('Aproximarea datelor experimentale')
legend('Date masurate', 'Curba aproximata')