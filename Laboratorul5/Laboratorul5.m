clear;
close all;
clc;

% Functia (Exercitiul 38)
syms x1 x2 s
f(x1,x2) = 2*x1^2 + 3*x1*x2 + x2^3 + x2^2 - 1;

% Gradientul
Gradient = gradient(f);

% Date initiale
x0 = [1; 1];          
eps = 1e-4;            
eps_line = 1e-6;       
kmax = 100;

% Conturul functiei
[X1,X2] = meshgrid(-2:0.05:2 , -2:0.05:2);
Z = 2*X1.^2 + 3*X1.*X2 + X2.^3 + X2.^2 - 1;

% Fletcher-Reeves (FR)
x = x0;
g = double(Gradient(x(1),x(2)));
d = -g;
pts_FR = x;
iter_FR = 0;

while norm(g) >= eps && iter_FR < kmax
    
    phi(s) = f(x(1) + s*d(1), x(2) + s*d(2));
    phi_fun = matlabFunction(phi);
    
    
    [s_opt_a, s_opt_b] = golden_section(phi_fun, 0, 0.5, eps_line);
    s_opt = (s_opt_a + s_opt_b) / 2;
    
    x_new = x + s_opt*d;
    g_new = double(Gradient(x_new(1),x_new(2)));
    
    beta = (g_new' * g_new) / (g' * g);
    d = -g_new + beta*d;     
    
    x = x_new;                
    g = g_new;                
    pts_FR(:,end+1) = x;      
    
    iter_FR = iter_FR + 1;    
end

x_FR = x;
f_FR = double(f(x_FR(1), x_FR(2)));

fprintf('Gradient Conjugat - Fletcher-Reeves:\n');
fprintf('xmin = [%.6f %.6f]\n', x_FR(1), x_FR(2));
fprintf('f(xmin) = %.6f\n', f_FR);
fprintf('Numar iteratii = %d\n\n', iter_FR);

% Polak-Ribiere (PR)
x = x0;
g = double(Gradient(x(1),x(2)));
d = -g;
pts_PR = x;
iter_PR = 0;

while norm(g) >= eps && iter_PR < kmax
    
    phi(s) = f(x(1) + s*d(1), x(2) + s*d(2));
    phi_fun = matlabFunction(phi);
    [s_opt_a, s_opt_b] = golden_section(phi_fun, 0, 0.5, eps_line);
    s_opt = (s_opt_a + s_opt_b) / 2;
    
    x_new = x + s_opt*d;
    g_new = double(Gradient(x_new(1),x_new(2)));
    
    % Formula Polak-Ribiere (4.2 din curs)
    beta = (g_new' * (g_new - g)) / (g' * g);
    beta = max(beta, 0); % Restart daca beta e negativ
    d = -g_new + beta*d;      
    
    x = x_new;              
    g = g_new;               
    pts_PR(:,end+1) = x;     
    
    iter_PR = iter_PR + 1;   
end

x_PR = x;
f_PR = double(f(x_PR(1), x_PR(2)));

fprintf('Gradient Conjugat - Polak-Ribiere:\n');
fprintf('xmin = [%.6f %.6f]\n', x_PR(1), x_PR(2));
fprintf('f(xmin) = %.6f\n', f_PR);
fprintf('Numar iteratii = %d\n', iter_PR);
%%
% Grafic comparativ
figure;
contour(X1,X2,Z,50)
hold on
grid on
%%
plot(pts_FR(1,:), pts_FR(2,:), 'o-','LineWidth',1.5, 'DisplayName', 'Fletcher-Reeves')
plot(pts_PR(1,:), pts_PR(2,:), 'r--s','LineWidth',1.2, 'DisplayName', 'Polak-Ribiere')
plot(x0(1),x0(2),'k*','MarkerSize',10, 'DisplayName', 'Punct initial')

xlabel('x_1')
ylabel('x_2')
title('Comparatie Gradient Conjugat pe functia Ex. 38')
legend show