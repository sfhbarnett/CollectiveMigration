function [rotationcomponent,tangentcomponent] = LinearizeField(vectorfield,cx,cy)
%Gives the normalised field that has been converted to rotational space to
%linear space
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
    
    
    if or(u~=0, v~=0)%if the vector has magnitude
        %Calculate the rotational and tanjent components (linearises)
        [xcomponent, ycomponent] = rotacity(cx,cy,x,y,u,v);
        rotationcomponent(y,x) = xcomponent;
        tangentcomponent(y,x) = ycomponent;
    else %if vector has zero magnitude, set to NaN
        tangentcomponent(y,x) = NaN;
    end
    
end
end

