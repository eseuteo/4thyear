function Hs = CalculoHs(W, Patron)
% Synaptic potential
%   h_i = w_i1 * x_1 + ... + w_in * x_n - theta_i
%   theta_i = 1/2 * (w_i1² + ... + w_in²)
    theta = 1/2 * sum(W .^ 2);
    Hs = Patron * W - theta;
end

