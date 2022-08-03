clear

folder = uigetdir('','Choose Batch-Folder to process');

pixelsize = 0.65 * 16; % pixel size in microns multiply half the PIV window size
timeinterval = 600/60/60; % time in hours

experiments = dir(folder);
experiments = experiments(~ismember({experiments.name},{'.','..','.DS_Store'}));

for experiment = 1:size(experiments)
    rotation = 0;
    scratch = 0;
    experimentpath = fullfile(folder,experiments(experiment).name);
    if experimentpath(end-2:end) == 'ROT' % Use ROT for both patterns and invasion
        rotation = 1;
    elseif experimentpath(end-2:end) == 'SCR' % for scratch wound assays
        scratch = 1;
    end

    datasets = dir(experimentpath);
    datasets = datasets(~ismember({datasets.name},{'.','..','.DS_Store'}));
    datasets = datasets([datasets.isdir]);

    counter = 1;
    for dataset = 1:size(datasets)
        vrms_total = [];
        LOP_total = [];
        ROP_total = [];
        RTOP_total = [];
        TOP_total = [];
        correlation_total = [];
        persistance_total = [];
        correlationlength_total = [];
        msd_total = [];

        datapath = fullfile(experimentpath,datasets(dataset).name,'PIV_roi_velocity_text');
        name = datasets(dataset).name;
        tifpath = [fullfile(experimentpath,name(1:end-8)),'.tif'];
        files = dir(datapath);
        files=files(~ismember({files.name},{'.','..','.DS_Store'}));

        names = {};
        for i=1:size(files,1)
            names{i} = files(i).name;
        end
        filessort = natsort(names).';
        vectorfield = [];

        for i = 1:size(filessort,1)
            vectorfield(:,:,i) = csvread(fullfile(datapath,filessort{i}));
        end

        info = imfinfo(tifpath);
        numberOfPages = length(info);
        images=[];
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

        if rotation
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

            mkdir(fullfile(experimentpath,datasets(dataset).name,'cleanfields'))
            for frame = 1:nframes
                colorquiver(vectorfield(:,1,frame),vectorfield(:,2,frame),vectorfield(:,3,frame),vectorfield(:,4,frame),images(:,:,frame),10)
                axis equal tight
                F = getframe(gca);
                im = frame2im(F);
                imwrite(im, fullfile(experimentpath,datasets(dataset).name,'cleanfields', [num2str(frame),'.tif']));
            end

            vrms = zeros([nframes,1]);
            for i = 1:nframes
                vrms(i) = vRMS(linearfield(:,:,i));
            end

            ROP = zeros([nframes,1]);
            for i = 1:nframes
                LOP(i) = LinearOrderParameter(vectorfield(:,:,i));
                [ROP(i),TOP(i)] = RotationalOrderParameter(vectorfield(:,:,i),centerX,centerY);
            end

            mkdir(fullfile(experimentpath,datasets(dataset).name,'rotationalalignments'))
            for frame = 1:nframes
                alignmap = reshape(alignment(linearfield(:,:,frame)),[width,height]);
                meanu = mean(mean(linearfield(:,3,frame),'omitnan'),'omitnan');
                meanv = mean(mean(linearfield(:,4,frame),'omitnan'),'omitnan');
    
                magnitude = sqrt(linearfield(:,3,frame).^2 + linearfield(:,4,frame).^2);
                meanmagnitude = sqrt(meanu^2 + meanv^2);
    
                scale = magnitude./meanmagnitude;
                im1 = images(:,:,frame);
    
                u = reshape(vectorfield(:,3,frame)./scale,[width,height]);
                v = reshape(vectorfield(:,4,frame)./scale,[width,height]);
                p1 = imagesc(alignmap,[-1,1]);
                imAlpha = ones(size(alignmap));
                imAlpha(isnan(alignmap))=0;
                p1.AlphaData = imAlpha;
                colormap default
                axis equal tight
                hold on
                quiver(vectorfield(:,1,frame)./vectorfield(1,1,1),vectorfield(:,2,frame)./vectorfield(1,2,1),u(:),v(:),'k')
                hold off
                saveas(gcf,fullfile(experimentpath,datasets(dataset).name,'rotationalalignments', [num2str(frame),'.tif']))
            end
            mkdir(fullfile(experimentpath,datasets(dataset).name,'linearalignments'))
            for frame = 1:nframes
                alignmap = reshape(alignment(vectorfield(:,:,frame)),[width,height]);
                meanu = mean(mean(linearfield(:,3,frame),'omitnan'),'omitnan');
                meanv = mean(mean(linearfield(:,4,frame),'omitnan'),'omitnan');
    
                magnitude = sqrt(linearfield(:,3,frame).^2 + linearfield(:,4,frame).^2);
                meanmagnitude = sqrt(meanu^2 + meanv^2);
    
                scale = magnitude./meanmagnitude;
                im1 = images(:,:,frame);
    
                u = reshape(vectorfield(:,3,frame)./scale,[width,height]);
                v = reshape(vectorfield(:,4,frame)./scale,[width,height]);
                p1 = imagesc(alignmap,[-1,1]);
                imAlpha = ones(size(alignmap));
                imAlpha(isnan(alignmap))=0;
                p1.AlphaData = imAlpha;
                colormap default
                axis equal tight
                hold on
                quiver(vectorfield(:,1,frame)./vectorfield(1,1,1),vectorfield(:,2,frame)./vectorfield(1,2,1),u(:),v(:),'k')
                hold off
                saveas(gcf,fullfile(experimentpath,datasets(dataset).name,'linearalignments', [num2str(frame),'.tif']))
            end

            % #########################################
        elseif scratch
            left = cleanField(vectorfield,5,5);
            right = cleanField(vectorfield,width-5,height-5);
            kymograph = zeros(sqrt(size(vectorfield,1)),size(time,2));
            for i = 1:size(vectorfield,3)
                i
                ufield = reshape(vectorfield(:,3,i),[sqrt(size(vectorfield,1)),sqrt(size(vectorfield,1))]);
                kymograph(:,i) = mean(ufield);
            end
            kymograph = kymograph.';
            imwrite(kymograph,fullfile(experimentpath,datasets(dataset).name,'kymograph.tif'))

            vrms = zeros([size(filessort,1),1]);
            for i = 1:size(filessort,1)
                vrms(i) = vRMS(vectorfield(:,:,i));
            end

            LOP = zeros([nframes,1]);
            for i = 1:nframes
                LOPL = LinearOrderParameter(left(:,:,i));
                LOPR = LinearOrderParameter(right(:,:,i));
                LOP(i) = mean([LOPL,LOPR]); %mean of both sides
            end
            mkdir(fullfile(experimentpath,datasets(dataset).name,'alignments'))
            for frame = 1:nframes
                alignmap = reshape(alignment(left(:,:,frame)),[width,height]);
                meanu = mean(mean(left(:,3,frame)));
                meanv = mean(mean(left(:,4,frame)));
    
                magnitude = sqrt(left(:,3,frame).^2 + left(:,4,frame).^2);
                meanmagnitude = sqrt(meanu^2 + meanv^2);
    
                scale = magnitude./meanmagnitude;
                im1 = images(:,:,frame);
    
                u = reshape(left(:,3,frame)./scale,[width,height]);
                v = reshape(left(:,4,frame)./scale,[width,height]);
                p1 = imagesc(imresize(alignmap,size(images(:,:,frame))));
                axis equal tight
                hold on
                quiver(left(:,1,frame), left(:,2,frame), u(:), v(:),'k')
                hold off
                saveas(gcf,fullfile(experimentpath,datasets(dataset).name,'alignments', [num2str(frame),'.tif']))
            end
            % #########################################
        else
            vrms = zeros([size(filessort,1),1]);
            for i = 1:size(filessort,1)
                vrms(i) = vRMS(vectorfield(:,:,i));
            end
            LOP = zeros([size(filessort,1),1]);
            for i = 1:size(filessort,1)
                LOP(i) = LinearOrderParameter(vectorfield(:,:,i));
            end
            mkdir(fullfile(experimentpath,datasets(dataset).name,'alignments'))
            for frame = 1:nframes
                alignmap = reshape(alignment(vectorfield(:,:,frame)),[width,height]);
                meanu = mean(mean(vectorfield(:,3,frame)));
                meanv = mean(mean(vectorfield(:,4,frame)));
    
                magnitude = sqrt(vectorfield(:,3,frame).^2 + vectorfield(:,4,frame).^2);
                meanmagnitude = sqrt(meanu^2 + meanv^2);
    
                scale = magnitude./meanmagnitude;
                im1 = images(:,:,frame);
    
                u = reshape(vectorfield(:,3,frame)./scale,[width,height]);
                v = reshape(vectorfield(:,4,frame)./scale,[width,height]);
                p1 = imagesc(imresize(alignmap,size(images(:,:,frame))));
                axis equal tight
                hold on
                quiver(vectorfield(:,1,frame),vectorfield(:,2,frame),u(:),v(:),'k')
                hold off
                saveas(gcf,fullfile(experimentpath,datasets(dataset).name,'alignments', [num2str(frame),'.tif']))
            end
        end
        startframe = 10;
        endframe = 100;
        corel = Correlation(vectorfield, startframe, endframe);

        x=((1:length(corel))-1).*pixelsize; % create x axis
        f_=fit(x',corel','exp2','Upper',[100,100,100,100],'Lower',[-100,-100,-100,-100]); %generate a double exponential fit
        F = f_.a*exp(f_.b*x) + f_.c*exp(f_.d*x); % create plotting data for the fit
        [Lcorr, delta1] = CorrelationLength(vectorfield,startframe,endframe,corel,x,pixelsize,f_);


        msd = MSD(vectorfield./pixelsize.*timeinterval,width,height);
        mMSD = mean(msd,1).*pixelsize^2;
        xtime = ((1:size(mMSD,2)).*timeinterval)';
        MSDfit = fit(xtime,mMSD','A*x.^2/(1+(B*x))','startpoint',[10 .5],'weight',1./xtime.^2);

        A = MSDfit.A;
        B = MSDfit.B;
        ci = confint(MSDfit,.95);
        da = ci(2,1)-ci(1,1);
        db = ci(2,2)-ci(1,2);
        L_p = sqrt(A)./B;

%         tj = trajectories(vectorfield,width,height);
%         tj(tj==0) = NaN;
%         Linevideo(tj,fullfile(experimentpath,[datasets(dataset).name,'.avi']),10,images);
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
        persistance_total(counter) = L_p;
        correlationlength_total(counter) = Lcorr;
        msd_total(:,counter) = mMSD;

        mkdir(fullfile(experimentpath,datasets(dataset).name,'orientation'))
        for frame = 1:nframes
            orientmap = reshape(orientation(vectorfield(:,:,frame)),[width,height]);
            imagesc(orientmap+180,[0 360])
            axis equal tight
            colormap(hsv)
            saveas(gcf,fullfile(experimentpath,datasets(dataset).name,'orientation', [num2str(frame),'.tif']))
        end

        counter = counter + 1;
        fclose('all');
    end
    writematrix(vrms_total,fullfile(experimentpath,'vrms.csv'))
    writematrix(correlation_total,fullfile(experimentpath,'correlation_total.csv'))
    writematrix(persistance_total,fullfile(experimentpath,'persistance_total.csv'))
    writematrix(correlationlength_total,fullfile(experimentpath,'correlation_length.csv'))
    writematrix(ROP_total,fullfile(experimentpath,'ROP_total.csv'))
    writematrix(TOP_total,fullfile(experimentpath,'TOP_total.csv'))
    writematrix(LOP_total,fullfile(experimentpath,'LOP_total.csv'))
    writematrix(msd_total,fullfile(experimentpath,'MSD_total.csv'))
end
