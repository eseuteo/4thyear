clear;
clc;
close all;

load DatosLS50
LR=0.1;
% En muchas ocasiones, con el LR a 0.1 no "empieza"
% el gradiente de error.
Limites=[-1.5, 2.5, -1.5, 2.5];
MaxEpoc=100;

W=PerceptronWeigthsGenerator(Data);
Epoc=1;

ErrorHistory = [];
prev_E = realmax;
[prevInput, prevOutput, prevTarget] = valoresIOTADALINE(Data,W,1);
prevW = W;
gradientDecreases = true;

% Si no empleamos el checkpatterns la curva es más "curva" (hace todas las épocas)
while gradientDecreases && Epoc<MaxEpoc
     for i=1:size(Data,1)
        [Input,Output,Target]=valoresIOTADALINE(Data,W,i);
        
        GrapDatos(Data,Limites);
        GrapPatron(Input,Output,Limites);
        GrapNeuron(W,Limites);hold off;
        drawnow;
        
        W=UpdateNet(W,LR,Output,Target,Input); % Modificar pesos red con el gradiente de error
        
       GrapDatos(Data,Limites);
       GrapPatron(Input,Output,Limites)
       GrapNeuron(W,Limites);hold off;
       drawnow;
       
     end
    E = get_error(W, Data);
    if E <= prev_E
        ErrorHistory = [ErrorHistory, E];
        prev_E = E;
        prevInput = Input;
        prevOutput = Output;
        prevTarget = Target;
        prevW = W;
    else
        gradientDecreases = false;
    end
    Epoc=Epoc+1;
end

GrapDatos(Data,Limites);
GrapPatron(prevInput,prevOutput,Limites)
GrapNeuron(prevW,Limites);hold off;
f = figure(2);
% Ploteamos la curva de error
plot(ErrorHistory, '-')