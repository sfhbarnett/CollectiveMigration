function [order] = LinearOrderParameter(vectorfield)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

meanu = mean(vectorfield(:,3));
meanv = mean(vectorfield(:,4));
mean_v2=mean(mean(vectorfield(:,3).^2+vectorfield(:,4).^2));
% mean_abs_v=mean(mean(sqrt(vectorfield(:,3).^2+vectorfield(:,4).^2)));

order = (meanu.^2+meanv.^2)./(mean_v2);
end

