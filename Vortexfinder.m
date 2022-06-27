

radius = 5;

ufield = reshape(vectorfield(:,3,im),[63 63]);
rfield = zeros([size(ufield),size(vectorfield,3)]);
for i = 1:size(vectorfield,3)
    im = i
    ufield = reshape(vectorfield(:,3,im),[63 63]);
    vfield = reshape(vectorfield(:,4,im),[63 63]);

    x = 1:radius*2+1;
    y = 1:radius*2+1;
    [xfield,yfield] = meshgrid(x,y);

    for x = radius+1:size(ufield,1)-radius
        for y = radius+1:size(vfield,2)-radius
            cropu = ufield(x-radius:x+radius,y-radius:y+radius);
            cropv = vfield(x-radius:x+radius,y-radius:y+radius);
            crop = [xfield(:),yfield(:),cropu(:),cropv(:)];
            if ufield(x,y) == 0 && vfield(x,y) == 0
                continue
            else
                rfield(x,y,i) = RotationalOrderParameter(crop);
            end
        end
    end

    imagesc(rfield(:,:,i),[0 1])
    hold on
    quiver(vectorfield(:,1,im)./max(vectorfield(1,1,im)),vectorfield(:,2,im)./max(vectorfield(1,1,im)),vectorfield(:,3,im),vectorfield(:,4,im),1.5,'r')
    axis equal tight
    axis([20 45 20 45])
    pause(0.4)
    hold off
end