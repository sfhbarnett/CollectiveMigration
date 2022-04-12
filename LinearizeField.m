function [rotationcomponent,tangentcomponent] = LinearizeField(vectorfield,cx,cy)
%LINEARIZEFIELD Summary of this function goes here
%   Detailed explanation goes here


rotationcomponent = zeros(max(vectorfield(:,1)),max(vectorfield(:,2)));
tangentcomponent = zeros(max(vectorfield(:,1)),max(vectorfield(:,2)));

for i = 1:size(vectorfield(:,1))
    x = vectorfield(i,1)/vectorfield(1,1);
    y = vectorfield(i,2)/vectorfield(1,2);
    u = vectorfield(i,3);
    v = vectorfield(i,4);
    
    if or(u~=0, v~=0)
        [xcomponent, ycomponent] = rotacity(cx,cy,x,y,u,v);
        rotationcomponent(x,y) = xcomponent;
        tangentcomponent(x,y) = ycomponent;
    else
        tangentcomponent(x,y) = NaN;
    end
    
end
end

