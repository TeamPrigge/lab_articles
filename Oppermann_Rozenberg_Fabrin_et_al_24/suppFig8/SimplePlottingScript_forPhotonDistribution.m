close all

M = [fliplr(frac_trans) frac_trans];
figure;imagesc(log10(M), 'AlphaData', ~isnan(M));

border5 = round(M,2)==0.5;
border1 = round(M,3)==0.1;
border05 = round(M,3)==0.05;
border01 = round(M,4)==0.01;
border005 = round(M,4)==0.005;
border001 = round(M,5)==0.001;
border0005 = round(M,5)==0.0005;
border0001 = round(M,6)==0.0001;


overall635 = [border5 |  border1 | border05 | border01 | border005 | border001 | border0005 | border0001];

figure;contour(overall635);

colormap([1 1 1; 0 0 0])
set(gca, 'Color', 'none')
%print(fig, 'myMatrixPlot.svg', '-dsvg', '-r300', '-painters', 'BackgroundColor', 'none');


