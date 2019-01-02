function Ganadoras = CompeticionSOFM(Model, Muestras)
    Ganadoras = zeros(1, size(Muestras, 2));
    for i=1:size(Muestras, 2)
        pixel = Muestras(:, i);
        distances = pixel - Model.Medias;
        distances = squeeze(sqrt(sum(distances.^2)));
        [~, I] = min(distances(:));
        Ganadoras(i) = I;
    end
end

