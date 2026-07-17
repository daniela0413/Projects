clc
clear
close all

[X1,X2] = meshgrid(-2:0.05:2, -2:0.05:2);
F = 2*X1.^2 + 3*X1.*X2 + X2.^3 + X2.^2 - 1;

figure; 
contour(X1,X2,F,40); 
hold on;
grid on;
xlabel('x1'); ylabel('x2');

%Metoda Newton

fgrad = @(x)[4*x(1) + 3*x(2);
             3*x(1) + 3*x(2)^2 + 2*x(2)];

H = @(x)[4, 3;
         3, 6*x(2)+2];

x = [1;1]; % punct initial
eps = 1e-6;

trajN = x';

for k=1:1000
    g = fgrad(x);
    if norm(g) < eps, break; end
    p = H(x)\g;
    x = x - p;
    trajN = [trajN; x'];
end

xNewton = x

%Newton modificat

x = [1;1];
H0 = H(x);
trajMN = x';

for k=1:1000
    g = fgrad(x);
    if norm(g) < eps, break; end
    p = H0\g;
    x = x - p;
    trajMN = [trajMN; x'];
end

xModNewton = x

%traiectorii

plot(trajN(:,1), trajN(:,2), 'r-o', 'LineWidth', 2);
plot(trajMN(:,1), trajMN(:,2), 'b-o', 'LineWidth', 2);
legend('contur','Newton','Newton modificat');


%%
close all;
clear ;
clc;

f = @(x) 2*x(1)^2 + 3*x(1)*x(2) + x(2)^3 + x(2)^2 - 1;

grad_f = @(x) [4*x(1) + 3*x(2); 
               3*x(1) + 3*x(2)^2 + 2*x(2)];

%Parametrii 
x0 = [1; 1];        
tol = 0.01;           
max_iter = 500;       
s_fix = 0.05;         

% Metoda Steepest Descent - Pas FIX
pts_fix = x0;
x_k = x0;
for k = 1:max_iter
    g_k = grad_f(x_k);
    if norm(g_k) < tol, break; end
    
   
    d_k = -g_k / norm(g_k);
    x_k = x_k + s_fix * d_k; 
    pts_fix = [pts_fix, x_k];
end

%  Metoda Steepest Descent - Pas VARIABIL
pts_var = x0;
x_k = x0;
options = optimset('TolX', tol/100); 

for k = 1:max_iter
    g_k = grad_f(x_k);
    if norm(g_k) < tol, break; end
    
    d_k = -g_k / norm(g_k);
   
    f_line = @(s) f(x_k + s * d_k);
    s_k = fminbnd(f_line, 0, 2, options); 
    
    x_k = x_k + s_k * d_k;
    pts_var = [pts_var, x_k];
end

% Vizualizare
figure('Color', 'w');
[X1, X2] = meshgrid(linspace(-2, 2, 100), linspace(-2, 2, 100));
Z = arrayfun(@(x,y) f([x;y]), X1, X2);

contour(X1, X2, Z, 40); hold on; grid on;
plot(pts_fix(1,:), pts_fix(2,:), 'r-o', 'LineWidth', 1.2, 'DisplayName', 'Pas Fix');
plot(pts_var(1,:), pts_var(2,:), 'b-x', 'LineWidth', 1.2, 'DisplayName', 'Pas Variabil');



xlabel('x_1'); ylabel('x_2');
legend('Contur f(x)', 'Steepest Descent (Fix)', 'Steepest Descent (Var)');