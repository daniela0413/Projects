clc;
clear;
close all;

date=load("iddata-18.mat");

u_id=date.id.InputData;
y_id=date.id.OutputData;

u_val=date.val.InputData;
y_val=date.val.OutputData;
Ts=date.val.Ts;

MSE_p_id = zeros(1, 10);
MSE_s_id = zeros(1, 10);
MSE_p_val = zeros(1, 10);
MSE_s_val = zeros(1, 10);
% n=10;
% na=n;
% nb=n;
% m=1;
for n = 1:10
    na = n;
    nb = n;
    m = 1; 

   puteri = PUTERI(na, nb, m);

    % Identificare
    semnal_id = SEMNAL(na, nb, u_id, y_id);
    phi_id = PHI(puteri, semnal_id)';
    teta_id = phi_id \ y_id;

    y_predictie_id = phi_id * teta_id;
    MSE_p_id(n) = MSE(y_id, y_predictie_id);
    y_simulat_id = YSimulat(na, nb, puteri, u_id, y_id, teta_id)';
    MSE_s_id(n) = MSE(y_id, y_simulat_id);

    % Validare
    semnal_val = SEMNAL(na, nb, u_val, y_val);
    phi_val = PHI(puteri, semnal_val)';
    teta_val = phi_val \ y_val;

    y_predictie_val = phi_val * teta_val;
    MSE_p_val(n) = MSE(y_val, y_predictie_val);
    y_simulat_val = YSimulat(na, nb, puteri, u_val, y_val, teta_id)';
    MSE_s_val(n) = MSE(y_val, y_simulat_val);
end

% Ploturi pentru erori
figure;
plot(MSE_p_id, '-o');
xlabel('n');
ylabel('MSE');
title('Eroarea de predicție - Identificare');
grid on;

figure;
plot( MSE_s_id, '-o');
xlabel('n');
ylabel('MSE');
title('Eroarea de simulare - Identificare');
grid on;

figure;
plot( MSE_p_val, '-o');
xlabel('n');
ylabel('MSE');
title('Eroarea de predicție - Validare');
grid on;

figure;
plot( MSE_s_val, '-o');
xlabel('n');
ylabel('MSE');
title('Eroarea de simulare - Validare');
grid on;
function puteri = PUTERI(na, nb, m)  
    total_termeni = na + nb;
    puteri = [];
    indici = zeros(1, total_termeni);  
    puteri = GenereazaPuteri(total_termeni, m, indici, 1, puteri);  
end

function genereaza_puteri = GenereazaPuteri(total_termeni, m, indici, pozitie, genereaza_puteri)
   if pozitie > total_termeni
        suma_puteri=0;
        for i=1:length(indici)
            suma_puteri=suma_puteri+indici(i);
        end
        if suma_puteri <= m  
            genereaza_puteri = [genereaza_puteri; indici];  
        end
        return;
   end

    for i = 0:m
        indici(pozitie) = i;  
        genereaza_puteri = GenereazaPuteri(total_termeni, m, indici, pozitie + 1, genereaza_puteri); 
    end
end

function semnal=SEMNAL(na,nb,u,y)
N=length(u);
matriceaY=[];
matriceaU=[];
for i=1:N
    for j=1:na
        index=i-j;
        if index>0
            matriceaY(i,j)=-y(index);
        else
            matriceaY(i,j)=0;
       end
    end
    for j=1:nb
        index=i-j;
        if index>0
            matriceaU(i,j)=u(index);
        else
            matriceaU(i,j)=0;
       end
    end
end
semnal=[matriceaY,matriceaU];
end

function phi = PHI(puteri,semnal)
phi = [];   
[N1, ~] = size(semnal);  
[N2, ~] = size(puteri); 

for i = 1:N1  
    s = semnal(i, :);  
    linie_fiecareSemnal= [];      
    for j = 1:N2 
        p = puteri(j, :);  
        semnal_p = s.^p; 
        produs=1;
        for l=1:length(semnal_p)
            produs=produs*semnal_p(l);
        end
        linie_fiecareSemnal = [linie_fiecareSemnal; produs];
    end   
    phi = [phi, linie_fiecareSemnal];  
end
end

function y_simulat = YSimulat(na,nb,puteri, u, y,teta) 
N = length(y);
y_simulat = zeros(1, N);
[N1,~]=size(puteri);
matriceaY=[];
matriceaU=[];
for i = 1:N
    for j=1:na
        index=i-j;
        if index>0
            matriceaY(:,j)=-y_simulat(index);
        else
            matriceaY(:,j)=0;
       end
    end
    for j=1:nb
        index=i-j;
        if index>0
            matriceaU(:,j)=u(index);
        else
            matriceaU(:,j)=0;
       end
    end
    semnal(i, :) = [matriceaY, matriceaU];
    phi = PHI(puteri,semnal)'; 
    s = 0;
        for k=1:N1
            s = s + teta(k,:)*phi(i, k);
        end
        y_simulat(:, i) = s; 
end
end


function mse=MSE(y1,y2)
N=length(y1);
eroare=0;
    for i=1:N
        e=y1(i)-y2(i);
        eroare=eroare+(1/N)*e^2;
    end
   mse=eroare;
end