function Network_PC = BP_Incrementar_Pesos( Network_PC, Deltas_PC, S_PC, Pattern, Parameter)
    for i = 1:Parameter.NumLayer
        if i == 1
            Network_PC{i} = Network_PC{i} + Parameter.Eta * Deltas_PC{i} .* Pattern';
        else
            Network_PC{i} = Network_PC{i} + Parameter.Eta * Deltas_PC{i} .* S_PC{i-1}';
        end
    end
end