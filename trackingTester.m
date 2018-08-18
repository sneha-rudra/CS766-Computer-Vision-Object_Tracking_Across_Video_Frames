function trackingTester(data_params, tracking_params)
    
    mkdir (fullfile(data_params.out_dir));
    stack = cell(length(data_params.frame_ids),1);
    for i = 1:length(data_params.frame_ids)
        im = imread(fullfile(data_params.data_dir, data_params.genFname(data_params.frame_ids(i))));
        stack{i} = im2double(im);
    end
    
    
    img = stack{1};    
    img = drawBox(img, tracking_params.rect, [0, 0, 255], 3);
    imwrite(img, fullfile(data_params.out_dir,data_params.genFname(data_params.frame_ids(1))));
   
    
    target = img(tracking_params.rect(2):tracking_params.rect(2)+tracking_params.rect(4),tracking_params.rect(1):tracking_params.rect(1) + tracking_params.rect(3),:);
    
    
    [tind,tmap] = rgb2ind(target,tracking_params.bin_n);
    thist = imhist(tind(:), tmap);
    
    
    for id = data_params.frame_ids(1)+1:data_params.frame_ids(1)+length(data_params.frame_ids)-1 
       
       img = stack{id};
      
       if (id == data_params.frame_ids(1)+1)
           
           ty_min = max(1,(tracking_params.rect(2)+tracking_params.rect(4)/2) - tracking_params.search_half_window_size);
           ty_max = min((tracking_params.rect(2)+tracking_params.rect(4)/2) + tracking_params.search_half_window_size, size(img,1));
     
           tx_min = max(1,(tracking_params.rect(1)+round(tracking_params.rect(3)/2)) - tracking_params.search_half_window_size);
           tx_max = min(size(img,2), (tracking_params.rect(1)+round(tracking_params.rect(3)/2)) + tracking_params.search_half_window_size);
           
           window = img(ty_min:ty_max, tx_min:tx_max,:);
           
       else
           
           ty_min = max(1,(rbox(2)+round(tracking_params.rect(4)/2)) - tracking_params.search_half_window_size);
           ty_max = min(size(img,1), (rbox(2)+round(tracking_params.rect(4)/2)) + tracking_params.search_half_window_size);
           
           tx_min = max(1,(rbox(1)+round(tracking_params.rect(3)/2)) - tracking_params.search_half_window_size);
           tx_max = min(size(img,2), (rbox(1)+round(tracking_params.rect(3)/2)) + tracking_params.search_half_window_size);
           
           window = img(ty_min:ty_max, tx_min:tx_max,:);
       end
       
       figure(), imshow(window)
       
       corr = []; lxy = [];
       
       for i = 1 : size(window,2)-tracking_params.rect(3)
            for j = 1 : size(window,1)-tracking_params.rect(4)
 
              
                tymax = j+tracking_params.rect(4)-1;
                tymin = j;
                
                if (tymax > size(window,1))
                    tymin = min(size(window,1), tymax) - tracking_params.rect(4);
                end
                tymax = min(size(window,1), tymax);

                if (tymin < 0)
                    tymax = max(0, tymin) + tracking_params.rect(4);
                end
                tymin = max(0, tymin);
                
                
                
                
                txmax = i+tracking_params.rect(3)-1;
                txmin = i;
                
                if (txmax > size(window,2))
                    txmin = min(size(window,2), txmax) - tracking_params.rect(3);
                end
                txmax = min(size(window,2), txmax);
                
                if (txmin < 0)
                    txmax = max(0,txmin) + tracking_params.rect(3);
                end
                txmin = max(0,txmin);
                
                
                
                                
                template = window(tymin:tymax, txmin:txmax,:);
                
                
                [tempInd,~] = rgb2ind(template,tracking_params.bin_n);
                img_hist = imhist(tempInd(:), tmap);

                muh1 = mean(thist); muh2 = mean(img_hist);

                tmp_corr = (sum((thist-muh1).*(img_hist-muh2)))/(sqrt(sum((thist-muh1).^2))*sqrt(sum((img_hist-muh2).^2)));
                
                lxy = [lxy; i j];
                corr = [corr abs(tmp_corr)];

            end
       end
       [~,mci] = max(corr);
        
       
        
        if id == data_params.frame_ids(1)+1
            rbox = double([0,0,0,0]);
            rbox(1) = ((tracking_params.rect(1)+ tracking_params.rect(3)/2) - tracking_params.search_half_window_size) + lxy(mci,1); 
            rbox(2) = ((tracking_params.rect(2)+round(tracking_params.rect(4)/2)) - tracking_params.search_half_window_size) + lxy(mci,2);
            rbox(3) = tracking_params.rect(3);
            rbox(4) = tracking_params.rect(4);

        else
            rbox = double([0,0,0,0]);
            rbox(1) = ((tracking_params.rect(1)+ tracking_params.rect(3)/2) - tracking_params.search_half_window_size) + lxy(mci,1); 
            rbox(2) = ((tracking_params.rect(2)+round(tracking_params.rect(4)/2)) - tracking_params.search_half_window_size) + lxy(mci,2);
            rbox(3) = tracking_params.rect(3);
            rbox(4) = tracking_params.rect(4);

        end
        img = drawBox(img, rbox, [0, 0, 255], 3);
        imwrite(img, fullfile(data_params.out_dir, data_params.genFname(data_params.frame_ids(id))));
    end
    

    
close all;
end

