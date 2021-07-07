function [C,W,FWHM,D,B,R,yft,gof,formula_out,D_confint] = ODMRFit(pks,fitf,fitdata)
%UNTITLED10 此处显示有关此函数的摘要
%   此处显示详细说明
%Parameters for fit control
    Para_D = fitf(find(fitdata == min(fitdata)));
    Para_W = 5;
    Para_B = mean(fitdata);
    Para_C = 0.05;
    
    %fit
    if pks == 1
        [formula,coef] = ODMRformula(1);
        ft1 = fittype(formula,'independent','x','coefficient',coef) ;
        formula_out = formula;
        [yft,gof] = fit(fitf',fitdata',ft1,...
        'StartPoint',[Para_B,Para_D,Para_W,Para_C]);
        R = gof.rsquare;        
        B = yft.b;D = yft.x1; W = yft.w1; C = yft.C1;
        FWHM = 2 * W;
        yft_confint = confint(yft,0.95);
        D_confint = (max(yft_confint(:,2)')-min(yft_confint(:,2)'))*0.5;
        fprintf(sprintf('D = %.6f ± %.6f MHz\n',mean(D),D_confint));
    end

    if pks == 2
        [formula,coef] = ODMRformula(2);
        ft2 = fittype(formula,'independent','x','coefficient',coef) ;
        formula_out = formula;
        [yft1,gof1] = fit(fitf',fitdata',ft2,...
        'StartPoint',[Para_B,Para_D,Para_W,Para_C,Para_D + 8,Para_W,Para_C]);
        [yft2,gof2] = fit(fitf',fitdata',ft2,...
        'StartPoint',[Para_B,Para_D,Para_W,Para_C,Para_D - 8,Para_W,Para_C]);
        R1 = gof1.rsquare; R2 = gof2.rsquare;

        if R1 <= R2
            yft = yft2;
            R = R2;
            gof = gof2;
        else
            yft = yft1;
            R = R1;
            gof = gof1;
        end

        B = yft.b;D(1) = yft.x1;W(1) = yft.w1;C(1) = yft.C1;
        D(2) = yft.x2; W(2) = yft.w2;C(2) = yft.C2;

        syms x
        fwhm = 0.5 * abs(max(C)-2*C(1)*W(1)/(4*((D(1))^2+W(1)^2))-2*C(2)*W(2)/(4*(D(2)^2+W(2)^2)) + B);
        eqn = -2*C(1)*W(1)/(4*((x-D(1))^2+W(1)^2))-2*C(2)*W(2)/(4*((x-D(2))^2+W(2)^2)) + B == fwhm;
        S = solve(eqn,x);
        result = double(S);
        FWHM = abs(result(1)-result(2));
        yft_confint = confint(yft,0.95);
        D_confint = (max(yft_confint(:,2)')-min(yft_confint(:,2)'))*0.5;
        fprintf(sprintf('D = %.6f ± %.6f MHz\n',mean(D),D_confint));
    end
end

