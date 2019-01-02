function DibujarWFc(FC)
clf
for x=1:FC(1)+1
    for y=1:FC(2)
        plot([x x],[y y+1],'-r');hold on;
    end
end
for x=1:FC(1)
    for y=1:FC(2)+1
        plot([x x+1],[y y],'-r');hold on;
    end
end  