function Deltas_PC = BP_Calculo_Deltas( S_PC, Deltas_PC, dist, Network_PC, Parameter )
%BP_OUTPUT_NEURONA Summary of this function goes here
%   Detailed explanation goes here
    e = dist';
    for i = Parameter.NumLayer:-1:1
            Deltas_PC{i} = derivar(S_PC{i}) .* e';
            if i > 1 
                e = Network_PC{i} * Deltas_PC{i}';
            end
    end

end
