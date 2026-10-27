function CheckboardFcn(check,Ch)
%creates the checkboard.

%check=(traces,block,Ch)
checkboard=check(:,:,Ch);

h=figure;
imagesc(checkboard);
colormap gray;
caxis([-1 1]);
hold on;
%creates the lines:
posUD = 0.5:size(checkboard,2)+0.5;
posLR = 0.5:size(checkboard,1)+0.5;
[X,Y] = meshgrid(posUD,posLR);
plot(X,Y,'k-','linewidth',1);
plot(X',Y','k-','linewidth',1);

set(gcf,'MenuBar','none');
set(gcf,'Position',[100 135 1740 384]);
xlabel('Blocks');
ylabel('Trials');
xticks(1:size(check,2));
yticks(1:size(check,1));


end