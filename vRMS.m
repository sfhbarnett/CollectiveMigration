function [vrms] = vRMS(vectorfield)
%VRMS Summary of this function goes here
%   Detailed explanation goes here


cumulative = 0;
total = 0;
totalu = 0;
totalv = 0;

for vector = 1:size(vectorfield,1)
    x = vectorfield(vector,1)/vectorfield(1,1);
    y = vectorfield(vector,2)/vectorfield(1,2);
    u = vectorfield(vector,3);
    v = vectorfield(vector,4);
    if isnan(u) == 0 && isnan(v) == 0
        cumulative = cumulative + (u^2 + v^2);
        totalu = totalu + u;
        totalv = totalv + v;
        total = total + 1;
    end
end

vrms = sqrt(cumulative/total);

end

