function[cell_indiv_data,all_angle_ret,all_int_ret,avg_plot]=radial_profile_calc_func(path1,file1,file2) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%breaking apart the filenames%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%Starting index%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%file 1
idx_f1=find(file1=='.');

%finding the image start number
num_start_tmp=file1(idx_f1(1)-2:idx_f1(1)-1);

%figuring out how many files there are
a=dir([path1,'*.tif']);
num_ims=numel(a);

if numel(str2num(num_start_tmp))>0
    
    %initial image number
    num_start=str2num(num_start_tmp);
    
    %path and file prefix
    path=strcat(path1,file1(1:idx_f1(1)-3));

    
else
    
    %initial image
    clear num_start_tmp;
    num_start_tmp=file1(idx_f1(1)-1);
    num_start=str2num(num_start_tmp);
    
    %path and file prefix
    path=strcat(path1,file1(1:idx_f1(1)-2));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%breaking apart the filenames%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%Ending index%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%file 2
idx_f2=find(file2=='.');

%finding the image start number
num_end_tmp=file2(idx_f2(1)-3:idx_f2(1)-1);

if numel(str2num(num_end_tmp))>0
    
    %finalimage number
    num_end=str2num(num_end_tmp);

else
    
    %final number is less than 100
    num_end_tmp=file2(idx_f2(1)-2:idx_f2(1)-1);
    
    %final image number
    num_end=str2num(num_end_tmp);
    
end



%path where images are
%path='C:\Users\jeichorst\Desktop\Casey Project\20180329_ROI21_cropped\1005_high_MYC_A488_CD45_A594_OKT3_A647_21_ch1_stack0000_560nm\ErodedBoundaryImages\MaskBoundErode';

%number of bins
nbins=180;

%image number to look at 
% num_start=63;
% num_end=67;

%number of ims
num_ims=num_end-num_start+1;

%cell array 
cell_indiv_data=cell(num_ims,3);
cell_hold=cell(num_ims,2);

%counter
count=1;
counta=1;

for i=num_start:num_end

    %reading in the image
    im1=imread(strcat(path,num2str(i),'.tif'));
    im1=double(im1);
    
    %getting all non-zero entries
    idx_use=find(im1>0);
    [y_use,x_use]=ind2sub(size(im1),idx_use);
    
    %bw image
    bw_im=zeros(size(im1));
    bw_im(idx_use)=1;
    
    %calculating center
    if count==1
        s=regionprops(bw_im,'centroid');
        x_center=s.Centroid(1);
        y_center=s.Centroid(2);
    end
    
    %calculate angle
    bound_send=[y_use,x_use];
    [angle_info]=calc_angle(bound_send,x_center,y_center,im1);
    
    %converting to degrees
    angle_info(:,3)=angle_info(:,3).*(180/pi);
    
    %sorting angle informations
    sort_angle_info=sortrows(angle_info,3);
     
    %adding a column for indices
    idx_col=sub2ind(size(im1),sort_angle_info(:,2),sort_angle_info(:,1));
    sort_angle_info(:,4)=idx_col;
    
    %adding another matrix to save
    sort_angle_info_save=sort_angle_info;
    sort_angle_info_save(:,5)=im1(idx_col);
    
    
    for g=1:nbins
       
        if g==1
            idx_start=0;
            idx_end=2;
        else
            idx_start=idx_end;
            idx_end=idx_start+2;
        end
        
        %starting indices
        idx_s_tmp=find(sort_angle_info(:,3)>=idx_start);
        
        if numel(idx_s_tmp)>0
            if idx_s_tmp(1)>1
                idx_s=idx_s_tmp(1)-1;
            else
                idx_s=1;
            end
        else 
            idx_s=1;
        end
        
        %ending indice
        idx_e_tmp=find(sort_angle_info(:,3)<=idx_end);
        
        if numel(idx_e_tmp)>0
            if idx_e_tmp(1)<=numel(sort_angle_info(:,3))
                   idx_e=idx_e_tmp(numel(idx_e_tmp));
            else
                idx_e=numel(sort_angle_info(:,3));
            end
        else
            idx_e=numel(sort_angle_info(:,3));
        end
        
        bin_arr(g,1)=idx_s; %start index from list (sort_angle_info)
        bin_arr(g,2)=idx_e; %end index from list (sort_angle_info)
        bin_arr(g,3)=idx_start; %low angle of bin
        bin_arr(g,4)=idx_end; %high angle of bin
        bin_arr(g,5)=mean([idx_start:idx_end]); %Average angle of bin
        bin_arr(g,6)=i; %image number
        
        %clear statements
        clear idx_s_tmp; clear idx_s;
        clear idx_e_tmp; clear idx_e;
        
    end
    
    %holding the relevant information
    cell_hold(count,1)={bin_arr};
    cell_hold(count,2)={sort_angle_info};
    
    %loading another cell array - data by angle
    cell_indiv_data(counta,1)={i};
    cell_indiv_data(counta,2)={sort_angle_info_save};
    
    %iterate counter
    count=count+1;
    counta=counta+1;
    
