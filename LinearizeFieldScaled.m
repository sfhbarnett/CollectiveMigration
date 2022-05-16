function [rotationcomponent,tangentcomponent] = LinearizeFieldScaled(vectorfield,cx,cy)
%LINEARIZEFIELD Summary of this function goes here
%   Detailed explanation goes here

%Reserve memory for new vector components
rotationcomponent = zeros(max(vectorfield(:,1)),max(vectorfield(:,2)));
tangentcomponent = zeros(max(vectorfield(:,1)),max(vectorfield(:,2)));

% for every vector in field
for i = 1:size(vectorfield(:,1))
    %subdivide vector
    x = vectorfield(i,1)/vectorfield(1,1);
    y = vectorfield(i,2)/vectorfield(1,2);
    u = vectorfield(i,3);
    v = vectorfield(i,4);
    magnitude = sqrt(u^2 + v^2);
    
    
    if or(u~=0, v~=0)%if the vector has magnitude
        %Calculate the rotational and tanjent components (linearises)
        [xcomponent, ycomponent] = rotacity(cx,cy,x,y,u,v);
        rotationcomponent(y,x) = xcomponent*magnitude;
        tangentcomponent(y,x) = ycomponent*magnitude;
    else %if vector has zero magnitude, set to NaN
        tangentcomponent(y,x) = NaN;
    end
    
end
end

