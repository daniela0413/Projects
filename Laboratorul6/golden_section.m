function [a,b] = golden_section(f,a,b,eps)
    d = b - a;
    while (b - a) >= eps
        d = 0.618 * d;
        x1 = b - d;
        x2 = a + d;
        if f(x1) <= f(x2)
            b = x2;
        else
            a = x1;
        end
    end
end
