function ans_W = ModificarPesos(W,Ys,Patron,LR)
% Update of synaptic weights
%   w_r(k+1) = w_r(k) + LR(k) * [x(k) - w_r(k)]
    ans_W = Ys .* W;
    delta_W = Patron' - ans_W;
    delta_W = Ys .* delta_W;
    delta_W = LR * delta_W;
    ans_W = W + delta_W;
end

