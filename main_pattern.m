%% Load in data
clear

path = '/Users/sbarnett/Documents/PIVData/fatima/200_D_C1_Phase_20220307_MCF10ARab5A_H2BGFP_uPatterns-01-Scene-04-P5-A01_cr_Results/';
tifpath = '/Users/sbarnett/Documents/PIVData/fatima/Invasion_migrating_edges/blurred/200_D_C1_Phase_20220505_MCF10ARab5A_H2BGFP_Invasion-01-Scene-021-P22-A02.tif';

pixelsize = 0.65 * 16; % pixel size in microns multiply half the PIV window size
timeinterval = 600/60/60; % time in hours
plotting = 1;

%Clean files and natural sort
files = dir(fullfile(path,'PIV_roi_velocity_text'));
names = {};
for i=3:size(files,1)
    names{i-2} = files(i).name;
end
filessort = natsort(names).';

% Read in the vectorfields
for i = 1:size(filessort,1)
    vectorfield(:,:,i) = csvread(fullfile(path,'PIV_roi_velocity_text',filessort{i}));
end

time = (1:size(names,2)).*timeinterval;

%% Linearise Field - works
%Remove unconnected vectors
vectorfield = cleanField(vectorfield);
%center x and y coordinates, assumes no movement
[centerX, centerY] = findCentre(vectorfield);
%change scale of x,y coordinates
vectorfield(:,1,:) = vectorfield(:,1,:)./vectorfield(1,1,:);
vectorfield(:,2,:) = vectorfield(:,2,:)./vectorfield(1,2,:);
linearfield = vectorfield;
%linearise the fields
for i = 1:size(filessort,1)
    [lfU,lfV] = LinearizeFieldScaled(vectorfield(:,:,i),centerX,centerY);
    linearfield(:,3,i) = lfU(:);
    linearfield(:,4,i) = lfV(:);
end

%% Calculate vRMS through time - works
% Check zeros dealt with properly
% vrms on normal field will equal zero, all movement averages

vrms = zeros([size(filessort,1),1]);
for i = 1:size(filessort,1)
    vrms(i) = vRMS(linearfield(:,:,i))*pixelsize;
end

if plotting
    plot(time, vrms,'o','MarkerFaceColor',[0, 0.4470, 0.7410])
    axis([0 23 0 60])
    axis square
    title('V_R_M_S','FontSize',16)
    xlabel('Time (hours)','FontSize',14)
    ylabel('V_R_M_S [\mum/hour]','FontSize',14)
end

%% Calculate ROP

ROP = zeros([size(filessort,1),1]);
for i = 1:size(filessort,1)
    ROP(i) = RotationalOrderParameter(vectorfield(:,:,i),centerX,centerY)
end


if plotting
    plot(time,ROP)
    axis([0 23 0 1])
    axis square
    title('Rotational Order Parameter','FontSize',16)
    xlabel('Time (hours)','FontSize',14)
    ylabel('\psi','FontSize',14)
end


%% Calculate Correlation - maybe

startframe = 10;
endframe = 100;
corel = Correlation(linearfield, startframe, endframe);

x=((1:length(corel))-1).*pixelsize; % create x axis
f_=fit(x',corel','exp2'); %generate a double exponential fit
F = f_.a*exp(f_.b*x) + f_.c*exp(f_.d*x); % create plotting data for the fit

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

%% Calculate Persistence length - probably not right

msd = MSD(vectorfield); % check linear vs vectorfield
mMSD = mean(msd,1).*pixelsize^2;
xtime = ((1:size(mMSD,2)).*timeinterval)'
MSDfit = fit(xtime,mMSD','A*x.^2/(1+(B*x))','startpoint',[10 .5],'weight',1./xtime.^2);

A = MSDfit.A;
B = MSDfit.B;
ci = confint(MSDfit,.95);
da = ci(2,1)-ci(1,1);
db = ci(2,2)-ci(1,2);
L_p = sqrt(A)./B;

if plotting
    loglog(xtime,mMSD)
    title('Mean Square Displacement','FontSize',16)
    xlabel('\DeltaT')
end
%%
DX = pixelsize*16
x_n=((1:length(C))-1);
f1=fit(x_n',y_C','a*exp(-abs(b*x).^c)','startpoint',[y_C(1) .01 1],'lower',[0 0 0],'upper',[inf inf 2]);

L1=(DX./f1.b)*gamma(1/f1.c)./f1.c;

%% Read in images to overlay on video
info = imfinfo(tifpath);
numberOfPages = length(info);

for k = 1 : numberOfPages
    images(:,:,k) = imread(tifpath, k);
end	


%%
%tj = trajectories(vectorfield);
tj(tj==0) = NaN;
% Give the video a name!
Linevideo(tj,fullfile(path,'vidlines.avi'),10)
