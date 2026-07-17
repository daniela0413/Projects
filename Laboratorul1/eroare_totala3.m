function E = eroare_totala3(x, k, x_hat)

y_model = functie(x, k);

E = sum((y_model - x_hat).^2);

end