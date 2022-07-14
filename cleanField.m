function [vectorfield] = cleanField(vectorfield)
%Removes unconnected objects in the field ie background. Assumes that
%object of interest is in the middle of the scene.
%   Takes in a vectorfield v[x,y,u,v]

for t = 1:size(vectorfield,3)
    u = reshape(vectorfield(:,3,t),[max(vectorfield(:,1,1))/vectorfield(1,1,1),max(vectorfield(:,1,1))/vectorfield(1,1,1)]);
    %problem is edge pixels
    u(:,1) = 0;
    u(:,end) = 0;
    u(1,:) = 0;
    u(end,:) = 0;
    v = reshape(vectorfield(:,4,t),[max(vectorfield(:,2,1))/vectorfield(1,2,1),max(vectorfield(:,2,1))/vectorfield(1,2,1)]);
    uthresh = abs(u)>0;
    convexhulls = regionprops(uthresh,'ConvexHull');
    pixels = regionprops(uthresh,'PixelIdxList');

    % see if the center is in a particuler convex hull
    c = 1;
    for blob = 1:size(convexhulls,1)
        result = inpolygon(size(u,1)/2,size(u,2)/2,convexhulls(blob).ConvexHull(:,1),convexhulls(blob).ConvexHull(:,2));
        if result == 1;
            break
        end
        c = c+1;
    end
    
    mask = zeros(max(vectorfield(:,1,1))/vectorfield(1,1,1),max(vectorfield(:,2,1))/vectorfield(1,2,1));
    mask(pixels(c).PixelIdxList) = 1;
    
    u = u.*mask;
    v = v.*mask;
    
    vectorfield(:,3,t) = u(:);
    vectorfield(:,4,t) = v(:);

end

end