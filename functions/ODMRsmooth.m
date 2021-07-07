function [fitdata] = ODMRsmooth(cycnum,avetemp,smoothswitch)
%UNTITLED12 此处显示有关此函数的摘要
%   此处显示详细说明
    switch smoothswitch
        case 'on'
            fitdata = smooth(avetemp,floor(length(avetemp)/4),'loess')';
        case 'off'
            if cycnum == 1
                fitdata = avetemp';
            else
                fitdata = avetemp;
            end
        otherwise
            fprintf('Wrong input in smoothswitch');
    end
end

