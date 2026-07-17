function [xmin, fmin] = golden_section(f, a, b, eps)
    while (b-a) > eps
        d = 0.618*(b-a);
        x1 = b - d;
        x2 = a + d;

        if f(x1) <= f(x2)
            b = x2;
        else
            a = x1;
        end
    end

    xmin = (a+b)/2;
    fmin = f(xmin);
end