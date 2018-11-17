clear;
clc;
close all;

load DatosXOR
LR=0.5;
% Se ha probado con valores de LR entre 0.5 y 0.01
% Clasificación correcta para todas las entradas (excepto XOR)
% En la mayoría de casos el resultado para XOR clasifica bien 2 elementos
Limites=[-1.5, 2.5, -1.5, 2.5];
MaxEpoc=100;

W=PerceptronWeigthsGenerator(Data);
Epoc=1;

while ~CheckPattern(Data,W) && Epoc < MaxEpoc
    for i=1:size(Data,1)
        [Input,Output,Target]=ValoresIOT(Data,W,i);
%         GrapDatos(Data,Limites);
%         GrapPatron(Input,Output,Limites);
%         GrapNeuron(W,Limites);hold off;
%         pause;
        
        % Aprendizaje por corrección de errores:
        if Output ~= Target                  
           W=UpdateNet(W,LR,Output,Target,Input);
        end
        
%         GrapDatos(Data,Limites);
%         GrapPatron(Input,Output,Limites)
%         GrapNeuron(W,Limites);hold off;
%         pause;
    end
    Epoc=Epoc+1;
end

        GrapDatos(Data,Limites);
        GrapPatron(Input,Output,Limites)
        GrapNeuron(W,Limites);hold off;