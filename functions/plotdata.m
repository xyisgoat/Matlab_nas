function [] = plotdata(x,y,labelx,labely)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
h1 = figure;
set(h1,'unit','pixels','position',[0 0 1200 900],'Color',[1,1,1]);
plot(x,y,'Marker','.','MarkerSize',20);
set(gca,'linewidth',1,'fontsize',20,'fontname','Arial',...
    'Position',[0.13,0.3,0.6,0.6],'Box','On','LineWidth',1);
xlabel(labelx,'Fontname','Arial','FontSize',20);
ylabel(labely,'Fontname','Arial','FontSize',20);
legend('Data','Lorentz fit','Box','Off');
end

