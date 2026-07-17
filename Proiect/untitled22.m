clc
clear
close all

A=332.5;
k=0.035;
k1=0.624;%experimental aflat
k2=-0.015;%experimental aflat
k3=-0.0006;%experimental aflat
C=9;
Pv=2;

k11=k2^2+4*(k-k3)*k1;
k12=4*(k-k3)*Pv; 
k13=2*(k-k3);

keta=8*10^(-5);

