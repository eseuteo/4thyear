function Indices=GenerarIndicesHex(FC)
Indices=zeros(2,FC(1),FC(2));
dy = sqrt(3) / 2;
for x=1:FC(1)
    for y=1:FC(2)
        current_x = ~mod(y, 2) * 0.5 + x;
        current_y = y * dy;
        Indices(:,x,y)=[current_x, current_y];
    end
end