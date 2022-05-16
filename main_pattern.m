%% Load in data
clear

path = '/Users/sbarnett/Documents/PIVData/fatima/ForSam/monolayer1/C1-20210708_MCF10ARAB5A_H2BGFP_Monolayer_Doxy_withoutDoxy.czi - 20210708_MCF10ARAB5A_H2BGFP_Monolayer_Doxy_withoutDoxy.czi #19_Results/PIV_roi_velocity_text';
files = dir(path);

names = {};
for i=3:size(files,1)
    names{i-2} = files(i).name;
end
filessort = natsort(names).';

for i = 1:size(filessort,1)
    vectorfield(:,:,i) = csvread(fullfile(path,filessort{i}));
end


%% Linearise Field
%center x and y coordinates
centerX = 25;
centerY = 25;
%change scale of x,y coordinates
vectorfield(:,1,:) = vectorfield(:,1,:)./vectorfield(1,1,:);
vectorfield(:,2,:) = vectorfield(:,2,:)./vectorfield(1,2,:);
linearfield = vectorfield;
%linearise the fields
for i = 1:size(filessort,1)
    [lfU,lfV] = LinearizeField(vectorfield(:,:,i),centerX,centerY);
    linearfield(:,3,i) = lfU(:);
    linearfield(:,4,i) = lfV(:);
end

%% Calculate vRMS through time

vrms = zeros([size(filessort,1),1]);
for i = 1:size(filessort,1)
    vrms(i) = vRMS(vectorfield(:,:,i))
end

%% Calculate Correlation

startframe = 10;
endframe = 100;
corel = Correlation(vectorfield, startframe, endframe);

x=(1:length(corel))-1; % create x axis
f_=fit(x',corel','exp2'); %generate a double exponential fit
F = f_.a*exp(f_.b*x) + f_.c*exp(f_.d*x); % create plotting data for the fit

plot(x,corel./(f_.a +f_.c),'s'); %plot data scaled to fit
hold on
plot(x,F/(f_.a +f_.c),'r'); %plot fit
