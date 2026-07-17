% domeniu
x1 = linspace(-2, 2, 200);
x2 = linspace(-2, 2, 200);

[X1, X2] = meshgrid(x1, x2);

% functia
F = 81*X1.^2 + 27*X1.*X2 + 18*X2.^2 + X2.^4 - 9;
figure
% plot
mesh(X1, X2, F)

syms x1 x2

eq1 = 162*x1 + 27*x2 == 0;
eq2 = 27*x1 + 36*x2 + 4*x2^3 == 0;

sol = solve([eq1, eq2], [x1, x2]);
sol.x1
sol.x2
%%
x1 = linspace(-2, 2, 400);
x2 = linspace(-2, 2, 400);
[X1, X2] = meshgrid(x1, x2);

F = 81*X1.^2 + 27*X1.*X2 + 18*X2.^2 + X2.^4 - 9;
figure
contour(X1, X2, F, 40); hold on
% constrangerea
x2_line = linspace(-2, 2, 400);
x1_line = x2_line - 1;
plot(x1_line, x2_line, 'r', 'LineWidth', 2)

% Punctul optim
x1_opt = -0.256;
x2_opt = 0.744;
plot(x1_opt, x2_opt, 'ko', 'MarkerFaceColor', 'k')

syms x2
sol = solve(4*x2^3 + 252*x2 - 189 == 0, x2);

sol_numeric = vpa(sol)

syms z

A = [162 - z, 27,      1;
     27,      42.64 - z, -1;
     1,       -1,       0];

eq = det(A) == 0;

solz = solve(eq, z);
solz = vpa(solz)

