

imagenRGB=imread('Baboon.png');
Comprimida=imread('BaboonSOFM.tif');
error=imagenRGB-Comprimida;
RMS(1)=(sum(sum(double(error(:,:,1)).*double(error(:,:,1))))/262144);
RMS(2)=(sum(sum(double(error(:,:,2)).*double(error(:,:,2))))/262144);
RMS(3)=(sum(sum(double(error(:,:,3)).*double(error(:,:,3))))/262144);
RMSTotal(1)=sqrt(sum(RMS)/3);

imagenRGB=imread('Lena.png');
Comprimida=imread('LenaSOFM.tif');
error=imagenRGB-Comprimida;
RMS(1)=(sum(sum(double(error(:,:,1)).*double(error(:,:,1))))/262144);
RMS(2)=(sum(sum(double(error(:,:,2)).*double(error(:,:,2))))/262144);
RMS(3)=(sum(sum(double(error(:,:,3)).*double(error(:,:,3))))/262144);
RMSTotal(2)=sqrt(sum(RMS)/3);

imagenRGB=imread('Peppers.png');
Comprimida=imread('PeppersSOFM.tif');
error=imagenRGB-Comprimida;
RMS(1)=(sum(sum(double(error(:,:,1)).*double(error(:,:,1))))/262144);
RMS(2)=(sum(sum(double(error(:,:,2)).*double(error(:,:,2))))/262144);
RMS(3)=(sum(sum(double(error(:,:,3)).*double(error(:,:,3))))/262144);
RMSTotal(3)=sqrt(sum(RMS)/3);



RMSTotal

