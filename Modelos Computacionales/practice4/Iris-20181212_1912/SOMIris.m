clear;
clc;
close all;

load('D_Iris3.mat');NumA=4;
eta0=0.9;
IterMax=300;
FC=[6 9];

[NumDatos,~]=size(data);
W=rand(NumA,FC(1),FC(2));
Indices=GenerarIndices(FC);

for i=1:IterMax
    fprintf('i: %d\n',i);
    ind=randperm(NumDatos);
    for j=1:NumDatos
        eta=eta0*(1-i/IterMax);
        Patron=(data(ind(j),1:NumA))';
    
        [Gx,Gy]=CalculoGanadora(W,Patron);
        IndGan=[Gx,Gy]';
        
        Vecindad=FuncionVecindadA(IndGan,W,Indices);
        W=IncrementarPesos(W,Patron,Vecindad,eta);
    end
%     DibujarIris(data,W);
end

DibujarIris(data,W);



        
   
    








