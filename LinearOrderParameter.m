function [order] = LinearOrderParameter(vectorfield)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%Calculates the Linear Order Parameter

meanu = mean(vectorfield(:,3),'omitnan');
meanv = mean(vectorfield(:,4),'omitnan');
mean_v2=mean(mean(vectorfield(:,3).^2+vectorfield(:,4).^2,'omitnan'),'omitnan');
% mean_abs_v=mean(mean(sqrt(vectorfield(:,3).^2+vectorfield(:,4).^2)));

order = (meanu.^2+meanv.^2)./(mean_v2);
end

