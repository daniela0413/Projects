clear all
clc

A=332.5;
C=7.4;
k=0.036;

u0=5.6;
u1=u0+0.5;
q0= 30.22;
h0=16.53;
q1=33.19;
h1=20.06;

deltah=h1-h0;
deltaq=q1-q0;
deltau=u1-u0;

k1=0.654;
k2=-0.015;
k3=-0.0006;


k11=k2^2+4*(k-k3)*k1;
k12=8*(k-k3);
k13=2*(k-k3);

qmax=92;
keta = 8e-5;

% identificare
kp=deltah/3/deltau;
h0+0.63*deltah % caut cat e T la valoarea asta
%%
Tp=201;

%proces
Hp=tf(kp,[Tp 1])

% %bucla inchisa
H0=tf(1,[40 1])

% %regulator PI
Hr=H0/(Hp*(1-H0))
pidstd(Hr)
%%
k_pi=1.7;
ti_pi=201;

%% cascada bucla interna
deltaq1=35.84-30.22;
kp2=deltaq1/deltau
0.63*deltaq1+q0
%%
Tp2=0.784;
Hp2=tf(kp2, [Tp2,1])

H01=tf(1,[1,1]);

Hr2=(1/Hp2)*(H01/(1-H01));
pidstd(Hr2)
%%
k_2=0.0698;
ti_2=0.784;
%% bucla externa
deltah1=20.11-16.53
kp1=(deltah1/3)/deltaq
0.63*deltah1+h0
%%
Tp1=388;
Hp1=tf(kp1, [Tp1,1])


Hr1=(1/Hp1)*(H0/(1-H0));
pidstd(Hr1)
%%
k_1=25.2;
ti_1=382;