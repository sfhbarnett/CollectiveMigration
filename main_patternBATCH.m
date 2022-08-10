%% Load in data

clear

experimentpath = '/Users/sbarnett/Documents/PIVData/fatima/BatchFolder/invasionROT';
datasets = dir(experimentpath);
datasets = datasets(~ismember({datasets.name},{'.','..','.DS_Store'}));
datasets = datasets([datasets.isdir]);

vrms_total = [];
LOP_total = [];
ROP_total = [];
RTOP_total = [];
TOP_total = [];
correlation_total = [];
persistance_total = [];
correlationlength_total = [];
msd_total = [];
counter = 1; 

for dataset = 1:size(datasets,1)

    path = fullfile(experimentpath,datasets(dataset).name);
    tifpath = [path(1:end-8),'.tif'];

    pixelsize = 0.65 * 16; % pixel size in microns multiply the PIV window size multiplied by overlap
    timeinterval = 600/60/60; % time in hours

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
        images(:,:,k) = imread(tifpath, k);
    end


    time = (1:size(names,2)).*timeinterval;

    width = max(vectorfield(:,1,1))/max(vectorfield(1,1,1));
    height = max(vectorfield(:,2,1))/max(vectorfield(1,2,1));
    nframes = size(vectorfield,3);
    squarex =reshape(vectorfield(:,1,:),[width,height,nframes]);
    squarey = reshape(vectorfield(:,2,:),[width,height,nframes]);
    squareu = reshape(vectorfield(:,3,:),[width,height,nframes]);
    squarev = reshape(vectorfield(:,4,:),[width,height,nframes]);

    % Linearise Field - works
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


    % Recreate quiver images after cleaning
    colorquiverpath = fullfile(path,'cleanfields');
    mkdir(colorquiverpath);
    for frame = 1:nframes
        colorquiver(vectorfield(:,1,frame),vectorfield(:,2,frame),vectorfield(:,3,frame),vectorfield(:,4,frame),images(:,:,frame),0.5)
        F = getframe(gca);
        im = frame2im(F);
        imwrite(im, fullfile(colorquiverpath, [num2str(frame),'.tif']));
    end
    fclose('all')

    % Calculate vRMS through time - works
    % Check zeros dealt with properly

    vrms = zeros([nframes,1]);
    for i = 1:nframes
        vrms(i) = vRMS(linearfield(:,:,i));
    end

    % Calculate ROP

    LOP = zeros([nframes,1]);
    ROP = zeros([nframes,1]);
    TOP = zeros([nframes,1]);
    for i = 1:nframes
        LOP(i) = LinearOrderParameter(vectorfield(:,:,i));
        [centerX, centerY] = findCentre(vectorfield(:,:,i),width,height);
        [ROP(i),TOP(i)] = RotationalOrderParameter(vectorfield(:,:,i),centerX,centerY);
    end

    % Calculate Correlation

    startframe = 10;
    endframe = 100;
    corel = Correlation(linearfield, startframe, endframe);

    x=((1:length(corel))-1).*pixelsize; % create x axis
    f_=fit(x',corel','exp2'); %generate a double exponential fit
    F = f_.a*exp(f_.b*x) + f_.c*exp(f_.d*x); % create plotting data for the fit
    [Lcorr, delta1] = CorrelationLength(vectorfield,startframe,endframe,corel,x,pixelsize,f_)

    % Calculate Persistence length

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

    % Line video
    tj = trajectories(vectorfield,width,height);
    tj(tj==0) = NaN;
    Linevideo(tj,fullfile(path,'vidlines.avi'),10)

    rotalignpath = fullfile(path,'rotationalignment');
    mkdir(rotalignpath);
    for frame = 1:nframes
        vectorfield(isnan(vectorfield)) = 0;

        alignmap = reshape(alignment(vectorfield(:,:,frame)),[width,height]);
        meanu = mean(mean(vectorfield(:,3,frame),'omitnan'),'omitnan');
        meanv = mean(mean(vectorfield(:,4,frame),'omitnan'),'omitnan');

        magnitude = sqrt(vectorfield(:,3,frame).^2 + vectorfield(:,4,frame).^2);
        meanmagnitude = sqrt(meanu^2 + meanv^2);

        scale = magnitude./meanmagnitude;

        u = reshape(vectorfield(:,3,frame)./scale,[width,height]);
        v = reshape(vectorfield(:,4,frame)./scale,[width,height]);
        %Creates same style alignment map with scaled vectors, file -> save as -> .svg
        alignmap = imresize(alignmap,size(images(:,:,frame)),'nearest');
        p1 = imagesc(alignmap,[-1 1]);
        imAlpha = ones(size(alignmap));
        imAlpha(isnan(alignmap))=0;
        p1.AlphaData = imAlpha;
        colormap default
        axis equal tight
        hold on
        quiver(vectorfield(:,1,frame),vectorfield(:,2,frame),u(:),v(:),'k')
        hold off
        pause(0.0000001)
        saveas(gcf,fullfile(rotalignpath, [num2str(frame),'.tif']))
    end
    % Create linear alignment map
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
        alignmap = imresize(alignmap,size(images(:,:,frame)),'nearest');
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

    % Create Orientation map
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
        saveas(gcf,fullfile(orientationpath, [num2str(frame),'.tif']))
    end
    fclose('all')
    if size(vrms_total,1)-size(vrms,1) > 0
        vrms = padarray(vrms,[size(vrms_total,1)-size(vrms,1),0],NaN,'post');
        LOP = padarray(LOP,[size(LOP_total,1)-size(LOP,1),0],NaN,'post');
        ROP = padarray(ROP,[size(ROP_total,1)-size(ROP,1),0],NaN,'post');
        TOP = padarray(TOP,[size(TOP_total,1)-size(TOP,1),0],NaN,'post');
        mMSD = padarray(mMSD,[size(msd_total,1)-size(mMSD,1),0],NaN,'post');
    end
    vrms_total(:,counter) = vrms;
    LOP_total(:,counter) = LOP;
    ROP_total(:,counter) = ROP;
    TOP_total(:,counter) = TOP;
    correlation_total(counter) = f_.b;
    persistance_total(counter) = persistence_length;
    correlationlength_total(counter) = Lcorr;
    msd_total(:,counter) = mMSD;
    counter = counter + 1;
end
writematrix(vrms_total,fullfile(experimentpath,'vrms.csv'))
writematrix(correlation_total,fullfile(experimentpath,'correlation_total.csv'))
writematrix(persistance_total,fullfile(experimentpath,'persistance_total.csv'))
writematrix(correlationlength_total,fullfile(experimentpath,'correlation_length.csv'))
writematrix(ROP_total,fullfile(experimentpath,'ROP_total.csv'))
writematrix(TOP_total,fullfile(experimentpath,'TOP_total.csv'))
writematrix(LOP_total,fullfile(experimentpath,'LOP_total.csv'))
writematrix(msd_total,fullfile(experimentpath,'MSD_total.csv'))

