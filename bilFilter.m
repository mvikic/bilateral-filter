%    bfilt_slika = bilFilter(img,w,sigma_s,sigma_r) funkcija koja vrsi
%    2-D bilateralnu filtraciju
%    slike sive skale img.
%    img bi trebalo da je double matrica velicine NxMx1
%    normalizovanih vrijednosti u intervalu [0,1].
%    w predstavlja polovinu prozora bilateralnog filtra.
%    Standardne devijacije bilateralnog filtra date su sa sigma_s i sigma_r.
%    sigma_s predstavlja standardnu devijaciju u prostornom
%    domenu a u amplitudskom domenu standardna devijacija je data sa sigma_r.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Funkcija koja implementira bilateralni filter za slike sive skale.
% Izlaz funkcije je filtrirana slika bfilt_slika. 

function bfilt_slika = bilFilter(img,agr)
w = 5;
sigma_s = round(agr * 20);
sigma_r = agr;
% skalirati sve parametre na osnovu jednog ulaznog
img_d = double(imread(img))/255;
w_str = num2str(w);
sigma_s_str = num2str(sigma_s);
sigma_r_str = num2str(sigma_r);

% Ra?unanje te?inskog faktora na osnovu prostorne bliskosti piksela
% Prostorni filter
[X,Y] = meshgrid(-w:w,-w:w);
G = exp(-(X.^2+Y.^2)/(2*sigma_s^2));

% Kreiranje linije progresa.
h = waitbar(0,'Primjenjuje se filtriranje bilateralnim filtrom...');
set(h,'Name','Molim sacekajte');

% Primjena bilateralnog filtra.
dim = size(img_d);
bfilt_slika = zeros(dim);
for i = 1:dim(1)
   for j = 1:dim(2)
      
         % Izvlacenje lokalnih regiona.
         iMin = max(i-w,1);
         iMax = min(i+w,dim(1));
         jMin = max(j-w,1);
         jMax = min(j+w,dim(2));
         I = img_d(iMin:iMax,jMin:jMax);
      
         % Ra?unanje te?inskog faktora na osnovu vrijednosti signala
         % Filter signala
         H = exp(-(I-img_d(i,j)).^2/(2*sigma_r^2));
      
         % Ra?unanje odziva bilateralnog filtra
         F = H.*G((iMin:iMax)-i+w+1,(jMin:jMax)-j+w+1);
         bfilt_slika(i,j) = sum(F(:).*I(:))/sum(F(:));
               
   end
   waitbar(i/dim(1));
end

% Kraj linije progresa.
close(h);

slika_razlika = img_d - bfilt_slika;

% Prikaz ulazne slike sive skale i izlazne filtrirane kao i njihove razlike
figure(1); clf;
set(gcf,'Name','Rezultat bilateralne filtracije slike sive skale');
subplot(1,3,1); imagesc(img_d);
axis image; colormap gray;
title('Ulazna slika');
subplot(1,3,2); imagesc(bfilt_slika);
axis image; colormap gray;
title('Slika nakon bilateralne filtracije');
subplot(1,3,3); imagesc(slika_razlika);
axis image; colormap gray;
title('Razlika ulazne i filtrirane');

% Cuvanje
z = [w_str '_' sigma_s_str '_' sigma_r_str '_' img];
imwrite(bfilt_slika, z)