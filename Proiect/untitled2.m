I=eye(2);
O=zeros(2);

A=[O I; O O];
B=[O; I];
P=[1,2,3,4];
K=place(A,B,P)

tau_max=1.18;