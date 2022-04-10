function [ROP] = RotationalOrderParameter(vectorfield)
%Calculates the rotational order parameter
%   Takes as inpuy an mx4 matrix representing a vectorfield with columens
%   x, y, u, v
%   Output is the rotational order parameter where 0 indicates no
%   rotational order and 1 equals perfect rotational order

fieldx = vectorfield(:,1);
fieldy = vectorfield(:,2);
fieldu = vectorfield(:,3);
fieldv = vectorfield(:,4);

cx = max(fieldx)/2;
cy = max(fieldy)/2;

rotationcomponent = NaN(cx*2,cy*2);
tangentcomponent = NaN(cx*2,cy*2);

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

