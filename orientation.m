function [theta] = orientation(vectorfield)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
[theta,rho] = cart2pol(vectorfield(:,3),vectorfield(:,4));
width = min(vectorfield(:,1));
height = min(vectorfield(:,2));
theta = reshape(rad2deg(theta),[max(vectorfield(:,1)./width), max(vectorfield(:,2)./height)]);
end

