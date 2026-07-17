function [a,b] = fibonacci_search(f,a,b,eps)
    F = [2 3];   % F1=2, F2=3
    n = 2;
    while (b - a) >= eps
        d = (b - a) * F(n-1)/F(n);
        x1 = b - d;
        x2 = a + d;
        if f(x1) <= f(x2)
            b = x2;
        else
            a = x1;
        end
        n = n + 1;
        F(n) = F(n-1) + F(n-2);
    end
end
