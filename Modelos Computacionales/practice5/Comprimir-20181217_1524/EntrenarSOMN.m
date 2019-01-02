function [Modelo]=EntrenarSOMN(Muestras,NumFilasMapa,NumColsMapa,NumEtapas)
% Entrenar un modelo SOMN:
% Yin, H. & Allinson, N.M. (2001). 
% Self-Organizing Mixture Networks for Probability Density Estimation, 
% IEEE Transactions on Neural Networks 12 (2), 405-411.
% Versión con gaussianas (matrices de covarianzas completas)

[Dimension,NumMuestras]=size(Muestras);

% Inicializacion
fprintf('Inicializando SOMN')
NumNeuro=NumFilasMapa*NumColsMapa;
Modelo.Pi=(1/NumNeuro)*ones(NumFilasMapa,NumColsMapa);
Modelo.NumColsMapa=NumColsMapa;
Modelo.NumFilasMapa=NumFilasMapa;
Modelo.Dimension=Dimension;
NumPatIni=max([Dimension+1,ceil(NumMuestras/(NumFilasMapa*NumColsMapa))]);

for NdxFila=1:NumFilasMapa
    for NdxCol=1:NumColsMapa
        MisMuestras=Muestras(:,ceil(NumMuestras*rand(1,NumPatIni)));
        Modelo.Medias{NdxFila,NdxCol}=mean(MisMuestras')';        
        Modelo.C{NdxFila,NdxCol}=cov(MisMuestras');      
        Modelo.CInv{NdxFila,NdxCol}=inv(Modelo.C{NdxFila,NdxCol});
        fprintf('.')
    end
end

%Entrenamiento
fprintf('\nEntrenando SOMN\n')
MaxRadio=(NumFilasMapa+NumColsMapa)/8;
for NdxEtapa=1:NumEtapas
    MiMuestra=Muestras(:,ceil(NumMuestras*rand(1)));
    if NdxEtapa<0.5*NumEtapas   
        % Fase de ordenación: caída lineal
        TasaAprendizaje=0.4*(1-NdxEtapa/NumEtapas);
        MiRadio=MaxRadio*(1-(NdxEtapa-1)/NumEtapas);
    else
        % Fase de convergencia: constante
        TasaAprendizaje=0.01;
        MiRadio=0.1;
    end
    
    for NdxNeuro=1:NumNeuro
        VectorDif=MiMuestra-Modelo.Medias{NdxNeuro};
        % Sin constante normalizadora
        Respon(NdxNeuro)=exp(-0.5*log(det(Modelo.C{NdxNeuro}))-0.5*...
            VectorDif'*Modelo.CInv{NdxNeuro}*VectorDif);   
        if ~isfinite(Respon(NdxNeuro))
            Respon(NdxNeuro)=0;
        end
    end
    Suma=sum(Respon);
    if Suma>0
        Respon=Respon/sum(Respon);
    else
        Respon=zeros(1,NumNeuronas);
        disp('Responsabilidades erróneas')
    end
    [Maximo NdxGana]=max(Respon);
    [CoordGana(1) CoordGana(2)]=ind2sub([NumFilasMapa NumColsMapa],NdxGana);
    % Actualizar las neuronas
    for NdxNeuro=1:NumNeuro
        % Distancia topológica
        [MiCoord(1) MiCoord(2)]=ind2sub([NumFilasMapa NumColsMapa],NdxNeuro);
        DistTopol=norm(CoordGana-MiCoord);
        Coef=TasaAprendizaje*exp(-(DistTopol/MiRadio)^2);
        % Actualización de esta neurona
        Modelo.Pi(NdxNeuro)=Coef*Respon(NdxNeuro)+...
            (1-Coef)*Modelo.Pi(NdxNeuro);
        VectorDif=MiMuestra-Modelo.Medias{NdxNeuro};
        Modelo.Medias{NdxNeuro}=Coef*MiMuestra+...
            (1-Coef)*Modelo.Medias{NdxNeuro};            
        Modelo.C{NdxNeuro}=Coef*VectorDif*VectorDif'+...
            (1-Coef)*Modelo.C{NdxNeuro};
        Modelo.CInv{NdxNeuro}=inv(Modelo.C{NdxNeuro});
    end
end

fprintf('Entrenamiento finalizado')

    
    
        
