clear;
close all;
clc;

% DEFINIREA FUNCTIEI
f = @(x1,x2) x1*x2^3+2*x1^2+2*x2^4-5;

% DATE INITIALE
x = [1; 1];
d(:,1) = [1; 0];
d(:,2) = [0; 1];

s0 = [0.5; 0.5];
s  = s0;

alpha = 2;
beta  = -0.5;

eps = 1e-4;
kmax = 50;

% MEMORARE TRAIECTORIE
X_path = x;

% METODA ROSENBROCK
k = 0;
stop = false;

while ~stop && k < kmax
    k = k + 1;

    success = [0; 0];
    fail    = [0; 0];
    c       = [0; 0];

    oscillation = false;

    while ~oscillation
        for i = 1:2
            x_trial = x + s(i)*d(:,i);

            f_cur   = f(x(1), x(2));
            f_trial = f(x_trial(1), x_trial(2));

            if f_trial < f_cur
                % SUCCES
                x = x_trial;
                c(i) = c(i) + s(i);
                success(i) = 1;
                s(i) = alpha * s(i);

                X_path = [X_path x];
            else
                % ESEC
                fail(i) = 1;
                s(i) = beta * s(i);
            end
        end

        % Oscilatie
        if all(success == 1) && all(fail == 1)
            oscillation = true;
        end

        if norm(s) < eps
            oscillation = true;
            stop = true;
        end
    end

    if stop
        break;
    end

    % CALCULUL NOILOR DIRECTII
    a(:,1) = c(1)*d(:,1) + c(2)*d(:,2);
    a(:,2) = c(2)*d(:,2);

    % Gram-Schmidt
    b(:,1) = a(:,1);

    if norm(b(:,1)) > 1e-12
        d_new(:,1) = b(:,1) / norm(b(:,1));
    else
        d_new(:,1) = d(:,1);
    end

    if norm(b(:,1)) > 1e-12
        b(:,2) = a(:,2) - ((a(:,2)'*b(:,1)) / (norm(b(:,1))^2)) * b(:,1);
    else
        b(:,2) = a(:,2);
    end

    if norm(b(:,2)) > 1e-12
        d_new(:,2) = b(:,2) / norm(b(:,2));
    else
        d_new(:,2) = d(:,2);
    end

    d = d_new;

    % reset pasii
    s = s0;

    if norm(x) < eps
        stop = true;
    end
end

% GRAFIC
[X1, X2] = meshgrid(-0.5:0.02:1.5, -0.5:0.02:1.5);
F = f(X1, X2);

figure;
contour(X1, X2, F, 30);
grid on;
hold on;
xlabel('x_1');
ylabel('x_2');
title('Metoda Rosenbrock - Traiectoria');

plot(X_path(1,:), X_path(2,:), 'ro-', 'LineWidth', 2);
plot(X_path(1,1), X_path(2,1), 'bs', 'MarkerFaceColor', 'b');
plot(X_path(1,end), X_path(2,end), 'kd', 'MarkerFaceColor', 'k');
legend('Curbe de nivel', 'Traiectorie', 'Start', 'Final');