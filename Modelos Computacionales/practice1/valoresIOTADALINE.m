function [Input,Output,Target]=valoresIOTADALINE(Data,W,i)
    % Similar a valoresIOT, pero sin usar la función signo
    Input = [Data(i, 1:2), -1];
    Output = Input * W;
    Target = Data(i, end);