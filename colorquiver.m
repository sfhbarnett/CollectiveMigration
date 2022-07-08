

% This is the fastest & best version for quiver plot.
%
% magnitude input to quiver = 50, arrow length -> maximally fit the grid
%
% so, if the maximum magnitude input by user is 10, find the scale to scale this maximum magnitude to 50.
% in this case, quiver_scale = 50/10 = 5, all the vector magnitude will be multiplied by 3 before input to the quiver function.
%
% Written by hui ting, 9 march 2016. edited by Sam Barnett 2022



function scaled_quiver2(x_coor,y_coor,uu,vv,f1,max_mag)

           
mag_u=sqrt((uu.^2)+(vv.^2));
clip_mag_u=mag_u; 
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   PLOT NORMALISED VECTOR   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

norm_ux=uu./mag_u;
norm_uy=vv./mag_u;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   FIND SCALE BASED ON USER MAX   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cmap = jet(36); % 1:36 level , define a color map with 35 levels
clr_scl = 35/max_mag; % 0:35 , find the scale to scale data max to 35 (max value for our colormap)
qv_scl = 50/max_mag; % find the scale to scale vector magnitude max to 50  (arrow max length fitted to grid = 50)

clip_mag_u(clip_mag_u>max_mag)=max_mag; % everything larger than user max, will be assigned the user max value
mag = floor(clr_scl.*clip_mag_u); % for color only, bcos inside the data, if no such max mag, quiver will rescale based on the max value in the data only, using any clr_scl will result the same.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   PLOT SCALED VECTOR   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clip_ux=clip_mag_u.*norm_ux;
clip_uy=clip_mag_u.*norm_uy;

scl_ux=qv_scl.*clip_ux;
scl_uy=qv_scl.*clip_uy;

imagesc(f1);hold on;
% title(tit)
%cla; imagesc(f1);hold on;
colormap gray
for i = 0:35
    
    idx_mag = find(mag==i);
    set(gca,'Clipping','on')
    if ~isempty(idx_mag)
    quiver(x_coor(idx_mag),y_coor(idx_mag),scl_ux(idx_mag),scl_uy(idx_mag),0,'Color',cmap(i+1,:),'MaxHeadSize',1,'Clipping','on');
    hold on;
    end
  
end
hold off
axis([0 size(f1,1), 0 size(f1,2)])
axis equal tight
%axis off;

