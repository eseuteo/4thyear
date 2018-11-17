function error = get_error(W, Data)
    patterns = Data(:, 1:2);
    % No empleamos la función signo
    outputs = patterns * W(1:2) - W(3);
    error = 1/2 * sum(Data(3) - outputs)^2;
end