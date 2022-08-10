function [theta] = orientation(vectorfield)
%Calculates orientation of 
%   Detailed explanation goes here

[theta,rho] = cart2pol(vectorfield(:,3),vectorfield(:,4));
width = min(vectorfield(:,1));
height = min(vectorfield(:,2));
theta = rad2deg(theta);

end