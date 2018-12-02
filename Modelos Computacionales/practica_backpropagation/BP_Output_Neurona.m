function [ S_PC, h_PC ] = BP_Output_Neurona( Network_PC, h_PC, S_PC, Pattern, Parameter )
%BP_OUTPUT_NEURONA Summary of this function goes here
%   Detailed explanation goes here
    
    x_i = Pattern;
    for i = 1:Parameter.NumLayer
        w = Network_PC{i};
        h_PC{i} = x_i * w;
        S_PC{i} = Sigmoide(h_PC{i});
        x_i = S_PC{i};
    end

end
