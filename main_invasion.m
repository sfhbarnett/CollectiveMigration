%% Load in data
clear

path = '/Users/sbarnett/Downloads/cleanfields_example/200_WD_C1_20211108_MCF10ARab5A_H2BGFP_Invasion-Scene-33-P48-B01DC_BL_Results/PIV_roi_velocity_text';
pixelsize = 0.65 * 32; % pixel size in microns multiply half the PIV window size
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

path = '/Users/sbarnett/Downloads/cleanfields_example/200_WD_C1_20211108_MCF10ARab5A_H2BGFP_Invasion-Scene-33-P48-B01DC_BL.tif';
info = imfinfo(path);
numberOfPages = length(info);
for k = 1 : numberOfPages
    tifstack(:,:,k) = imread(path, k);
end	

%%

v = cleanField(vectorfield);


%%
path = '/Users/sbarnett/Downloads/cleanfields_example/cleanfields';
mkdir(path)
for frame = 1:156
    colorquiver(v(:,1,frame),v(:,2,frame),v(:,3,frame),v(:,4,frame),tifstack(:,:,frame),0.5)
    F = getframe(gca);
    im = frame2im(F);
    imwrite(im, fullfile(path, [num2str(frame),'.tif']));
end

%% Calculate vRMS through time - works
% Check zeros dealt with properly
% vrms on normal field will equal zero, all movement averages

vrms = zeros([size(filessort,1),1]);
for i = 1:size(filessort,1)
    vrms(i) = vRMS(vectorfield(:,:,i));
end

if plotting
    plot(time, vrms,'o','MarkerFaceColor',[0, 0.4470, 0.7410])
    axis([0 23 0 60])
    axis square
    title('V_R_M_S','FontSize',16)
    xlabel('Time (hours)','FontSize',14)
    ylabel('V_R_M_S [\mum/hour]','FontSize',14)
end

