function [ROP] = RotationalOrderParameter(vectorfield,cx,cy)
%Calculates the rotational order parameter
%   Takes as inpuy an mx4 matrix representing a vectorfield with columens
%   x, y, u, v
%   Output is the rotational order parameter where 0 indicates no
%   rotational order and 1 equals perfect rotational order

fieldx = vectorfield(:,1)./vectorfield(1,1);
fieldy = vectorfield(:,2)./vectorfield(1,2);
fieldu = vectorfield(:,3);
fieldv = vectorfield(:,4);

%assumes rotation relative to center of field
% cx = max(fieldx)/2;
% cy = max(fieldy)/2;

%Reserve space in memory
rotationcomponent = NaN(sqrt(size(fieldx,1)),sqrt(size(fieldx,1)));
tangentcomponent = NaN(sqrt(size(fieldx,1)),sqrt(size(fieldx,1)));

for i = 1:size(fieldx,1)
    %Calculate the rotational and tangent components for each vector
    x = fieldx(i);
    y = fieldy(i);
    u = fieldu(i);
    v = fieldv(i);
    if or(u~=0, v~=0)
        [xcomponent, ycomponent] = rotacity(cx,cy,x,y,u,v);
        rotationcomponent(x,y) = xcomponent;
        tangentcomponent(x,y) = ycomponent;
    else
        tangentcomponent(x,y) = NaN;
    end
end
%This is actually the rotational order parameter now but we have
%transformed the rotation into linear space
ROP = LinearOrderParameter([fieldx(:),fieldy(:),rotationcomponent(:),tangentcomponent(:)]);
end

