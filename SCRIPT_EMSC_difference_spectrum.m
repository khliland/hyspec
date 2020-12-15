%% Skript for å estimere differansespektrum mellom sopp og bakgrunn
% for inkludering i EMSC model

load('..\soppima.mat')
I = soppima(:,:,:,1);


%% Velg sopp og bakgrunn  ============== Denne delen kan byttes med hyspec_select =================
figure
imagesc(I(:,:,1))
colormap(gray)
sopp     = impoly(gca);

% ---------- Velg sopp før du kjører videre ---------------
soppMask = find(createMask(sopp));
ikke     = impoly(gca);

% ---------- Velg bakgrunn før du kjører videre -----------
ikkeMask = find(createMask(ikke));


%% Lag differansespektrum
corrected = hyspec_emsc(I);
[r,c,p] = size(I);
sopp_spec = zeros(p,1);
ikke_spec = zeros(p,1);
for i=1:p
    sopp_spec(i) = mean(corrected(soppMask+(i-1)*r*c));
    ikke_spec(i) = mean(corrected(ikkeMask+(i-1)*r*c));
end
diff_spec = sopp_spec-ikke_spec;
[diff_corrected, diff_parameters, diff_par_names] = hyspec_emsc(I,'constituent',diff_spec');


%% Plott parameterbilde for sopp/ikke-differanse i EMSC
imtool(diff_parameters(:,:,5))


%% Lag film av sopp/bakgrunn
F(10) = struct('cdata',[],'colormap',[]);
writerObj = VideoWriter('EMSC_differanseparameter.avi');
writerObj.FrameRate = 1;
open(writerObj);
figure('Renderer','zbuffer')
colormap(gray)
for i=1:10
    [diff_corrected, diff_parameters, diff_par_names] = hyspec_emsc(soppima(:,:,:,i),'constituent',diff_spec');
    imagesc(diff_parameters(:,:,5),[-1,1.4])
    F(i) = getframe;
    writeVideo(writerObj,F(i));
end
movie(F,1,1);shg
close(writerObj);
