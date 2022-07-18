function [cx,cy] = findCentreDIC(image)
%Finds the center of a circularly monolayer of cells. Takes a DIC image as
%an imput and outputs cx and cy, the centre of the monolayer. 



imagemean = mean(image(:));
imagesub = image-imagemean;
minvalx = min(smooth(std(double(abs(imagesub)),[],1)));
minvaly = min(smooth(std(double(abs(imagesub)),[],2)));

xstd = smooth(std(double(abs(imagesub)),[],1))-minvalx;
ystd = smooth(std(double(abs(imagesub)),[],2))-minvaly;

meanbgx = mean([xstd(5:15);xstd(end-15:end-5)]);
meanbgy = mean([ystd(5:15);ystd(end-15:end-5)]);

[maxx,indxl] = max(xstd);

while maxx > 2 * meanbgx
    maxx = xstd(indxl-1);
    indxl = indxl-1;
end

[maxx,indxr] = max(xstd);

while maxx > 2 * meanbgx
    maxx = xstd(indxr+1);
    indxr = indxr+1;
end

[maxy,indyl] = max(ystd);

while maxy > 2 * meanbgy
    maxy = ystd(indyl-1);
    indyl = indyl-1;
end

[maxy,indyr] = max(ystd);

while maxy > 2 * meanbgy
    maxy = ystd(indyr+1);
    indyr = indyr+1;
end

cx = (indxr+indxl)/2;
cy = (indyr+indyl)/2;

end

