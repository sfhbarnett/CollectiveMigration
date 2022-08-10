function [RadialProfile] = radialSymmetry(vectorfield,width,height,centerX,centerY)

squareu = reshape(vectorfield(:,3,:),[width,height]);
squarev = reshape(vectorfield(:,4,:),[width,height]);
normmap = sqrt(squareu.^2+squarev.^2);
normmap(normmap==0)=NaN;

% Find out what the max distance will be by computing the distance to each corner.
distanceToUL = sqrt((1-centerY)^2 + (1-centerX)^2);
distanceToUR = sqrt((1-centerY)^2 + (width-centerX)^2);
distanceToLL = sqrt((height-centerY)^2 + (1-centerX)^2);
distanceToLR= sqrt((height-centerY)^2 + (width-centerX)^2);
maxDistance = ceil(max([distanceToUL, distanceToUR, distanceToLL, distanceToLR]));

% Allocate an array for the profile
profileSums = zeros(1, maxDistance);
profileCounts = zeros(1, maxDistance);
% Scan the original image getting gray level, and scan edtImage getting distance.
% Then add those values to the profile.
for column = 1:width
    for row = 1:height
        thisDistance = round(sqrt((row-centerY)^2 + (column-centerX)^2));
        if thisDistance <= 0
            continue;
        end
        if ~isnan(normmap(row,column))
            profileSums(thisDistance) = profileSums(thisDistance) + double(normmap(row, column));
            profileCounts(thisDistance) = profileCounts(thisDistance) + 1;
        end
    end
end

RadialProfile = profileSums ./ profileCounts;
RadialProfile(isnan(RadialProfile)) = 0;

end