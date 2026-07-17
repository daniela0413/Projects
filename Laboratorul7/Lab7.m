
clear; clc; close all;

%  Definirea functiei
f = @(x) x(1)*x(2)^3 + 2*x(1)^2 + 2*x(2)^4 - 5;

%  Parametrii initiali
V1 = [0; 0];    
V2 = [1; 0];    
V3 = [1; 1];    
epsilon = 1e-4; 
max_iter = 30;  

%  Pregatirea graficului
figure; hold on; grid on;
[X1, X2] = meshgrid(-2:0.05:2, -2:0.05:2);
Z = X1.*X2.^3 + 2.*X1.^2 + 2.*X2.^4 - 5;

%liniile de nivel (izoliniile)
contour(X1, X2, Z, 50, 'LineWidth', 0.8);
colormap jet;
colorbar;
xlabel('x_1'); ylabel('x_2');
title('Optimizare Nelder-Mead (Simplex)');

% Nelder-Mead
for iter = 1:max_iter
    % Desenarea triunghiului curent pe grafic
    
    triunghi = plot([V1(1), V2(1), V3(1), V1(1)], [V1(2), V2(2), V3(2), V1(2)], ...
        'k-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'r');
    
    pause(0.5); 
    
    % Calcularea valorilor functiei in varfuri
    f_vals = [f(V1), f(V2), f(V3)];
    puncte = [V1, V2, V3];
    
    % Sortare pentru a identifica: B (Best), G (Good), W (Worst)
    [~, idx] = sort(f_vals);
    B = puncte(:, idx(1));
    G = puncte(:, idx(2));
    W = puncte(:, idx(3));
    
    % Verificarea conditiei de oprire 
    muchii = [norm(B-G), norm(G-W), norm(W-B)];
    if max(muchii) < epsilon
        fprintf('Algoritmul a convergit la iterația %d.\n', iter);
        break;
    end
    
    %Nelder-Mead 
    M = (B + G) / 2;    
    R = 2*M - W;        % Reflexia
    
    if f(R) < f(W)
        % Incercam o Expansiune (E)
        E = 2*R - M;
        if f(E) < f(R)
            W = E; % Acceptam expansiunea
        else
            W = R; % Ramanem la reflexie
        end
    else
        % Contractie (C)
        C1 = (M + W) / 2;
        C2 = (M + R) / 2;
        
        % Alegem cea mai buna contractie
        if f(C1) < f(C2)
            C = C1;
        else
            C = C2;
        end
        
        if f(C) < f(W)
            W = C; 
        else
            % Reducere (Shrink) - toate punctele se apropie de B
            W = (B + W) / 2;
            G = (B + G) / 2;
        end
    end
    
    % Actualizăm varfurile pentru iteratia următoare
    V1 = B;
    V2 = G;
    V3 = W;
end

% 5. minimul
plot(B(1), B(2), 'p', 'MarkerSize', 15, 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k');
fprintf('Punctul de minim : [%.4f, %.4f]\n', B(1), B(2));
fprintf('Valoarea functiei in minim: %.4f\n', f(B));
hold off;