function ans = BP_Calcular_Prob(W, tests, Parameter )
    h_PC=cell(1,Parameter.NumLayer);
    S_PC=cell(1,Parameter.NumLayer);
    
    for N=1:Parameter.NumLayer
        h_PC{N}=zeros(1,Parameter.NumNeu(N+1));
        S_PC{N}=zeros(1,Parameter.NumNeu(N+1));    
    end
    
    accuracy = 0;
    output = 0;
    for i = 1:size(tests, 1)
        [S, ~] = BP_Output_Neurona(W, h_PC, S_PC, tests(i, 1:size(tests, 2)-1), Parameter);
        output = S{Parameter.NumLayer} >= 0.5;
        accuracy = accuracy + (output == tests(i, end));
    end
    ans = 100 * accuracy / size(tests,1);
end