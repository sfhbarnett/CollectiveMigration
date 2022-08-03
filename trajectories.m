function trajectories = trajectories(vectorfield,width,height)

trajectories = [];
counter = 1;
zerovectors = 0;
%pixel_size = 0.65;
%timestep = 30;
tic
trajectories = zeros(size(vectorfield,3),size(vectorfield,1)*2);
trajectory = zeros(size(vectorfield,3),2);
ufieldtot = reshape(vectorfield(:,3,:),[width,height,size(vectorfield,3)]);
vfieldtot = reshape(vectorfield(:,4,:),[width,height,size(vectorfield,3)]);
% for each vector
for j = 1:size(vectorfield,1)
    % if either u or v is not zero
    %if or(vectorfield(j,3,1)~=0, vectorfield(j,4,1)~=0)
    %normalise x/y
    x = vectorfield(j,1,1)/vectorfield(1,1,1);
    y = vectorfield(j,2,1)/vectorfield(1,1,1);
    trajectory = [x,y];
    for i = 2:size(vectorfield,3)
        newx = round(trajectory(i-1,1));
        newy = round(trajectory(i-1,2));
        if newx > width
            newx = width;
        end
        if newy > height
            newy = height;
        end
        if newx < 1
            newx = 1;
        end
        if newy < 1
            newy = 1;
        end
        newu = ufieldtot(newy,newx,i-1);
        newv = vfieldtot(newy,newx,i-1);

        trajectory(i,:) = [trajectory(i-1,1)+newu,trajectory(i-1,2)+newv];
    end

    trajectories(:,counter:counter+1) = trajectory;
    counter = counter + 2;
end

for t = 1:size(vectorfield,3)
    ufield(:,:,t) = reshape(vectorfield(:,3,t),[width,height]);
    vfield(:,:,t) = reshape(vectorfield(:,4,t),[width,height]);
end
toc
uind = 1:width;
vind = 1:height;
[uind,vind] = meshgrid(uind,vind);
lengthchange = 1;

%finds points where there isn't a vector within a certain distance and
%fills them in
for t = 2:size(vectorfield,3)
    t
    %Current timepoint
    for uu = 1:size(uind,1)
        for vv = 1:size(uind,2)
            tjs = trajectories(t,:);
            diffx = (tjs(1:2:end)-uind(uu,vv)).^2;
            diffy = (tjs(2:2:end)-vind(uu,vv)).^2;
            comb = diffx+diffy;
            greaterthanzero = comb>0;
            if min(comb(greaterthanzero)) > 1.5 
                new_tj = [uind(uu,vv),vind(uu,vv)];
                c = 1;
                for furthert = t+1:size(vectorfield,3)
                    newx = round(new_tj(c,1));
                    newy = round(new_tj(c,2));

                    if newx > width
                        newx = width;
                    end
                    if newy > height
                        newy = height;
                    end
                    if newx < 1
                        newx = 1;
                    end
                    if newy < 1
                        newy = 1;
                    end

                    newu = ufield(newy,newx,furthert);
                    newv = vfield(newy,newx,furthert);

                    new_tj(c+1,:) = [new_tj(c,1)+newu,new_tj(c,2)+newv];
                    c = c + 1;
                end
                new_tj = padarray(new_tj,[size(vectorfield,3)-size(new_tj,1),0],NaN,'pre');
                trajectories(:,end+1:end+2) = new_tj;
            end
        end
    end


    %
    %     tjs = trajectories(t,:);
    %     t
    %     %get xcoord
    %     xcoord = tjs(1:2:end).';
    %     %repeat xcoords to test against every x/y combination
    %     xcoord = repmat(xcoord,1,width,height);
    %     xcoord = permute(xcoord,[3,2,1]);
    %
    %     ycoord = tjs(2:2:end).';
    %     ycoord = repmat(ycoord,1,width,height);
    %     ycoord = permute(ycoord,[3,2,1]);
    %
    %     diffx = (xcoord-uind).^2;
    %     diffy = (ycoord-vind).^2;
    %
    %     d = min(diffx + diffy,[],3);
    %
    %
    %     idx = find(d>1.5);
    %
    %     for i = 1:size(idx,1)
    %         new_tj = [uind(idx(i)),vind(idx(i))];
    %         c = 1;
    %         for furthert = t+1:size(vectorfield,3)
    %             newx = round(new_tj(c,1));
    %             newy = round(new_tj(c,2));
    %
    %             if newx > width
    %                 newx = width;
    %             end
    %             if newy > height
    %                 newy = height;
    %             end
    %             if newx < 1
    %                 newx = 1;
    %             end
    %             if newy < 1
    %                 newy = 1;
    %             end
    %
    %             newu = ufield(newy,newx,furthert);
    %             newv = vfield(newy,newx,furthert);
    %
    %             new_tj(c+1,:) = [new_tj(c,1)+newu,new_tj(c,2)+newv];
    %             c = c + 1;
    %         end
    %         trajectories(t:end,end+1:end+2) = new_tj;
    %     end
    % end


end
