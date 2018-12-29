function [jHxf] = GetObsJacs(xPred, xFeature)
    delta = xFeature - xPred(1:2);
    d = norm(delta);
    
    jHxf = zeros(size(xFeature,1), size(xPred,1));
    jHxf(1,:) = [(-delta ./ d)', 0];
    jHxf(2,:) = [delta(2)/d^2, - delta(1) / d^2, -1];
end


