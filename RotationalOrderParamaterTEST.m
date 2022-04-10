
%Generate a fake vectorfield for testing
[fieldx,fieldy,fieldu,fieldv] = generateVortex(100,100,0.1);
cx = 50;
cy = 50;

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
ROP = LinearOrderParameter([fieldx(:),fieldy(:),rotationcomponent(:),tangentcomponent(:)])

%%

[fieldx,fieldy,fieldu,fieldv] = generateVortex(100,100,0.1);
ROP = RotationalOrderParameter(fieldx,fieldy,fieldu,fieldv)
