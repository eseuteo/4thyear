clear;
clc;
close all;

load DatosXOR
LR=0.05;
% Con un learning rate alto (0.5), la probabilidad de
% no "visitar" los pesos que dan una clasificación correcta
% de tres elementos es muy baja.
Limites=[-1.5, 2.5, -1.5, 2.5];
MaxEpoc=100;

W=PerceptronWeigthsGenerator(Data);
Epoc=1;

W_best = W;
correct_patterns = 0;

while ~CheckPattern(Data,W) && Epoc<MaxEpoc
     for i=1:size(Data,1)
        [Input,Output,Target]=ValoresIOT(Data,W,i);
        
%         GrapDatos(Data,Limites);
%         GrapPatron(Input,Output,Limites);
%         GrapNeuron(W,Limites);hold off;
%         pause;
        
        % Aprendizaje por corrección de errores
        if Output~=Target
           W=UpdateNet(W,LR,Output,Target,Input);
        end
        
%         GrapDatos(Data,Limites);
%         GrapPatron(Input,Output,Limites)
%         GrapNeuron(W,Limites);hold off;
%         pause;
        
     end
    
     % Bolsillo:
     % Aprendizaje por corrección de errores con memoria
     if correct_patterns < CountPocket(Data, W)
         correct_patterns = CountPocket(Data, W);
         W_best = W;
     end
    Epoc=Epoc+1;
end

GrapDatos(Data,Limites);
GrapPatron(Input,Output,Limites)
GrapNeuron(W_best,Limites);hold off;