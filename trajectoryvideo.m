
impath = '/Users/sbarnett/Documents/PIVData/fatima/200_D_C1_Phase_20220307_MCF10ARab5A_H2BGFP_uPatterns-01-Scene-04-P5-A01_cr_Results/200_D_20220307_P5_PIV_quiver_image.tif';
info = imfinfo(impath);
numberOfPages = length(info);
imagestack = zeros(686,686,numberOfPages);
for k = 1 : numberOfPages
    % Read the kth image in this multipage tiff file.
    imagestack(:,:,k) = imread(impath, k);
    % Now process thisPage somehow...
end
%%
myVideo = VideoWriter('test_monolayer2.avi');
myVideo.FrameRate = 10;
open(myVideo);
figure('Position',[200,200,800,800])

for i = 2:126-10
    if i < 10
        plot(trajectories(1:i,1:2:end),trajectories(1:i,2:2:end),'LineWidth',2)
        axis([0 63 0 63])
    else
        plot(trajectories(i-9:i,1:2:end),trajectories(i-9:i,2:2:end),'LineWidth',2)
        axis([0 63 0 63])
    end
    pause(0.02)
    frame = getframe(gcf);
    writeVideo(myVideo,frame);
    
end
close(myVideo);