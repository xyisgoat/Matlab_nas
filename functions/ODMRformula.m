function [formula,coef] = ODMRformula(pks)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
    formula = [];
    coef = {'b'};
    for i = 1:pks
        C = ['C',num2str(i)];
        w = ['w',num2str(i)];
        X = ['x',num2str(i)];
        formula = [formula,'-2*',C,'*',w,'/(4*((x-',X,')^2+',w,'^2))'];
        coef{end+1} = X;
        coef{end+1} = w;
        coef{end+1} = C;
    end
    formula = [formula,'+b'];
end

