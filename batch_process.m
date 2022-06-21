clear

folder = uigetdir('','Choose Batch-Folder to process');

pixelsize = 0.65 * 16; % pixel size in microns multiply half the PIV window size
timeinterval = 600/60/60; % time in hours

experiments = dir(folder);
experiments = experiments(~ismember({experiments.name},{'.','..','.DS_Store'}));

for experiment = 1:size(experiments)
    
    experimentpath = fullfile(folder,experiments(experiment).name)
    if experimentpath(end-2:end) == 'ROT'
        rotation = 1
    else
        rotation = 0
    end
    
    datasets = dir(experimentpath);
    datasets = datasets(~ismember({datasets.name},{'.','..','.DS_Store'}));
    datasets = datasets([datasets.isdir])
    
    vrms_total = [];
    LOP_total = [];
    correlation_total = [];
    persistance_total = [];
    counter = 1
    for dataset = 1:size(datasets)
        
        datapath = fullfile(experimentpath,datasets(dataset).name,'PIV_roi_velocity_text');
        files = dir(datapath);
        files=files(~ismember({files.name},{'.','..','.DS_Store'}));
        
        time = (1:size(names,2)).*timeinterval;
        
        names = {};
        for i=1:size(files,1)
            names{i} = files(i).name;
        end
        filessort = natsort(names).';
        
        for i = 1:size(filessort,1)
            vectorfield(:,:,i) = csvread(fullfile(datapath,filessort{i}));
        end
        
        if rotation
            ufield = reshape(vectorfield(:,3,i-1),[63,63]);
            ufield(ufield==0) = NaN;
            idx = find(~isnan(ufield));
            [x,y] = ind2sub([63,63],idx);
            centerX = round(mean(x));
            centerY = round(mean(y));
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
            
            vrms = zeros([size(filessort,1),1]);
            for i = 1:size(filessort,1)
                vrms(i) = vRMS(linearfield(:,:,i))*pixelsize;
            end
            
            ROP = zeros([size(filessort,1),1]);
            for i = 1:size(filessort,1)
                ROP(i) = RotationalOrderParameter(vectorfield(:,:,i))
            end
            tj = trajectories(vectorfield);
            tj(tj==0) = NaN;
            Linevideo(tj,fullfile(experimentpath,fullfile(experimentpath,[datasets(dataset).name,'.avi'])),10)
            counter = counter + 1
        else
            vrms = zeros([size(filessort,1),1]);
            for i = 1:size(filessort,1)
                vrms(i) = vRMS(vectorfield(:,:,i))*pixelsize;
            end
            
            LOP = zeros([size(filessort,1),1]);
            for i = 1:size(filessort,1)
                LOP(i) = LinearOrderParameter(vectorfield(:,:,i));
            end
            
            startframe = 10;
            endframe = 100;
            corel = Correlation(vectorfield, startframe, endframe);
            
            x=((1:length(corel))-1).*pixelsize; % create x axis
            f_=fit(x',corel','exp2'); %generate a double exponential fit
            F = f_.a*exp(f_.b*x) + f_.c*exp(f_.d*x); % create plotting data for the fit
            
            
            msd = MSD(vectorfield);
            mMSD = mean(msd,1).*pixelsize^2;
            xtime = ((1:size(mMSD,2)).*timeinterval)';
            MSDfit = fit(xtime,mMSD','A*x.^2/(1+(B*x))','startpoint',[10 .5],'weight',1./xtime.^2);
            
            A = MSDfit.A;
            B = MSDfit.B;
            ci = confint(MSDfit,.95);
            da = ci(2,1)-ci(1,1);
            db = ci(2,2)-ci(1,2);
            L_p = sqrt(A)./B;
            
            tj = trajectories(vectorfield);
            tj(tj==0) = NaN;
            % Give the video a name!
            Linevideo(tj,fullfile(experimentpath,fullfile(experimentpath,[datasets(dataset).name,'.avi'])),10)
            
            vrms_total(:,counter) = vrms;
            LOP_total(:,counter) = LOP;
            correlation_total(counter) = f_.b;
            persistance_total(counter) = L_p;
            
            counter = counter + 1;
        end
        fclose('all');
    end
end
