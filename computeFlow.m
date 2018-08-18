function result = computeFlow(img1, img2, win_radius, template_radius, grid_MN)

    img1 = im2double(img1);
    img2 = im2double(img2);
    img2 = padarray(img2,[win_radius win_radius]);
  
    inc = size(img1)./grid_MN;  
  
    
    [X,Y] = meshgrid(1:inc(1,1):size(img1,1), 1:inc(1,2):size(img1,2));
    x = zeros(size(X));
    y = zeros(size(X));
    u = zeros(size(X));
    v = zeros(size(X));
    for i = 1:1:size(X,1)
        for j = 1:1:size(X,2)
            x(i,j) = X(i,j);
            y(i,j) = Y(i,j);
        end
    end   
    
    
    k = 0;
    for i = template_radius+1 : inc(1,2) : size(img1,2)-template_radius-1
       for j = template_radius+1 : inc(1,1) : size(img1,1)-template_radius-1
           
           k = k+1;

           template = img1(j-template_radius : j+template_radius, i-template_radius : i+template_radius);
           A = img2(j:j+2*win_radius, i:i+2*win_radius);
           
           C = normxcorr2(template, A);
           
           [~,val] = max(C(:));
           [corry, corrx] = ind2sub(size(C),val);

           u(k) = (i + corrx - template_radius) - (win_radius + 1) - i;
           v(k) = (j + corry - template_radius) - (win_radius + 1) - j;
           
           x(k) = i;
           y(k) = j;
       end
    end
    
    fh1 = figure;
    imshow(img1), hold on
    quiver(x,y,u,v,'linewidth', 2);
    annotated_img = saveAnnotatedImg(fh1);
    result = annotated_img;
end

%%
function annotated_img = saveAnnotatedImg(fh)
figure(fh); 

% The figure needs to be undocked
set(fh, 'WindowStyle', 'normal');

% The following two lines just to make the figure true size to the
% displayed image. The reason will become clear later.
img = getimage(fh);
truesize(fh, [size(img, 1), size(img, 2)]);

% getframe does a screen capture of the figure window, as a result, the
% displayed figure has to be in true size. 
frame = getframe(fh);
frame = getframe(fh);
pause(0.5); 
% Because getframe tries to perform a screen capture. it somehow 
% has some platform depend issues. we should calling
% getframe twice in a row and adding a pause afterwards make getframe work
% as expected. This is just a walkaround. 
annotated_img = frame.cdata;
end
