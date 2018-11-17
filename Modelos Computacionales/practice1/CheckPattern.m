% Mirar si todos los patrones están bien clasificados
function all_patterns = CheckPattern(Data, W)
    % Para evitar el uso de bucles empleo la función all
    % con la comparación las salidas con los objetivos:
    % Tomo los patrones de entrada
    patterns = Data(:, 1:2);
    % Calculo las salidas 
    outputs = sign(patterns * W(1:2) - W(3));
    % Comparo salidas y objetivos
    comparison = outputs == Data(:, 3);
    % And lógico de las comparaciones anteriores
    % (Se cumple si todos son true)
    all_patterns = all(comparison);
end