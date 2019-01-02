function Vecindad = FuncionVecindadC(IndGan, i, Indices)
    dist = Indices - IndGan;
    dist = dist .^ 2;
    dist = sum(dist);
    dist = sqrt(dist);
    Vecindad = exp(-dist);
end



