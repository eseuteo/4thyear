function [Input,Output,Target]=ValoresIOT(Data,W,i)
    Input = [Data(i, 1:2), -1];
    Output = sign(Input * W);
    Target = Data(i, end);
    