%% Load in data
clear

path = '/Users/sbarnett/Documents/PIVData/fatima/200_D_C1_Phase_20220307_MCF10ARab5A_H2BGFP_uPatterns-01-Scene-04-P5-A01_cr_Results/PIV_roi_velocity_text';
pixelsize = 0.65 * 16; % pixel size * windowsize (32) * overlap (0.5) 
timeinterval = 30 % time step

files = dir(path);
names = {};
for i=3:size(files,1)
    names{i-2} = files(i).name;
end
filessort = natsort(names).';

for i = 1:size(filessort,1)
    vectorfield(:,:,i) = csvread(fullfile(path,filessort{i}));
end



%% Linearise Field - works
%center x and y coordinates
centerX = 32;
centerY = 32;
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

vrms = zeros([size(filessort,1),1]);
for i = 1:size(filessort,1)
    vrms(i) = vRMS(vectorfield(:,:,i))
    test(i) = vRMS(linearfield(:,:,i))
end

%% Calculate ROP

ROP = RotationalOrderParameter(vectorfield)

ROP = zeros([size(filessort,1),1]);
for i = 1:size(filessort,1)
    ROP(i) = RotationalOrderParameter(vectorfield(:,:,i))
end


%% Calculate Correlation - maybe

startframe = 10;
endframe = 100;
corel = Correlation(vectorfield, startframe, endframe);

x=(1:length(corel))-1; % create x axis
f_=fit(x',corel','exp1'); %generate a double exponential fit
F = f_.a*exp(f_.b*x) % create plotting data for the fit

plot(x,corel./(f_.a),'s'); %plot data scaled to fit
hold on
plot(x,F/(f_.a),'r'); %plot fit

%% Calculate Persistence length - probably not right

pixel_size = 0.65;
timeinteveral = 60;
msd = MSD(vectorfield);

%msd = LinearizeField(


mMSD = mean(msd,2).*pixel_size^2;
time = (1:126) .* timeinteveral;
MSDfit = fit(time',mMSD,'A*x.^2/(1+(B*x))','startpoint',[10 .5],'weight',1./time.^2);

A = MSDfit.A;
B = MSDfit.B;
ci = confint(MSDfit,.95);
da = ci(2,1)-ci(1,1);
db = ci(2,2)-ci(1,2);
L_p = sqrt(A)./B;

