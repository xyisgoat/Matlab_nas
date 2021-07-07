function [] = FigureFormat(labelx,labely,Title)
%UNTITLED7 此处显示有关此函数的摘要
%   此处显示详细说明
set(gca,'linewidth',1,'fontsize',20,'fontname','Arial',...
    'Position',[0.13,0.3,0.6,0.6],'Box','On','LineWidth',1);
xlabel(labelx,'Fontname','Arial','FontSize',20);
ylabel(labely,'Fontname','Arial','FontSize',20);
title(Title)
end

