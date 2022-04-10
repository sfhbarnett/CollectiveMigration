function [fieldx,fieldy,fieldu,fieldv] = generateVortex(sX,sY,randomness)
%Generates a vectorfield with a vortex centred in the middle
%   INPUTS:
%   sX - size of field in X
%   sY - size of field in Y
%   randomness - adds variability to the vectors heading with 0 being a
%   perfect fortex and 1 being perfectly random
%   O:
%   x - sX by sY matrix of the x coordinates
%   y - sX by sY matrix of the y coordinates
%   fieldu - sX by sY matrix of the u coordinates
%   fieldv - sX by sY matrix of the v coordinates

fieldu = zeros(sX,sY);
fieldv = zeros(sX,sY);
cx = sX/2;
cy = sY/2;

for i = 1:sX
    for j = 1:sY
        x = i-cx;
        y = j-cy;
        theta = rad2deg(atan2(y,x))-180+rand*randomness*360;
        u = sin(deg2rad(theta+90));
        v = cos(deg2rad(theta+90));
        fieldu(i,j) = u;
        fieldv(i,j) = v;
    end
end
[x,y] = meshgrid(1:sX,1:sY);
fieldx = x(:);
fieldy = y(:);
fieldu = fieldu(:);
fieldv = fieldv(:);

end

