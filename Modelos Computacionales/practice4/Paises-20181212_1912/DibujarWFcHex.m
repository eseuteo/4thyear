function DibujarWFcHex(FC)
clf
l=sqrt(3)/sqrt(6.75);
for x=1:FC(1)
    for y=1:2:FC(2)
        plot([x-0.5 x-0.5],[y-l/2 y+l/2],'-r');hold on;
        plot([x+0.5 x+0.5],[y-l/2 y+l/2],'-r');hold on;
        plot([x x+0.5],[y+l y+l/2],'-r');hold on;
        plot([x-0.5 x],[y+l/2 y+l],'-r');hold on;
        plot([x x+0.5],[y-l y-l/2],'-r');hold on;
        plot([x-0.5 x],[y-l/2 y-l],'-r');hold on;
    end
end
for x=1:FC(1)
    for y=2:2:FC(2)
        plot([x x],             [y-l/2 y+l/2],'-r');hold on;
        plot([x+1 x+1],    [y-l/2 y+l/2],'-r');hold on;
        plot([x+0.5 x+1], [y+l y+l/2],'-r');hold on;
        plot([x x+0.5],      [y+l/2 y+l],'-r');hold on;
        plot([x+0.5 x+1], [y-l y-l/2],'-r');hold on;
        plot([x x+0.5],      [y-l/2 y-l],'-r');hold on;
    end
end
axis([0 FC(1)+1.5 0 FC(2)+1])  