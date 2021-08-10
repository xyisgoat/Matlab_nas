function [aveg2] = G2traceCalc(Image,sumImage,tau_range)
%author: XY
%本代码用于计算g2-t
g2 = [];
[x0,y0] = find(sumImage.photon == max(max(sumImage.photon)));
tau_min = -tau_range;tau_max = tau_range;
ni = reshape(Image.photon(x0,y0,:),1,[]);
for xaxis = -1:1
    for yaxis = -1:1
        if xaxis == 0 && yaxis == 0
            continue
        end
        tempni = []; tempnk = [];
        nk = reshape(Image.photon(x0+xaxis,y0+yaxis,:),1,[]);        
       %% 计算 aveni, avenk
        aveni = mean(ni);
        avenk = mean(nk);       
        %% 计算 sum(ni(t) * nk(t + tau))
        %将nk矩阵进行延迟
        tempnk = repmat(nk,(tau_max - tau_min + 1),1);
        m = size(tempnk,1);
        tempnk = [tempnk';zeros(m)];
        tempnk = reshape(tempnk(1:end-m),[],m)';
        
        %将ni矩阵用0补齐长度
        tempni = zeros(length(tempnk),1);
        tempni(tau_range+1:length(ni) + tau_range) = ni;
        sumnink = sum(tempni'.*tempnk,2);
        
        %计算ni*nk的平均值
        l = length(ni);
        l_nink = [[l-tau_range:1:l],[l-1:-1:l- tau_range]];
        avenink = sumnink./l_nink';        
        %% 计算 g2trace
        g2 = [g2,avenink/(aveni * avenk)];
    end
end
    aveg2 = mean(g2,2);
end

