%% Load in data
clear

path = '/Users/sbarnett/Documents/PIVData/fatima/Invasion_migrating_edges/blurred/200_D_C1_Phase_20220505_MCF10ARab5A_H2BGFP_Invasion-01-Scene-021-P22-A02_Results/PIV_roi_velocity_text';
pixelsize = 0.65 * 16; % pixel size in microns multiply half the PIV window size
timeinterval = 600/60/60; % time in hours
plotting = 1;

files = dir(path);

names = {};
for i=3:size(files,1)
    names{i-2} = files(i).name;
end
filessort = natsort(names).';

for i = 1:size(filessort,1)
    vectorfield(:,:,i) = csvread(fullfile(path,filessort{i}));
end

time = (1:size(names,2)).*timeinterval;

path = '/Users/sbarnett/Documents/PIVData/fatima/Invasion_migrating_edges/blurred/200_D_C1_Phase_20220505_MCF10ARab5A_H2BGFP_Invasion-01-Scene-021-P22-A02.tif';
info = imfinfo(path);
numberOfPages = length(info);
for k = 1 : numberOfPages
    tifstack(:,:,k) = imread(path, k);
end	

%%

v = cleanField(vectorfield);


%%
path = '/Users/sbarnett/Documents/PIVData/fatima/Invasion_migrating_edges/blurred/200_D_C1_20211108_MCF10ARab5A_H2BGFP_Invasion-Scene-08-P4-A01_Results/cleanfields'

for frame = 1:156
    colorquiver(v(:,1,frame),v(:,2,frame),v(:,3,frame),v(:,4,frame),tifstack(:,:,frame),0.5)
    F = getframe(gca);
    im = frame2im(F);
    imwrite(im, fullfile(path, [num2str(frame),'.tif']));
end