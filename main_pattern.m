%% Load in data
clear

path = '/Users/sbarnett/Downloads/uPatterns_forSam/500_WD_C1-20210710_MCF10ARAB5A_H2BGFP_Micropatterns_diffSizes_Doxy_withoutDoxy.czi #030_Results';
tifpath = [path(1:end-8),'.tif'];

pixelsize = 0.65 * 16; % pixel size in microns multiply the PIV window size multiplied by overlap
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

info = imfinfo(tifpath);
numberOfPages = length(info);

for k = 1 : numberOfPages
    image(:,:,k) = imread(tifpath, k);
end


time = (1:size(names,2)).*timeinterval;

width = max(vectorfield(:,1,1))/max(vectorfield(1,1,1));
height = max(vectorfield(:,2,1))/max(vectorfield(1,2,1));
nframes = size(vectorfield,3);
squarex =reshape(vectorfield(:,1,:),[width,height,nframes]);
squarey = reshape(vectorfield(:,2,:),[width,height,nframes]);
squareu = reshape(vectorfield(:,3,:),[width,height,nframes]);
squarev = reshape(vectorfield(:,4,:),[width,height,nframes]);

%% Processing with Rois - Don't close the image until after the next section
t = 1;
imagesc(image(:,:,t))
colormap('gray')
axis equal tight
roi = drawcircle();

%% Process Rois
bw = createMask(roi);
for j = 1:size(vectorfield,1)
    x = vectorfield(j,1);
    y = vectorfield(j,2);
    if bw(x,y) == 0
        vectorfield(j,3:4,:) = repmat([0,0],[1,1,126]);
    end
end
% Now close the image!

%% Linearise Field - works
%Remove unconnected vectors
dX = vectorfield(1,1,1);
vectorfield = cleanField(vectorfield,width/2,height/2);
%center x and y coordinates, assumes no movement
[centerX, centerY] = findCentre(vectorfield(:,:,i),width,height);
%change scale of x,y coordinates
vectorfield(:,1,:) = vectorfield(:,1,:);
vectorfield(:,2,:) = vectorfield(:,2,:);
linearfield = vectorfield;
%linearise the fields
for i = 1:nframes
    [centerX, centerY] = findCentre(vectorfield(:,:,i),width,height);
    [lfU,lfV] = LinearizeFieldScaled(vectorfield(:,:,i),centerX,centerY);
    linearfield(:,3,i) = lfU(:);
    linearfield(:,4,i) = lfV(:);
end

vectorfield(:,1,:) = vectorfield(:,1,:);
vectorfield(:,2,:) = vectorfield(:,2,:);

%% Recreate quiver images after cleaning
path = '/Users/sbarnett/Downloads/cleanfields_example/cleanfields';
mkdir(path)
for frame = 1:nframes
    frame
    colorquiver(vectorfield(:,1,frame),vectorfield(:,2,frame),vectorfield(:,3,frame),vectorfield(:,4,frame),images(:,:,frame),0.5)
    F = getframe(gca);
    im = frame2im(F);
    imwrite(im, fullfile(path, [num2str(frame),'.tif']));
end
%% Calculate vRMS through time - works
% Check zeros dealt with properly
% vrms on normal field will equal zero, all movement averages

vrms = zeros([nframes,1]);
for i = 1:nframes
    vrms(i) = vRMS(linearfield(:,:,i));
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

ROP = zeros([nframes,1]);
TOP = zeros([nframes,1]);
for i = 1:size(filessort,1)
    [ROP(i),TOP(i)] = RotationalOrderParameter(vectorfield(:,:,i),centerX,centerY);
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
[Lcorr, delta1] = CorrelationLength(vectorfield,startframe,endframe,corel,x,pixelsize,f_)

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

msd = MSD(vectorfield,width,height); % check linear vs vectorfield
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

%% Line video
tj = trajectories(vectorfield,width,height);
tj(tj==0) = NaN;
Linevideo(tj,fullfile(path,'vidlines.avi'),10)
%%
linalignpath = fullfile(path,'linearalignment');
mkdir(linalignpath);
for frame = 1:nframes
    linearfield(isnan(linearfield)) = 0;

    alignmap = reshape(alignment(linearfield(:,:,frame)),[width,height]);
    meanu = mean(mean(linearfield(:,3,frame),'omitnan'),'omitnan');
    meanv = mean(mean(linearfield(:,4,frame),'omitnan'),'omitnan');

    magnitude = sqrt(linearfield(:,3,frame).^2 + linearfield(:,4,frame).^2);
    meanmagnitude = sqrt(meanu^2 + meanv^2);

    scale = magnitude./meanmagnitude;

    u = reshape(linearfield(:,3,frame)./scale,[width,height]);
    v = reshape(linearfield(:,4,frame)./scale,[width,height]);
    %Creates same style alignment map with scaled vectors, file -> save as -> .svg
    alignmap = imresize(alignmap,size(image(:,:,frame)),'nearest');
    p1 = imagesc(alignmap,[-1 1]);
    imAlpha = ones(size(alignmap));
    imAlpha(isnan(alignmap))=0;
    p1.AlphaData = imAlpha;
    colormap default
    axis equal tight
    hold on
    quiver(linearfield(:,1,frame),linearfield(:,2,frame),u(:),v(:),'k')
    hold off
    pause(0.0000001)
    saveas(gcf,fullfile(linalignpath, [num2str(frame),'.tif']))
end
%% Create Orientation map
orientationpath = fullfile(path,'orientationmap');
mkdir(orientationpath);

for frame=1:nframes
    orientmap = reshape(orientation(vectorfield(:,:,frame)),[width,height]);
    p1 = imagesc(orientmap+180,[0 360]);
    imAlpha = ones(size(orientmap));
    imAlpha(orientmap==0)=0;
    p1.AlphaData = imAlpha;
    axis equal tight
    colormap(hsv)
    pause(0.0000001)
    saveas(gcf,fullfile(orientationpath, [num2str(frame),'.tif']))
end
