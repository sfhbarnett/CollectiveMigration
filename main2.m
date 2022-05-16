%% Load in data
clear

path = '/Users/sbarnett/Documents/PIVData/fatima/ForSam/monolayer1/C1-20210708_MCF10ARAB5A_H2BGFP_Monolayer_Doxy_withoutDoxy.czi - 20210708_MCF10ARAB5A_H2BGFP_Monolayer_Doxy_withoutDoxy.czi #19_Results/PIV_roi_velocity_text';
files = dir(path);

names = {};
for i=3:size(files,1)
    names{i-2} = files(i).name;
end
filessort = natsort(names).';

%% Calculate vRMS through time

vrms = zeros([size(filessort,1),1]);
for i = 1:size(filessort,1)
    vectorfield = csvread(fullfile(path,filessort{i}));
    vrms(i) = vRMS(vectorfield)
end

%% Calculate order paramter

LOP = zeros([size(filessort,1),1]);
for i = 1:size(filessort,1)
    vectorfield = csvread(fullfile(path,filessort{i}));
    LOP(i) = LinearOrderParameter(vectorfield)
end
