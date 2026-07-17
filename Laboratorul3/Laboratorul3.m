clc
clear
close all

f = @(x) -exp(x).*sin(x);
fplot(f,[0 pi])
grid on

a = 0; b = pi; eps = 1e-3;

%golden section 


[a_min, b_min] = golden_section(f,a,b,eps)
x_min_approx = (a_min + b_min)/2

f_min_approx = f(x_min_approx)
hold on
plot(x_min_approx,f_min_approx,"o")
%fibonacci

[aF, bF] = fibonacci_search(f,a,b,eps)
x_minF = (aF + bF)/2
f_minF = f(x_minF)

phi = @(s) - (s).^2 - (s).^2 + 18*(s).*(s).^3 - 3;

% cautare liniara pe s in [-2, 2]
[a_s, b_s] = golden_section(phi, -2, 2, 1e-3);
s_min = (a_s + b_s)/2;

% punctul urmator in R^2
xk = [0; 0];
d  = [1; 1];
x_next = xk + s_min * d








