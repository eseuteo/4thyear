function ganadoras = CalculoGanadorasData(W, Data)
%CALCULOGANADORA Summary of this function goes here
%   Detailed explanation goes here
    Gx = zeros(size(Data, 1),1);
    Gy = zeros(size(Data, 1),1);
    theta = 1 / 2 * sum(W .^ 2);
    for i= 1:size(Data, 1)
        h = Data(i,:)' .* W;
        hs = squeeze(sum(h) - theta);
        [~, I] = max(hs(:));
        [Gx(i), Gy(i)] = ind2sub(size(hs), I);
    end
    ganadoras = [Gx, Gy]
end


