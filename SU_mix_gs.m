% <span style="font-size:18px;">%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%Author: Ziheng H. Shen @Tsinghua Univ.  
%HybridGaussModel @Digital Image Process Practice  
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
clc;  
cd '...'
cntFrame = 500;  
% obj = VideoReader('768x576.avi');  
% numFrames = obj.NumberOfFrames;  
%  for k = 1 : cntFrame  
%      frame = read(obj,k);  
%       imwrite(frame,...  
%           strcat('C:\Users\Zi-Heng Shen\Documents\MATLAB\BackGroundModel\��ϸ�˹������ģ\',...  
%           num2str(k),'.bmp'),'bmp');  
%  end  
%% �������弰��ʼ��  
I = imread('seq00.avi0001.bmp');                    %�����һ֡��Ϊ����֡  
fr_bw = I;       
[height,width] = size(fr_bw);           %��ÿ֡ͼ���С  
width = width/3;                        %�ų���ɫͨ����  
fg = zeros(height, width);              %����ǰ���ͱ�������  
bg_bw = zeros(height, width);  
  
C = 3;                                  % ����˹ģ�͵ĸ���(ͨ��Ϊ3-5)  
M = 3;                                  % ��������ģ�͸���  
D = 2.5;                                % ƫ����ֵ  
alpha = 0.01;                           % ѧϰ��  
thresh = 0.25;                          % ǰ����ֵ  
sd_init = 15;                           % ��ʼ����׼��  
w = zeros(height,width,C);              % ��ʼ��Ȩ�ؾ���  
mean = zeros(height,width,C);           % ���ؾ�ֵ  
sd = zeros(height,width,C);             % ���ر�׼��  
u_diff = zeros(height,width,C);         % ������ĳ����˹ģ�;�ֵ�ľ��Ծ���  
p = alpha/(1/C);                        % ��ʼ��p�������������¾�ֵ�ͱ�׼��  
rank = zeros(1,C);                      % ������˹�ֲ������ȼ���w/sd)  
  
pixel_depth = 8;                        % ÿ������8bit�ֱ���  
pixel_range = 2^pixel_depth -1;         % ����ֵ��Χ[0,255]  
  
for i=1:height  
    for j=1:width  
        for k=1:C  
            mean(i,j,k) = rand*pixel_range;     %��ʼ����k����˹�ֲ��ľ�ֵ  
            w(i,j,k) = 1/C;                     % ��ʼ����k����˹�ֲ���Ȩ��  
            sd(i,j,k) = sd_init;                % ��ʼ����k����˹�ֲ��ı�׼��             
        end  
    end  
end  
  
for n = 1:cntFrame  
%     frame=strcat(num2str(n),'.bmp');  
    if n<10
        frame = sprintf('seq00.avi000%d.bmp',n); % ����ʵ��ͼƬ������Ϣ�����޸�
    elseif n<100
        frame = sprintf('seq00.avi00%d.bmp',n);
    else
        frame = sprintf('seq00.avi0%d.bmp',n);
    end
    I1 = imread(frame);  % ���ζ����֡ͼ��  
    fr_bw = I1;         
    % �������������m����˹ģ�;�ֵ�ľ��Ծ���  
    for m=1:C  
        u_diff(:,:,m) = abs(double(fr_bw(:,:,m)) - double(mean(:,:,m)));  
    end  
    % ���¸�˹ģ�͵Ĳ���  
    for i=1:height  
        for j=1:width  
            match = 0;                                       %ƥ����;  
            for k=1:C                         
                if (abs(u_diff(i,j,k)) <= D*sd(i,j,k))       % �������k����˹ģ��ƥ��    
                    match = 1;                               %��ƥ������Ϊ1  
                    % ����Ȩ�ء���ֵ����׼�p  
                    w(i,j,k) = (1-alpha)*w(i,j,k) + alpha;  
                    p = alpha/w(i,j,k);                    
                    mean(i,j,k) = (1-p)*mean(i,j,k) + p*double(fr_bw(i,j));  
                    sd(i,j,k) =   sqrt((1-p)*(sd(i,j,k)^2) + p*((double(fr_bw(i,j)) - mean(i,j,k)))^2);  
                else                                         % �������k����˹ģ�Ͳ�ƥ��  
                    w(i,j,k) = (1-alpha)*w(i,j,k);           %��΢����Ȩ��     
                end  
            end        
            bg_bw(i,j)=0;  
            for k=1:C  
                bg_bw(i,j) = bg_bw(i,j)+ mean(i,j,k)*w(i,j,k);  
            end  
            % ����ֵ����һ��˹ģ�Ͷ���ƥ�䣬�򴴽��µ�ģ��  
            if (match == 0)  
                [min_w, min_w_index] = min(w(i,j,:));      %Ѱ����СȨ��  
                mean(i,j,min_w_index) = double(fr_bw(i,j));%��ʼ����ֵΪ��ǰ�۲����صľ�ֵ  
                sd(i,j,min_w_index) = sd_init;             %��ʼ����׼��Ϊ6  
            end  
            rank = w(i,j,:)./sd(i,j,:);                    % ����ģ�����ȼ�  
            rank_ind = [1:1:C];%���ȼ�����         
            % ����ǰ��        
            fg(i,j) = 0;  
            while ((match == 0)&&(k<=M))           
                    if (abs(u_diff(i,j,rank_ind(k))) <= D*sd(i,j,rank_ind(k)))% �������k����˹ģ��ƥ��  
                        fg(i,j) = 0; %������Ϊ��������Ϊ��ɫ          
                    else  
                        fg(i,j) = 255;    %����Ϊǰ������Ϊ��ɫ   
                    end                          
                k = k+1;  
            end  
        end  
    end  
    se = strel('disk',2);
    se2 = strel('line',6,90);
    se3 = strel('line',6,0);
    se4 = strel('disk',25);
%     se5 = strel('line',25,0);
    
    BW = imdilate(fg,se);
    BW2 = imerode(BW,se2);
    BW3 = imerode(BW2,se3);
    BW4 = imclose(BW3,se4);
    [L,num]=bwlabel(BW4);
    STATS = regionprops(L,'BoundingBox');
%     BW5 = imclose(BW3,se5);

    if n>330 & mod(n,5)==0 & n<355
        figure,
        imshow(frame) ,title(sprintf('��ϸ�˹����frame number %d',floor(n)));
        for i = 1:num
                rectangle('Position',STATS(i).BoundingBox,'EdgeColor','r');
        end
    end
    if n>430 & mod(n,5)==0 & n<455
        figure,
        imshow(frame) ,title(sprintf('��ϸ�˹����frame number %d',floor(n)));
        for i = 1:num
                rectangle('Position',STATS(i).BoundingBox,'EdgeColor','r');
        end
    end
    if n==340 | n==345 | n==350 | n==410 | n==415
        figure,
        imshow(fg) ,title(sprintf('��ϸ�˹����frame number %d',floor(n)));
    end
    if n==340 | n==345 | n==350 | n==410 | n==415 
        figure,
        imshow(BW4) ,title(sprintf('��ϸ�˹����frame number %d',floor(n)));
    end



%     imshow(frame);title(sprintf('��ϸ�˹����frame number %d',floor(n)));
%     for i = 1:num
%         rectangle('Position',STATS(i).BoundingBox,'EdgeColor','r');
%     end
    pause(0.000001);
%     %��ʾǰ�� imsh
end
% </span>