clear;
clc;
close all;

[num,txt,raw]=xlsread('PaisesA.xls');
save('PaisesA.mat','num','txt','raw')