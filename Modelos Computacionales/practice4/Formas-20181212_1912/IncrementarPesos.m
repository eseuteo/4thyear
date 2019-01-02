function new_W = IncrementarPesos(W, Patron, Vecindad, eta)
    delta_W = eta * Vecindad;
    delta_W = delta_W .* (Patron - W);
    new_W = W + delta_W;
end

