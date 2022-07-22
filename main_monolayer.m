%% Load in data
clear

%Path to folder where PIV_roi_velocity_text files are
path = '/Users/sbarnett/Documents/PIVData/fatima/ForSam/monolayer2/C1-20210708_MCF10ARAB5A_H2BGFP_Monolayer_Doxy_withoutDoxy.czi - 20210708_MCF10ARAB5A_H2BGFP_Monolayer_Doxy_withoutDoxy.czi #21_Results/';
tifpath = '/Users/sbarnett/Documents/PIVData/fatima/ForSam/monolayer2/C1-20210708_MCF10ARAB5A_H2BGFP_Monolayer_Doxy_withoutDoxy.czi - 20210708_MCF10ARAB5A_H2BGFP_Monolayer_Doxy_withoutDoxy.czi #21.tif';

pixelsize = 0.65 * 16; % pixel size in microns multiply half the PIV window size
timeinterval = 10/60; % time in hours
plotting = 1;

files = dir(fullfile(path,'PIV_roi_velocity_text'));

%Clean up file names and natural sort
names = {};
for i=3:size(files,1)
    names{i-2} = files(i).name;
end
filessort = natsort(names).';

%Read in the vector fields
for i = 1:size(filessort,1)
    vectorfield(:,:,i) = csvread(fullfile(path,'PIV_roi_velocity_text',filessort{i}));
end

time = (1:size(names,2)).*timeinterval;

%% Calculate vRMS through time - works

vrms = zeros([size(filessort,1),1]);
for i = 1:size(filessort,1)
    vrms(i) = vRMS(vectorfield(:,:,i));
end



if plotting
    plot(time, vrms,'o','MarkerFaceColor',[0, 0.4470, 0.7410])
    axis([0 23 0 40])
    axis square
    title('V_R_M_S','FontSize',16)
    xlabel('Time (hours)','FontSize',14)
    ylabel('V_R_M_S [\mum/hour]','FontSize',14)
end
%% Calculate order paramter

LOP = zeros([size(filessort,1),1]);
for i = 1:size(filessort,1)
    LOP(i) = LinearOrderParameter(vectorfield(:,:,i));
end

if plotting
    plot(time,LOP)
    axis([0 23 0 1])
    axis square
    title('Linear Order Parameter','FontSize',16)
    xlabel('Time (hours)','FontSize',14)
    ylabel('\psi','FontSize',14)
end

%% Calculate Correlation - works

startframe = 10;
endframe = 100;
corel = Correlation(vectorfield, startframe, endframe);

x=((1:length(corel))-1).*pixelsize; % create x axis
f_=fit(x',corel','exp2'); %generate a double exponential fit
F = f_.a*exp(f_.b*x) + f_.c*exp(f_.d*x); % create plotting data for the fit
[Lcorr, delta1] = CorrelationLength(vectorfield,10,100,corel,x,pixelsize,f_)

if plotting
    plot(x,corel./(f_.a +f_.c),'s'); %plot data scaled to fit
    hold on
    plot(x,F/(f_.a +f_.c),'r'); %plot fit
    axis([0 150 0 1])
    axis square
    xlabel('r[\mum]','FontSize',14)
    ylabel('C_V_V','FontSize',14)
    title('Correlation','FontSize',16)
end
%% Calculate Persistence length - works
%might want to give a border to MSD calculation to stop artificial
%curtailing

msd = MSD(vectorfield);
mMSD = mean(msd,1).*pixelsize^2;
xtime = ((1:size(mMSD,2)).*timeinterval)'
MSDfit = fit(xtime,mMSD','A*x.^2/(1+(B*x))','startpoint',[10 .5],'weight',1./xtime.^2);

A = MSDfit.A;
B = MSDfit.B;
ci = confint(MSDfit,.95);
da = ci(2,1)-ci(1,1);
db = ci(2,2)-ci(1,2);
persistence_length = sqrt(A)./B;

if plotting
    loglog(xtime,mMSD)
    title('Mean Square Displacement','FontSize',16)
    xlabel('\DeltaT')
end

%% read in raw images

info = imfinfo(tifpath);
numberOfPages = length(info);

for k = 1 : numberOfPages
    images(:,:,k) = imread(tifpath, k);
end	
%% Generate video with trails

tj = trajectories(vectorfield);
tj(tj==0) = NaN;
Linevideo(tj,fullfile(path,'vidlines.avi'),10,images)

%% Create Alignment map
alignmap = reshape(alignment(vectorfield(:,:,1)),[sqrt(3969),sqrt(3969)]);
meanu = mean(mean(vectorfield(:,3,1)));
meanv = mean(mean(vectorfield(:,4,1)));

magnitude = sqrt(vectorfield(:,3,1).^2 + vectorfield(:,4,1).^2);
meanmagnitude = sqrt(meanu^2 + meanv^2);

scale = magnitude./meanmagnitude;

u = reshape(vectorfield(:,3,1)./scale,[sqrt(3969),sqrt(3969)]);
v = reshape(vectorfield(:,4,1)./scale,[sqrt(3969),sqrt(3969)]);
%Creates same style alignment map with scaled vectors, file -> save as -> .svg
hf = figure;
h1 = axes;
p1 = imagesc(imresize(alignmap,size(images(:,:,1))));
axis equal tight
h2 = axes;
p2 = imagesc(im1>160,'AlphaData',im1>160)
set(h2,'color','none','visible','off')
colormap(h2,gray)
axis equal tight
hold on
quiver(vectorfield(:,1,1),vectorfield(:,2,1),u(:),v(:),'k')

%% Create Orientation map

orientmap = reshape(orientation(vectorfield(:,:,1)),[sqrt(3969),sqrt(3969)]);
hf = figure;
h1 = axes;
p1 = imagesc(imresize(orientmap,size(images(:,:,1)),'bilinear'));
axis equal tight
h2 = axes;
p2 = imagesc(images(:,:,1),'AlphaData',0.5)
set(h2,'color','none','visible','off')
axis equal tight
colormap(h2,gray)
colormap(h1,hsv)