%     %making a test image
    for j=1:numel(idx_use)
        
       bw_im(sort_angle_info(j,4))=sort_angle_info(j,3);
        
    end
%     
 %   figure, imagesc(bw_im); colormap(jet); colorbar; title('Angle Definition'); hold on;
%     angle_rgb_im=make_rgb_ims(bw_im);
%     figure, imshow(angle_rgb_im);
%     
%     figure, hold on;imagesc(im1); colormap(gray); colorbar; 
%     plot(x_center,y_center,'r+','MarkerSize',12,'LineWidth',1.5);
%     axis tight;
%     
    %clear statements
    clear im1; clear idx_use; clear x_use; clear y_use;
     clear bw_im; clear s; %clear x_center; clear y_center;
    clear bound_send; clear angle_info; %clear sort_angle_info;
    clear idx_col;clear sort_angle_info_save;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%making plots%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% bin_arr(g,1)=idx_s; %start index from list (sort_angle_info)
% bin_arr(g,2)=idx_e; %end index from list (sort_angle_info)
% bin_arr(g,3)=idx_start; %low angle of bin
% bin_arr(g,4)=idx_end; %high angle of bin
% bin_arr(g,5)=mean([idx_start:idx_end]); %Average angle of bin
% bin_arr(g,6)=i; %image number

%another counter
count2=1;

%another counter
count3=1;

%cell array 
cell_hold_angle=cell(num_ims,2);

