function [outputArg1,outputArg2] = Linevideo(tj,filename,tjlength)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
myVideo = VideoWriter(filename);
myVideo.FrameRate = 10;
open(myVideo);
figure('Position',[200,200,800,800])

maxspeed = 0.2;
cmap = jet(36);
for i = 1:size(tj,1)-tjlength
    if i < tjlength
        distx = diff(tj(1:i,1:2:end)).^2;
        distx(isnan(distx)) = 0;
        disty = diff(tj(1:i,2:2:end)).^2;
        disty(isnan(disty)) = 0;
        col = sum(distx+disty,1)./i;
        colpos = round(col./maxspeed.*36)+1;
        colpos(colpos>256) = 36;
        for j = 1:36
            idx = find(colpos==j);
            toplotx = tj(:,idx.*2-1);
            toploty = tj(:,idx.*2);
            plot(toplotx(1:i,:),toploty(1:i,:),'Color',cmap(j,:),'LineWidth',2)
            hold on
        end
        hold off
        %plot(tj(1:i,1:2:end),tj(1:i,2:2:end))
        axis([0 max(tj(1,:)) 0 max(tj(1,:))])
    else
        distx = diff(tj(i-9:i,1:2:end)).^2;
        distx(isnan(distx)) = 0;
        disty = diff(tj(i-9:i,2:2:end)).^2;
        disty(isnan(disty)) = 0;
        col = sum(distx+disty,1)./10;
        colpos = round(col./maxspeed.*36)+1;
        colpos(colpos>36) = 36;
        for j = 1:36
            idx = find(colpos==j);
            toplotx = tj(:,idx.*2-1);
            toploty = tj(:,idx.*2);
            plot(toplotx(i-(tjlength-1):i,:),toploty(i-(tjlength-1):i,:),'Color',cmap(j,:),'LineWidth',2)
            hold on
        end
        hold off
        %plot(tj(i-9:i,1:2:end),tj(i-9:i,2:2:end))
        axis([0 max(tj(1,:)) 0 max(tj(1,:))])
    end
    pause(0.02) 
    frame = getframe(gcf);
    writeVideo(myVideo,frame);
end
close(myVideo);
end

