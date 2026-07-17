clc
clear 
close all

data=load("proj_fit_04.mat");

X1_id=data.id.X{1};
X2_id=data.id.X{2};
Y_id=data.id.Y;

X1_val=data.val.X{1};
X2_val=data.val.X{2};
Y_val=data.val.Y;

for i=1:25
m=i;
element1=[];
phi=[];
phi_id=PHI(m,X1_id,X2_id,phi,element1);

y_aprox_id=YAprox(m,X1_id,X2_id,phi,element1,Y_id);
e_id=Y_id-y_aprox_id;
mse_id(m)=MSE(e_id);

y_aprox_val=YAprox(m,X1_val,X2_val,phi,element1,Y_val);
e_val=Y_val-y_aprox_val;
mse_val(m)=MSE(e_val);
end

m=1:25;
figure("Name","Grafic pentru MSE pentru datele de validare")
plot(m,mse_val,"-*")
MSE_val_min=min(mse_val)


figure('Name',"Subantrenat vs Supraantrenat")
plot(m,mse_val,"-*",'Color','red')
hold on
plot(m,mse_id,"-*",'Color','green')
legend('Eroarea pe datele de validare','Eroarea pe datele de identificare')

figure('Name','Verificare')
mesh(X1_val,X2_val,Y_val,'EdgeColor','green')
hold on
mesh(X1_val,X2_val,YAprox(20,X1_val,X2_val,phi,element1,Y_val),'EdgeColor','red')
legend('Functia necunoscuta','Functia aproximata')

function element=ELEMENT(m,x1,x2,element)
for i=0:m
    element=[element;(x1.^(m-i).*x2.^(i))];
end   
end

function phi=PHI(m,x1,x2,phi,element)   
for i=1:m+1
    phi=[phi;ELEMENT((i-1),x1,x2,element)];    
end
end

function y_aprox=YAprox(m,x1,x2,element,phi,y)
phi=PHI(m,x1,x2,phi,element)';
teta=phi\y;
y_aprox=phi*teta;
end


function mse=MSE(eroare)
[N1,N2]=size(eroare);
mse=0;
for i=1:N1
    for j=1:N2
        mse=mse+((1/(N1*N2))*eroare(i,j)^2);  
    end
end
end