for s=num_start:num_end

    
    %getting info from cell array
    bin_arr_now_tmp=cell_hold(count2,1);
    bin_arr_now=bin_arr_now_tmp{1};
    
    sort_angle_info_now_tmp=cell_hold(count2,2);
    sort_angle_info_now=sort_angle_info_now_tmp{1};
    
    %indices for image
    idx_look=find(bin_arr_now(:,6)==s);

    if numel(idx_look)>0
        
        %read in the image
        im1a=imread(strcat(path,num2str(s),'.tif'));
        im1a=double(im1a);
        
        %figure, imagesc(im1a); colormap(gray); colorbar; hold on;

        figure, hold on; title(strcat('Slice#',num2str(s)));
        
        for r=1:numel(idx_look)
            s
            r
            %indices from image list to look
            idx1a=bin_arr_now(r,1);
            idx2a=bin_arr_now(r,2);
            
            if r>1
                idx1a=idx1a+1;
            end
            
            %debugging variable
            bin_arr_use(r,1)=idx1a;
            bin_arr_use(r,2)=idx2a;
            
            idx1aa=sort_angle_info_now(idx1a,4);
            idx2aa=sort_angle_info_now(idx2a,4);
            
            %         [y1,x1]=ind2sub(size(im1a),idx1aa);
            %         [y2,x2]=ind2sub(size(im1a),idx2aa);
            %         plot(x1,y1,'g+');
            %         plot(x2,y2,'r+');
            
            idx_calc=sort_angle_info_now(idx1a:idx2a,4);
            
            plot(sort_angle_info_now(idx1a:idx2a,3),im1a(idx_calc),'r.','LineWidth',4,'MarkerEdgeColor',[0.6,0.6,.6],'MarkerSize',12);
            
            %holding onto to raw data
            if r==1 && count2==1
                raw_data_keep(:,1)=sort_angle_info_now(idx1a:idx2a,3);
                raw_data_keep(:,2)=im1a(idx_calc);
                raw_data_keep(:,3)=linspace(bin_arr(r,5),bin_arr(r,5),numel(idx_calc))';
            else
                raw_data_keep_tmp=raw_data_keep;
                clear raw_data_keep;
                raw_data_keep(:,1)=[raw_data_keep_tmp(:,1);sort_angle_info_now(idx1a:idx2a,3)];
                raw_data_keep(:,2)=[raw_data_keep_tmp(:,2);im1a(idx_calc)];
                raw_data_keep(:,3)=[raw_data_keep_tmp(:,3);linspace(bin_arr(r,5),bin_arr(r,5),numel(idx_calc))'];
                clear raw_data_keep_tmp;
            end
            
            %arrays for plotting
            int_plot(r,1)=bin_arr(r,5);
            int_plot(r,2)=mean(im1a(idx_calc));
            
            if bin_arr(r,5)>171 && bin_arr(r,5)<180
                im1a(idx_calc)
            end
            
            %clear statements
            clear idx1a; clear idx2a;
            clear idx1aa; clear idx2aa;clear idx_calc;
            
        end
        
        %more plots
        plot(int_plot(:,1),int_plot(:,2),'k','LineWidth',1.5);
        xlabel('Angle (deg.)'); ylabel('Intensity');
        
        if count3==1
            int_plot_save=int_plot;
            count3=count3+1;
        end
        
        
        %clear statements
        clear im1a; clear int_plot;
        
    end
    
    %put everything into a cell array
    cell_hold_angle(count2,1)={raw_data_keep};
 
    
    %iterate counter
    count2=count2+1;
    
    %clear statements
    clear bin_arr_now_tmp; clear bin_arr_now;
    clear sort_angle_info_now; clear sort_angle_info_now_tmp;
    clear idx_look; 
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%Combining plots if there are mutliple slices%%%%%%%%%%%%%%%%

if num_ims>1
    
    figure, hold on; title('Average');
    
    
    for q=1:(count2-1)
        
        %raw data
        the_raw_tmp=cell_hold_angle(q,1);
        the_raw=the_raw_tmp{1};
        
        if count2>2
            
            if q==1
                raw_final=the_raw;
            else
                raw_final=[raw_final;the_raw];
            end
            
        end
        
        %clear statements
        clear the_raw_tmp; clear the_raw;
        
    end
    
    %counter
    final_count=1;
    
    for a=1:max(raw_final(:,3))
        
        %get a bin
        idx_bin=find(raw_final(:,3)==a);
        
        if numel(idx_bin)>0
            
            the_angle_plot=raw_final(idx_bin,1);
            the_int_plot=raw_final(idx_bin,2);
            
            %plotting
            plot(the_angle_plot,the_int_plot,'r.','LineWidth',4,'MarkerEdgeColor',[0.6,0.6,.6],'MarkerSize',12);
            
            %vaerages for final plot
            avg_plot(final_count,1)=a;
            avg_plot(final_count,2)=mean(the_int_plot);
            
            if final_count==1
                all_angle_ret=the_angle_plot;
                all_int_ret=the_int_plot;
            else
                all_int_ret_tmp=all_int_ret;
                clear all_int_ret;
                all_int_ret=[all_int_ret_tmp;the_int_plot];
                clear all_int_ret_tmp;
                
                all_angle_ret_tmp=all_angle_ret;
                clear all_angle_ret;
                all_angle_ret=[all_angle_ret_tmp;the_angle_plot];
                clear all_angle_ret_tmp;
                
            end
            
            %iterate counte
            final_count=final_count+1;
            
            %clear statement
            clear the_angle_plot; clear the_int_plot;
            
        end
        
        %clear atatement
        clear idx_bin;
        
        
    end
    
    plot(avg_plot(:,1),avg_plot(:,2),'k','LineWidth',1.5);
    xlabel('Angle (deg.)'); ylabel('Intensity');
    
    
else
    
    %single image - returning parameter;
    
    %averages
    avg_plot=int_plot_save;
    
    %raw data
    the_raw_to_ret_tmp=cell_indiv_data(1,2);
    the_raw_to_ret=the_raw_to_ret_tmp{1};
    
    all_int_ret=the_raw_to_ret(:,5);
    all_angle_ret=the_raw_to_ret(:,3);
    
    
    
end





















