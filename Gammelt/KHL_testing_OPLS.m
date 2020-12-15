%% EMSC + O-PLS

[r,c,p,n] = size(soppima);
ref = zeros(p,1);
for i=1:n % Felles referanse for alle bilder
    ref = ref + (1/n).*hyspec_mean(soppima(:,:,:,i));
end

% Korriger bilder og legg inn i matrise
X = zeros(0,p);
Y = zeros(0,1);
for i=1:n
    [corrected, parameters, par_names] = hyspec_emsc(soppima(:,:,:,i), 'reference', ref);
    X = [X; reshape(corrected, [r*c,p])];
    Y = [Y; repmat(i,r*c,1)];
end


% Ta et tilfeldig utvalg på alle bilder for å bygge modeller. Korriger alt med disse.
% something random og greier

% Kanskje bruke diff_parameters som en maske som henter ut de delene av
% bildet som blir sopp

utvalg = unidrnd(r*c*n,round(r*c*n/100),1); % 1 prosent av pikslene

[Yhcv, Ycv, gfit, minis, more] = crossvalKHL('cppls', 50, X(utvalg,:), Y(utvalg,:), 'cvseg',10,3, 'condis', {'d'});

[W,P,T,~,~,~,~,ssqx,ssqy] = pls2(12,X(utvalg,:),dummy(Y(utvalg,:)));
[Wc,Pc,Tc] = cppls(10,X,dummy(Y));

[Xortho, Wortho, Tortho, Portho] = O2PLS(12,X(utvalg,:),dummy(Y(utvalg,:)));

Xc = bsxfun(@minus, X, mean(X));
for j=1:size(Wortho,2)
    tno  = Xc*Wortho(:,j)/(Wortho(:,j)'*Wortho(:,j));
    Xc = Xc - tno*Portho(:,j)';
end
Xo = bsxfun(@plus, Xc, mean(X));

[Yhcv, Ycv, gfit, minis, more] = crossvalKHL('cppls', 20, Xo(utvalg,:), Y(utvalg,:), 'cvseg',10,3, 'condis', {'d'});
