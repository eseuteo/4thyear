function final_W = ModificarPesosLotes(W,Ys,Data,LR)
    final_W = W;
    for i = 1:size(W,2)
        ans_W = W(:,i);
        delta_W = (Data' - ans_W)';
        delta_W = delta_W(Ys(:,i),:);
        delta_W = mean(delta_W) * LR;
        final_W(:,i) = W(:,i) + delta_W';
    end
end

