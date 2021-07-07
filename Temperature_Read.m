clc,clear,close all
%%
cd 'E:\XY\Data\20210707'
%%
prefix = ['ReceivedTofile-COM6-2021_7_7_1-22-28'];
suffix = ['.DAT'];
filename = [prefix,suffix];
f = fopen(filename);
a = fread(f);
a_hex = dec2hex(a);
% a_hex = ['00';a_hex];
for n = 1:length(a_hex)
    data_reshape{n} = a_hex(n,:);
end

% if rem(length(data_reshape),7) ~= 0
%     data_reshape(end-rem(length(data_reshape),7)+1:end,:) = [];
% end
data_reshape = reshape(data_reshape,7,[]);
for i = 1:length(data_reshape)
    temp1 = num2str(data_reshape{4,i});
    temp2 = num2str(data_reshape{5,i});
    T(i) = hex2dec([temp1,temp2])/10;
end
% T = T-T(1);
%%
h1 = figure;
set(h1,'unit','pixels','position',[0 0 1200 900],'color',[1,1,1]);  

plot([1:length(T)]/60,T,'LineWidth',1)
FigureFormat('Time (min)', 'Temp. (Celsius degree)',['Logged Temperature'])

fclose(f);