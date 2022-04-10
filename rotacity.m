function [xcomponent,ycomponent] = rotacity(cx,cy,x,y,u,v)
%Calculates the rotational component of a vector field around an origin
%   Detailed explanation goes here
%   cx is the center of the vortex in x
%   cy is the center of the vortex in y
%   x is the x coordinate of the current vector
%   y is the y coordinate of the current vector
%   u is the magnitude of the current vector in x
%   v is the magnitude of the current vector in y

x = x-cx;
y = y-cx;

%Get the angle of the vector relative to the origin of the vortex
theta = rad2deg(atan2(y,x))+180;
fromN = deg2rad(270 - theta);

%Generate rotation matrix to transform vector onto the positive y-axis
rotmat = [cos(fromN),-sin(fromN);sin(fromN),cos(fromN)];

%Normalise the vector
normalised = [u,v]/norm([u,v]);
nu = normalised(1);
nv = normalised(2);

%rotate normalised vector so that it is now relative to positive y-axis
rotnormuv = rotmat*[nu;nv];

%Work out the angle that the rotated vector now points
angle = rad2deg(atan2(rotnormuv(2),rotnormuv(1)))+180;

%Deal with which quadrant the vector now ends up in to calculate x/y
%components

if angle < 90
    xcomponent = -1*(1-angle/90);
    ycomponent = -1-xcomponent;
elseif angle >=90 && angle < 180
    xcomponent = (angle-90)/90;
    ycomponent = -1*(1-xcomponent);
elseif angle >= 180 && angle < 270
    xcomponent = 1-(angle-180)/90;
    ycomponent = 1-xcomponent;
elseif angle > 270
    xcomponent = -1*((angle-270)/90);
    ycomponent = 1-(-1*xcomponent);
end

end

