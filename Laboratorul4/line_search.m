function s = line_search(phi)
    % Golden section search pe intervalul [0, 1]
    a = 0;
    b = 1;
    tau = (sqrt(5)-1)/2;
    eps = 1e-4;

    x1 = b - tau*(b-a);
    x2 = a + tau*(b-a);

    f1 = phi(x1);
    f2 = phi(x2);

    while (b - a) > eps
        if f1 < f2
            b = x2;
            x2 = x1;
            f2 = f1;
            x1 = b - tau*(b-a);
            f1 = phi(x1);
        else
            a = x1;
            x1 = x2;
            f1 = f2;
            x2 = a + tau*(b-a);
            f2 = phi(x2);
        end
    end

    s = (a + b)/2;
end
