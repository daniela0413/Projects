function disp_tf_z(num, den, name)
%DISP_TF_Z  Afiseaza o functie de transfer in domeniul Z
%   disp_tf_z(num, den, name)

if nargin < 3
    name = 'H(z)';
end

fprintf('\n  %s:\n', name);
fprintf('    Numarator: ');
print_poly_z(num);
fprintf('    Numitor:   ');
print_poly_z(den);
fprintf('\n');
end

function print_poly_z(p)
% Afiseaza un polinom in z^-1
str = '';
for i = 1:length(p)
    coef = p(i);
    exp  = -(i-1);
    if abs(coef) < 1e-10
        continue;
    end
    if isempty(str)
        str = sprintf('%.4f', coef);
    else
        if coef >= 0
            str = [str, sprintf(' + %.4f', coef)];
        else
            str = [str, sprintf(' - %.4f', abs(coef))];
        end
    end
    if exp == 0
        % nimic
    elseif exp == -1
        str = [str, '*z^{-1}'];
    else
        str = [str, sprintf('*z^{%d}', exp)];
    end
end
if isempty(str)
    str = '0';
end
fprintf('%s\n', str);
end
