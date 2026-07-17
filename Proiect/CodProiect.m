clc
clear
close all

A=332.5;
C=9;
A=332.5;
k=0.035;
k1=0.654;%experimental aflat
k2=-0.015;%experimental aflat
k3=-0.0006;%experimental aflat
C=9;
Pv=2;

k11=k2^2+4*(k-k3)*k1; %=0.0934
k12=4*(k-k3)*Pv; %0.2848
k13=2*(k-k3); %0.0712

keta=8*10^(-5);

