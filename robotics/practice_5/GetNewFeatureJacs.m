

function [jGz] = GetNewFeatureJacs(Xv, z)
    a = Xv(3) + z(2);
    jGz = [ cos(a), - z(1) * sin(a);
            sin(a), z(1) * cos(a)];
end
