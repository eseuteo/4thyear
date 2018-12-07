function Ys = CalculoYs(Hs)
% Computer dynamics
% y =
%       1 if h_i = max_k {h_1, ..., h_M}
%       0 otherwise
    Ys = (Hs == max(Hs, [], 2));
end

