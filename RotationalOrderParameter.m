function [ROP,TOP] = RotationalOrderParameter(vectorfield,cx,cy)
%Calculates the rotational order parameter
%   Takes as inpuy an mx4 matrix representing a vectorfield with columens
%   x, y, u, v
%   Output is the rotational order parameter where 0 indicates no
%   rotational order and 1 equals perfect rotational order
%   TOP is for tangential motion
%   god I hate rotation

fieldx = vectorfield(:,1)./vectorfield(1,1);
fieldy = vectorfield(:,2)./vectorfield(1,2);
fieldu = vectorfield(:,3);
fieldv = vectorfield(:,4);
fieldu = reshape(fieldu,[max(fieldx),max(fieldy)]);
fieldu(cx,cy) = 0;
fieldu = fieldu(:);
fieldv = reshape(fieldv,[max(fieldx),max(fieldy)]);
fieldv(cx,cy) = 0;
fieldv = fieldv(:);

[rotationcomponent,tangentcomponent] = LinearizeFieldScaled([fieldx,fieldy,fieldu,fieldv],cx,cy);
rotationcomponent = round(rotationcomponent,5);
tangentcomponent = round(tangentcomponent,5);
meanu = mean(rotationcomponent(:),'omitnan');
meanu2 = mean(mean(rotationcomponent.^2,'omitnan'),'omitnan');
mean_uv2=mean(mean(rotationcomponent.^2+tangentcomponent.^2,'omitnan'),'omitnan');
ROP = meanu.^2/mean_uv2;
meanv = mean(tangentcomponent(:),'omitnan');
meanv2 = mean(mean(tangentcomponent.^2,'omitnan'),'omitnan');
TOP = meanv.^2/mean_uv2;

mean_v2=mean(mean(rotationcomponent.^2+tangentcomponent.^2,'omitnan'),'omitnan');
if isnan(ROP)
    ROP = 0;
end
if isnan(TOP)
    TOP = 0;
end
%ROP = mean(trianglesin(rad2deg(theta)+180),'omitnan');
%ROP = abs(mean((deg2rad(90)-abs(theta-deg2rad(90)))/deg2rad(90),'omitnan'));

end

