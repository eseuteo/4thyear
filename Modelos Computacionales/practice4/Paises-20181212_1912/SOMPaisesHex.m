clear;
clc;
% close all;

load('PaisesA.mat');NumA=16;
data=num;
eta0=0.9;
IterMax=500;
FC=[10 8];

DibujarWFcHex(FC)


[NumDatos,~]=size(data);
W=rand(NumA,FC(1),FC(2));
Indices=GenerarIndicesHex(FC);

for i=1:IterMax
    fprintf('i: %d\n',i);
    ind=randperm(NumDatos);
    for j=1:NumDatos
        eta=eta0*(1-i/IterMax);
        Patron=(data(ind(j),1:NumA))';
    
        [Gx,Gy]=CalculoGanadora(W,Patron);
        IndGan=Indices(:, Gx, Gy);
        
        Vecindad=FuncionVecindadC(IndGan,W,Indices);
        W=IncrementarPesos(W,Patron,Vecindad,eta);
    end

end

Ganadoras=CalculoGanadorasData(W,data);


DibujarWFcHex(FC)
EscribirCiudades(Ganadoras,FC,txt)










