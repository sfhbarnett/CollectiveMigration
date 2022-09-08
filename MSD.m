function msd = MSD(vectorfield,width,height)

msd = [];
counter = 1;
zerovectors = 0;
%pixel_size = 0.65;
%timestep = 30;
tottrajectories = [];

for j = 1:size(vectorfield,1)
    if or(vectorfield(j,3,1)~=0, vectorfield(j,3,1)~=0)
        x = vectorfield(j,1,1)./vectorfield(1,1,1);
        y = vectorfield(j,2,1)./vectorfield(1,2,1);
        trajectory = [x,y];
        for i = 2:size(vectorfield,3) %for every timesetep
            ufield = reshape(vectorfield(:,3,i-1),[sqrt(size(vectorfield,1)),sqrt(size(vectorfield,1))]);
            vfield = reshape(vectorfield(:,4,i-1),[sqrt(size(vectorfield,1)),sqrt(size(vectorfield,1))]);
            newx = round(trajectory(i-1,1));
            newy = round(trajectory(i-1,2));

            if newx > width
                break
            end
            if newy > height
                break
            end
            if newx < 1
                break
            end
            if newy < 1
                break
            end
            if ~isnan(newy) && ~isnan(newx)
                if ~isnan(ufield(newy,newx)) && ~isnan(vfield(newy,newx))
                    newu = ufield(newy,newx);
                    newv = vfield(newy,newx);
                else
                    newu = 0;
                    newv = 0;
                end         
                trajectory(i,:) = [trajectory(i-1,1)+newu,trajectory(i-1,2)+newv];
            end
        end
        if size(trajectory,1) < size(vectorfield,3)
            trajectory = padarray(trajectory,[size(vectorfield,3)-size(trajectory,1),0],NaN,'post');
        end
        %calculate MSD

        tottrajectories(:,:,counter) = trajectory;
        %for t = 1:size(trajectory,1)
        %    msd(t,counter) = ((trajectory(t,1)-trajectory(1,1))^2 + (trajectory(t,2)-trajectory(1,2))^2);
        %end
        counter = counter + 1;

    end
end

for tau = 1:size(tottrajectories,1)/4
    for t = 1:size(tottrajectories,3)
        deltacoords = tottrajectories(1+tau:end,:,t)-tottrajectories(1:end-tau,:,t);
        squares = sum(deltacoords.^2,2);
        squares(squares==0) = NaN;
        msd(t,tau) = mean(squares,'omitnan');
    end
end
end
