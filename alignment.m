function [value] = alignment(vectorfield)
%Calculates the alignment of the vectorfield with the mean vector
%   a value of 1 indicates perfect correlation
%   a value of -1 indicates perfect anticorrelation
%   Input is an Mx4 field of form [x,y,u,v]

averageU = mean(vectorfield(:,3,1));
averageV = mean(vectorfield(:,4,1));

meanvector = [averageU,averageV];
upper = [vectorfield(:,3,1),vectorfield(:,4,1)] * meanvector.';

lower = sqrt(vectorfield(:,3,1).^2+vectorfield(:,4,1).^2) * sqrt(meanvector(1)^2 +meanvector(2)^2);

value = upper./lower
end

