%% Load in data


clear

path = '/Users/sbarnett/Documents/PIVData/scratch/piv2/data-1_Results/PIV_roi_velocity_text';
pixelsize = 0.65 * 16; % pixel size in microns multiply half the PIV window size
timeinterval = 600/60/60 % time in hours
plotting = 1

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
%%
kymograph = zeros(sqrt(size(vectorfield,1)),size(time,2));
for i = 1:size(vectorfield,3)
    i
    ufield = reshape(vectorfield(:,3,i),[sqrt(size(vectorfield,1)),sqrt(size(vectorfield,1))]);
    kymograph(:,i) = mean(ufield);
end
imagesc(abs(kymograph).')
figure
plot(max(kymograph))
%% Calculate vRMS through time - works

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
L_p = sqrt(A)./B;

if plotting
    loglog(xtime,mMSD)
    title('Mean Square Displacement','FontSize',16)
    xlabel('\DeltaT')
end
