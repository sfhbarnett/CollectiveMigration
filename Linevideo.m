function [] = Linevideo(tj,filename,tjlength,images)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin == 3
    im = 0;
else
    im = 1;
end

myVideo = VideoWriter(filename);
myVideo.FrameRate = 10;
open(myVideo);
figure('Position',[200,200,800,800])
%change thickness
linewidth = 2;

maxspeed = 0.2;
ncol = 100;
cmap = jet(ncol);
for i = 1:size(tj,1)-tjlength
    if im
        imagesc(images(:,:,i))
        colormap('gray')
        hold on
    end
    if i < tjlength
        distx = diff(tj(1:i,1:2:end)).^2;
        distx(isnan(distx)) = 0;
        disty = diff(tj(1:i,2:2:end)).^2;
        disty(isnan(disty)) = 0;
        col = sum(distx+disty,1)./i;
        colpos = round(col./maxspeed.*36)+1;
        colpos(colpos>256) = ncol;
        for j = 1:ncol
            idx = find(colpos==j);
            toplotx = tj(:,idx.*2-1);
            toploty = tj(:,idx.*2);
            plot(toplotx(1:i,:).*16,toploty(1:i,:).*16,'Color',cmap(j,:),'LineWidth',linewidth)
            hold on
        end
        hold off
        %plot(tj(1:i,1:2:end),tj(1:i,2:2:end))
        axis([0 max(tj(1,:).*16) 0 max(tj(1,:).*16)])
    else
        distx = diff(tj(i-9:i,1:2:end)).^2;
        distx(isnan(distx)) = 0;
        disty = diff(tj(i-9:i,2:2:end)).^2;
        disty(isnan(disty)) = 0;
        col = sum(distx+disty,1)./10;
        colpos = round(col./maxspeed.*ncol)+1;
        colpos(colpos>ncol) = ncol;
        for j = 1:ncol
            idx = find(colpos==j);
            toplotx = tj(:,idx.*2-1);
            toploty = tj(:,idx.*2);
            plot(toplotx(i-(tjlength-1):i,:).*16,toploty(i-(tjlength-1):i,:).*16,'Color',cmap(j,:),'LineWidth',linewidth)
            hold on
        end
        hold off
        %plot(tj(i-9:i,1:2:end),tj(i-9:i,2:2:end))
        axis([0 max(tj(1,:).*16) 0 max(tj(1,:).*16)])
    end
    frame = getframe(gcf);
    writeVideo(myVideo,frame);
end
close(myVideo);
end

