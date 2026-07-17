% Parametri
tol_metoda = 1e-4;
tol_golden = tol_metoda / 100;

%functia
f = @(x) 2*x(1)^2 + 3*x(1)*x(2) + x(2)^3 + x(2)^2 - 1;
grad_f = @(x) [4*x(1) + 3*x(2); 3*x(1) + 3*x(2)^2 + 2*x(2)];

% Initializare
x = [1; 0]; 
B = eye(2); 
traiectorie = x;

for k = 1:50
    g = grad_f(x);
    
    if norm(g) < tol_metoda
        fprintf('Convergenta atinsa la iteratia %d\n', k);
        break;
    end
    
    d = -B * g;
    
 
    phi = @(s) f(x + s*d);
    
   
    [a_fin, b_fin] = golden_section(phi, 0, 2, tol_golden);
    s_k = (a_fin + b_fin) / 2; 
    

    x_new = x + s_k * d;
    dx = x_new - x;
    dG = grad_f(x_new) - g;
    
  
    rho = 1 / (dG' * dx);
    I = eye(2);
    B = (I - rho * dx * dG') * B * (I - rho * dG * dx') + rho * (dx * dx');
    
    x = x_new;
    traiectorie = [traiectorie, x];
end

%% 
figure;
fcontour(@(x1,x2) 2*x1.^2 + 3*x1.*x2 + x2.^3 + x2.^2 - 1, [-3 3 -3 3], 'LineWidth', 1);
hold on;
plot(traiectorie(1,:), traiectorie(2,:), 'r-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'k');
plot(traiectorie(1,end), traiectorie(2,end), 'gp', 'MarkerSize', 15, 'MarkerFaceColor', 'g');
xlabel('x_1'); ylabel('x_2');
grid on;