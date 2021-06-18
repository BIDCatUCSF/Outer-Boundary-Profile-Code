function[giant_coord_list]=calc_angle(bound_1,x_cent,y_cent,im_j)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%initial test to flatten the images%%%%%%%%%%%%%%%%%%%%

%counter 
count_big=1;

% %test image for debugging
% test_now=zeros(size(im_j));
% test_now=double(test_now);

for r=1:numel(bound_1(:,2))
    
    del_x=bound_1(r,2)-x_cent;
    del_y=bound_1(r,1)-y_cent;
    
    %convert to index
    idx_ok=sub2ind(size(im_j),bound_1(r,1),bound_1(r,2));
    
    if del_x>0 && del_y<0
        del_y=abs(del_y);
        theta=atan(del_y/del_x);
    elseif del_x<0 && del_y>0
        del_x=abs(del_x);
        theta=pi+(atan((del_y)/del_x));
    elseif del_x<0 && del_y<0
        del_y=abs(del_y);
        del_x=abs(del_x);
        theta=pi-atan(del_y/del_x);
    elseif del_x>0 && del_y>0
        theta=(2*pi)-atan(del_y/del_x);
    elseif del_x==0 && del_y>0
        theta=1.5*pi;
    elseif del_x==0 && del_y<0
        theta=0.5*pi;
    elseif del_x>0 && del_y==0
        theta=0;
    elseif del_x<0 && del_y==0
        theta=pi;
    elseif del_x==0 && del_y==0
        theta=0;
    end
    
    
    
    %storage for later - will pre-allocate to speed up
    giant_coord_list(count_big,1)=bound_1(r,2); %x
    giant_coord_list(count_big,2)=bound_1(r,1); %y
    giant_coord_list(count_big,3)=theta; %angle in xy space
    %giant_coord_list(count_big,4)=t; %z position
    
    %iterate counter
    count_big=count_big+1;
    
    %clear statements
    clear theta; clear idx_ok; clear del_x; clear del_y;
    
end


