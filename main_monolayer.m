%% Load in data
clear

path = '/Users/sbarnett/Documents/PIVData/fatima/ForSam/monolayer1/C1-20210708_MCF10ARAB5A_H2BGFP_Monolayer_Doxy_withoutDoxy.czi - 20210708_MCF10ARAB5A_H2BGFP_Monolayer_Doxy_withoutDoxy.czi #19_Results/PIV_roi_velocity_text';
pixelsize = 0.65 * 16; % pixel size in microns multiply half the PIV window size
timeinterval = 600/60/60; % time in hours
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

%% Calculate vRMS through time - works

vrms = zeros([size(filessort,1),1]);
for i = 1:size(filessort,1)
    vrms(i) = vRMS(vectorfield(:,:,i))*pixelsize;
end



if plotting
    plot(time, vrms,'o','MarkerFaceColor',[0, 0.4470, 0.7410])
    axis([0 23 0 10])
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

%%
%tj = trajectories(vectorfield);
%tj(tj==0) = NaN;
% Give the video a name! 
myVideo = VideoWriter('monolayer_smooth_color.avi');
myVideo.FrameRate = 10;
open(myVideo);
figure('Position',[200,200,800,800])

maxspeed = 0.2;
cmap = jet(36);
for i = 1:126-10
    if i < 10
        distx = diff(tj(1:i,1:2:end)).^2;
        distx(isnan(distx)) = 0;
        disty = diff(tj(1:i,2:2:end)).^2;
        disty(isnan(disty)) = 0;
        col = sum(distx+disty,1)./i;
        colpos = round(col./maxspeed.*36)+1;
        colpos(colpos>256) = 36;
        for j = 1:36
            idx = find(colpos==j);
            toplotx = tj(:,idx.*2-1);
            toploty = tj(:,idx.*2);
            plot(toplotx(1:i,:),toploty(1:i,:),'Color',cmap(j,:))
            hold on
        end
        hold off
        %plot(tj(1:i,1:2:end),tj(1:i,2:2:end))
        axis([0 63 0 63])
    else
        distx = diff(tj(i-9:i,1:2:end)).^2;
        distx(isnan(distx)) = 0;
        disty = diff(tj(i-9:i,2:2:end)).^2;
        disty(isnan(disty)) = 0;
        col = sum(distx+disty,1)./10;
        colpos = round(col./maxspeed.*36)+1;
        colpos(colpos>36) = 36;
        for j = 1:36
            idx = find(colpos==j);
            toplotx = tj(:,idx.*2-1);
            toploty = tj(:,idx.*2);
            plot(toplotx(i-9:i,:),toploty(i-9:i,:),'Color',cmap(j,:))
            hold on
        end
        hold off
        %plot(tj(i-9:i,1:2:end),tj(i-9:i,2:2:end))
        axis([0 63 0 63])
    end
    pause(0.02) 
    frame = getframe(gcf);
    writeVideo(myVideo,frame);
end
close(myVideo);