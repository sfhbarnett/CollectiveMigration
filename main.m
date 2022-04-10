

path = '/Volumes/Sam_MBI_data/200_D_C1_Phase_20220307_MCF10ARab5A_H2BGFP_uPatterns-01-Scene-04-P5-A01_cr_Results/PIV_roi_velocity_text/';
files = dir(path);

names = {};
for i=1:128
    test = files(i).name
    names{i} = files(i).name;
end
filessort = natsort(names).';

vectorfield = csvread(fullfile(files(3).folder,files(3).name));
cx = max(vectorfield(:,1)/vectorfield(1,1))/2;
cy = max(vectorfield(:,2)/vectorfield(1,2))/2;

rotationcomponent = NaN(cx*2,cy*2,size(files,1)-2);
tangentcomponent = NaN(cx*2,cy*2,size(files,1)-2);

for f = 3:size(files)
    f
    vectorfield = csvread(fullfile(files(f).folder,filessort{f}));
    for i = 1:size(vectorfield(:,1))
        x = vectorfield(i,1)/vectorfield(1,1);
        y = vectorfield(i,2)/vectorfield(1,2);
        u = vectorfield(i,3);
        v = vectorfield(i,4);
        if or(u~=0, v~=0)
            [xcomponent, ycomponent] = rotacity(cx,cy,x,y,u,v);
            rotationcomponent(x,y,f-2) = xcomponent;
            tangentcomponent(x,y,f-2) = ycomponent;
        else
            tangentcomponent(x,y,f-2) = NaN;
        end

    end
end

%%
% This will create a little animation of the data with the vector field on
% top
figure
imAlpha=ones(size(rotationcomponent(:,:,1)));
for i = 1:126
    vectorfield = csvread(fullfile(files(i).folder,filessort{i+2}));
    hold off
    imAlpha(isnan(rotationcomponent(:,:,i)))=0;
    imagesc(rotationcomponent(:,:,i)', 'AlphaData',imAlpha,[-1,1]);
    hold on
    quiver(vectorfield(:,1)./16,vectorfield(:,2)./16,vectorfield(:,3),vectorfield(:,4),5);
    axis equal tight
    title(i)
    pause(0.3)
end
%set(gca,'color',0*[1 1 1]);

%%
%Calculates the mean rotational and mean tangential components for each
%timepoint
m = [];
for i = 1:126
    imrot = rotationcomponent(:,:,i);
    meanrot(i) = mean(imrot(:),'omitnan');
    imtan = tangentcomponent(:,:,i);
    meantan(i) = mean(imtan(:),'omitnan');
end
%%
%Plots mean rotation and a sample of images.
figure
plot(meanrot)
figure
imagesc(abs(rotationcomponent(:,:,46)),[-1 1])
title("Clockwise rotation (Absolute)")
figure
imagesc(rotationcomponent(:,:,46),[-1 1])
title("Clockwise rotation")
figure
imagesc(abs(rotationcomponent(:,:,112)),[-1 1])
title("Anticlockwise rotation (Absolute)")
figure
imagesc(rotationcomponent(:,:,112),[-1 1])
title("Anticlockwise rotation")

%%
%Order component

order = zeros(size(rotationcomponent,3));
for f = 1:size(rotationcomponent,3)
    u = rotationcomponent(f)
    v = tangentcomponent(f)
    meanu = mean(u(:));
    meanv = mean(v(:));
    mean_v2=mean(mean(u(:).^2+v(:).^2));
    mean_abs_v=mean(mean(sqrt(u(:).^2+v(:).^2)));

    order(f) = (meanu.^2+meanv.^2)./(mean_v2);
end
