%% Showcase
% Noen eksempler på bruk av hyspec-metodene


%% Sopp
load('..\soppima.mat')
I = soppima(:,:,:,10);

M1  = hyspec_snv(soppima(:,:,:,1));
M10 = hyspec_snv(soppima(:,:,:,10));
[means, specs, which] = hyspec_select(M1);
[corrected, parameters, par_names, model] = hyspec_emsc(M,'terms',2);

[means, specs, which] = hyspec_select(M1);
vann = means(1,:);
[corrected, parameters, par_names, model] = hyspec_emsc(M,'terms',2,'interferent',vann);
[means, specs, which] = hyspec_select(parameters);
[means, specs, which] = hyspec_select(corrected);
% [corrected, parameters, par_names, model] = hyspec_emsc(M,'terms',2,'reference',sopt(1,:),'constituent',sopt(2,:));


%% Farse
[data, xAxis, yAxis, zAxis, misc] = fsmload('..\farse\farse1.fsm');

% Mean spectrum
mean = hyspec_mean(data);
figure;plot(zAxis,mean)

% Original spectra
hyspec_select(data,zAxis);

% -log10
data2 = -log10(data);

% 2nd derivative
M = hyspec_derivative(data2,2,'points', 11);

% EMSC
[corrected, parameters, par_names, model] = hyspec_emsc(M);

% Velge fett og proteiner
[fettProtein, specsFP, whichFP] = hyspec_select(corrected,zAxis);

% EMSC med fett og protein som konstituent og referanse
[correctedFP, parametersFP, par_namesFP, modelFP] = hyspec_emsc(M,'constituent',fettProtein(1,:),'reference',fettProtein(2,:));
[means, specs, which] = hyspec_select(parametersFP);

% Plotte protein og fett som rødt og grønt
rgbi = parametersFP(:,:,[2,5]);
rgbi(:,:,3) = zeros(size(parametersFP(:,:,1)));
for i=1:2
    rgbi(:,:,i) = rgbi(:,:,i)-min(min(rgbi(:,:,i)));
    rgbi(:,:,i) = rgbi(:,:,i)./max(max(rgbi(:,:,i)));
end
figure
image(rgbi)

% X = reshape(corrected, [160*128,1626]);
% Y = [reshape(parametersFP(:,:,2),[160*128,1]) reshape(parametersFP(:,:,5),[160*128,1])];
% [Yhcv, Ycv, gfit, minis, more] = crossvalKHL('pls2', 10, X, Y, 'cvseg',10,3);
% 
% [W,P,T,~,~,~,~,ssqx,ssqy] = pls2(18,X,Y);
% [Wc,Pc,Tc] = cppls(10,X,dummy(Y));
% 
% [Xortho, Wortho, Tortho, Portho] = O2PLS(18,X,Y);
