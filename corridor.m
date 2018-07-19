function []=corridor(MEAN,STD,start,step,stop,color)
% Trace le corridor moyenne +/- ecart type
% mean, std = column vector
% x column vector[0:end,end:-1:0]
% Pour le trace des corridors, permet de faire un aller retour sur le
% graphe
hold on;
x=[start:step:stop stop:-step:start]';
y=[MEAN+STD;MEAN(end:-1:1)-STD(end:-1:1)]; % [Aller;Retour]
A=fill(x,y,color,'LineStyle','none','Facealpha',0.5); % Trace le corridor +/- 1 SD
% set(get(get(A,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Retire surface de la légende
% plot(MEAN,color);
