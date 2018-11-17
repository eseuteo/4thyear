function correct_patterns = CountPocket(Data, W)
    % Muy similar a CheckPattern, pero usando sum
    % (para contar elementos correctos)
    patterns = Data(:, 1:2);
    outputs = sign(patterns * W(1:2) - W(3));
    comparison = outputs == Data(:, 3);
    correct_patterns = sum(comparison);
