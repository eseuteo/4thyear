function EscribirCiudades(Ganadoras,FC,txt)

Ciudades=txt(2:end,2);
NumDatos=length(Ganadoras);
for i=1:FC(1)
    for j=1:2:FC(2)
        A=repmat([i j],NumDatos,1);
        indCiu=find(sum(Ganadoras==A,2)==2);
        B=Ciudades(indCiu);
        lon=length(B);
        if lon<=3
            text(i-0.5,j,B)
        elseif lon<=8
            text(i-0.5,j,B(1:3,:));
            text(i-0.1,j,B(4:end,:));
        elseif lon<=13
            text(i-0.5,j,B(1:3,:));
            text(i-0.2,j,B(4:8,:));
            text(i+0.1,j,B(9:end,:));
            
        elseif lon<=16
            text(i-0.5, j,B(1:3,:));
            text(i-0.25, j, B(4:8,:));
            text(i, j, B(9:13,:));
            text(i+0.25, j, B(13:end,:));
        else
            text(i-0.5, j,B(1:4,:));
            text(i-0.25, j, B(5:10,:));
            text(i, j, B(11:15,:));
            text(i+0.25, j, B(16:end,:));
        end
    end
end




for i=1:1:FC(1)
    for j=2:2:FC(2)
        A=repmat([i j],NumDatos,1);
        indCiu=find(sum(Ganadoras==A,2)==2);
        B=Ciudades(indCiu);
        lon=length(B);
        if lon<=3
            text(i,j,B)
        elseif lon<=8
            text(i,j,B(1:3,:));
            text(i+0.4,j,B(4:end,:));
        elseif lon<=13
            text(i,j,B(1:3,:));
            text(i+0.3,j,B(4:8,:));
            text(i+6,j,B(9:end,:));
            
        elseif lon<=16
            text(i, j,B(1:3,:));
            text(i+0.25, j, B(4:8,:));
            text(i+0.5, j, B(9:13,:));
            text(i+0.75, j, B(13:end,:));
        else
            text(i-0.5, j,B(1:4,:));
            text(i-0.25, j, B(5:10,:));
            text(i, j, B(11:15,:));
            text(i+0.25, j, B(16:end,:));
%             text(i+0.38, j, B(22:end,:));
        end
    end
end