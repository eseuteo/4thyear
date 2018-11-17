function W_out = UpdateNet(W,LR,Output,Target,Input)
    delta_W = LR * (Target - Output) * Input;
    W_out = W + delta_W';