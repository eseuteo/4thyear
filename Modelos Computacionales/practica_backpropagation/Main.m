%60%-40%
%Algoritmo donde divide el conjunto de patrones en 2 partes uno para train
%y otro para test.
%y calcula el tiempo que tarda en realizar una iteracion en función de las
%neuronas

clc;
clear;
close all;
%rng(1)
% Reg_Cla='Regresion/';
% Data=load([Reg_Cla 'D_Airfoil']);Neu=[5  1]; 
% Data=load([Reg_Cla 'D_C_C_Power_Plant']);Neu=[4  1]; 
% Data=load([Reg_Cla 'D_Concrete_Com_Str']);Neu=[8 1];
% Data=load([Reg_Cla 'D_Concrete_Slump']);Neu=[10 1]; 
% Data=load([Reg_Cla 'D_Energy_Efficient_A']);Neu=[8 1];
% Data=load([Reg_Cla 'D_Energy_Efficient_B']);Neu=[8 1];
% Data=load([Reg_Cla 'D_Forest_Fire']);Neu=[12 1];
% Data=load([Reg_Cla 'D_Housing']);Neu=[13 1];
% Data=load([Reg_Cla 'D_Parkinson_Telemonit']);Neu=[21 1];
% Data=load([Reg_Cla 'D_WineQuality_Red']);Neu=[11 1];
% Data=load([Reg_Cla 'D_WineQuality_White']);Neu=[11 1];
% Data=load([Reg_Cla 'D_Yacht_Hydrodynamics']);Neu=[6  1]; 

 Reg_Cla='Clasificacion/';
% Data=load([Reg_Cla 'D_Blood_Transfusion']);Neu=[4  1]; 
% Data=load([Reg_Cla 'D_Cancer']);Neu=[9  1]; 
 Data=load([Reg_Cla 'D_Card']);Neu=[51 1];
% Data=load([Reg_Cla 'D_Climate']);Neu=[18 1]; 
% Data=load([Reg_Cla 'D_Diabetes']);Neu=[8 1];
% Data=load([Reg_Cla 'D_heartc']);Neu=[35 1];
% Data=load([Reg_Cla 'D_Ionosphere']);Neu=[34 1];
% Data=load([Reg_Cla 'D_Sonar']);Neu=[60 1];
% Data=load([Reg_Cla 'D_Statlog(Heart)']);Neu=[13 1];
% Data=load([Reg_Cla 'D_Vertebral_Column']);Neu=[6 1];

Data=Data.data; 


Parameter.NumNeu=[Neu(1) 10 10 10 10 10 10 10 10 10 10 10 10 10 10 Neu(2)]; 


Parameter.Eta=0.1;
Parameter.NumEpoch=500;


Parameter.NumLayer=length(Parameter.NumNeu)-1;

[FilData,ColData]=size(Data);

Data2=Data(randperm(FilData),:);%Data2=Data;
%Data2=Data;

ProbTrain=0.5;
ProbValid=0.3;
ProbTests=0.2;

FilaTrain=fix(FilData*ProbTrain);
FilaValid=fix(FilData*(ProbValid));
FilaTests=FilData-FilaTrain-FilaValid;

Datos.Train=Data2(1:FilaTrain,:);
Datos.Valid=Data2(FilaTrain+1:FilaTrain+FilaValid,:);
Datos.Tests=Data2(FilaTrain+FilaValid+1:end,:);


[NumPatTra,~]=size(Datos.Train);
[NumPatVal,~]=size(Datos.Valid);



Network_PC=cell(1,Parameter.NumLayer);
h_PC=cell(1,Parameter.NumLayer);
S_PC=cell(1,Parameter.NumLayer);
Deltas_PC=cell(1,Parameter.NumLayer);

for N=1:Parameter.NumLayer
    h_PC{N}=zeros(1,Parameter.NumNeu(N+1));
    S_PC{N}=zeros(1,Parameter.NumNeu(N+1));
    Deltas_PC{N}=zeros(1,Parameter.NumNeu(N+1));
    Network_PC{N}=randn(Parameter.NumNeu(N),Parameter.NumNeu(N+1));
    % Network_PC{N}=0.1*ones(Parameter.NumNeu(N),Parameter.NumNeu(N+1));
    
end

DiferT_PC=zeros(Parameter.NumNeu(end),NumPatTra);
Difer2T_PC=zeros(Parameter.NumNeu(end),NumPatTra);
DiferV_PC=zeros(Parameter.NumNeu(end),NumPatVal);
Difer2V_PC=zeros(Parameter.NumNeu(end),NumPatVal);

ErrorFinal_PC=Inf;
for NumEpoc=1:Parameter.NumEpoch
  NumEpoc;
%   p=NumPatTra:-1:1;
      p=1:NumPatTra;
     for i=1:NumPatTra
         Pattern=Datos.Train(p(i),1:Parameter.NumNeu(1));
         Target=Datos.Train(p(i),Parameter.NumNeu(1)+1:end);
         [S_PC,h_PC] = BP_Output_Neurona(Network_PC,h_PC,S_PC, Pattern, Parameter);
         DiferT_PC(:,i)=(Target-S_PC{end});
         Deltas_PC=BP_Calculo_Deltas(S_PC,Deltas_PC,DiferT_PC(:,i),Network_PC,Parameter);
         Network_PC=BP_Incrementar_Pesos(Network_PC,Deltas_PC,S_PC,Pattern,Parameter);
     end
Difer2T_PC=DiferT_PC.^2;
ErrorIter_PC=sum(sum(Difer2T_PC))/NumPatTra;
MSE.PC.Train(NumEpoc)=ErrorIter_PC;   


q=NumPatVal:-1:1;
    for i=1:NumPatVal
         Pattern=Datos.Valid(q(i),1:Parameter.NumNeu(1));
         Target=Datos.Valid(q(i),Parameter.NumNeu(1)+1:end);
 
         [S,h] = BP_Output_Neurona(Network_PC,h_PC,S_PC,Pattern,Parameter);
         DiferV_PC(:,i)=(Target-S{end});
     end  
     Difer2V_PC=DiferV_PC.^2;
     ErrorValid_PC=sum(sum(Difer2V_PC))/NumPatVal;
     MSE.PC.Valid(NumEpoc)=ErrorValid_PC;
     
     if ErrorValid_PC<ErrorFinal_PC
         Iteration_PC=NumEpoc;
         Network_PCFinal=Network_PC;
         ErrorFinal_PC=ErrorValid_PC;
     end

end
  
MSE.PC.Prob=BP_Calcular_Prob(Network_PCFinal, Datos.Tests, Parameter);
disp(MSE.PC.Prob)


plot(MSE.PC.Train,'LineStyle','-','Color',[1 0 0],'LineWidth',3);hold on;
plot(MSE.PC.Valid,'LineStyle',':','Color',[0 0 1 ],'LineWidth',3);hold on;

LimiteY=min(0.4,max(max(MSE.PC.Train,MSE.PC.Train)));
axis([0 Parameter.NumEpoch 0 LimiteY])
legend('PC Train','PC Validation');

