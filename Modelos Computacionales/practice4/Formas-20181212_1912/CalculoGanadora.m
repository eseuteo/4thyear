function [Gx,Gy]=CalculoGanadora(W,Patron)
%CALCULOGANADORA Summary of this function goes here
%   Detailed explanation goes here
    theta = 1 / 2 * sum(W .^ 2);
    h = Patron .* W;
    hs = squeeze(sum(h) - theta);
    [~, I] = max(hs(:));
    [Gx, Gy] = ind2sub(size(hs), I);
end

