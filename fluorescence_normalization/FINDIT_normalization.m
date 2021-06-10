close all;
clear all;

%Instructions to run this code:
%After pressing run, first select the uniform fluorescent sample image.
%Then a new file selection window will popup- select the buffer-filled
%cartridge image. For the final file selection window, select all the
%experimental images to be analyzed. The code will read each image,
%normalize the images and calculate the mean ROI intensities of each channel
%of the cartridge which is stored in a matrix called 'intensity'. 


timepoints=360; %number of timepoints

%Read uniform fluorescent sample image
[name1, place1]= uigetfile('C:\Wainamics ncr\Data_042221\*.tiff');
%current_name=cell2mat(name1);
if isequal(name1,0)
   disp('User selected Cancel');
else
   disp('User selected uniform fluorescent sample image');
end
image1=imread(fullfile(place1, name1));
uni=double(image1);
uni_norm = uni./mean2(uni);

%Read buffer-filled cartridge image
[name2, place2]= uigetfile('C:\Wainamics ncr\Data_042221\*.tiff');
if isequal(name2,0)
   disp('User selected Cancel');
else
   disp('User selected buffer-filled cartridge image');
end
image2=imread(fullfile(place2, name2));
buf_cart= double(image2);

%Get all experimental images
[name, place]= uigetfile('C:\Wainamics ncr\Data_042221\20210422_Csm6_Ct24_Clinical-20210423T015853Z-001\20210422_Csm6_Ct24_Clinical\*.tiff','Select One or More Files', ...
    'MultiSelect', 'on');
if isequal(name,0)
   disp('User selected Cancel');
elseif isequal(length(name),timepoints)
   disp('User selected all experimental images');
else 
   disp('User did not select all experimental images');
end
name = sortrows(name);

[c,Nfile]=size(name);

Imatrix = [];
%Input the ROI x and y coordinates for each channel of the cartridge
c1_recx1= 198; %x-coordinate of the top left corner of channel 1 ROI
c1_recx2= c1_recx1+150;
c1_recy1= 298;%y-coordinate of the top left corner of channel 1 ROI 
c1_recy2= c1_recy1+400;
c2_recx1= 718;%x-coordinate of the top left corner of channel 2 ROI
c2_recx2= c2_recx1+150;
c2_recy1= 304;%y-coordinate of the top left corner of channel 2 ROI 
c2_recy2= c2_recy1+400;
c3_recx1= 1178;%x-coordinate of the top left corner of channel 3 ROI
c3_recx2= c3_recx1+150;
c3_recy1= 306;%y-coordinate of the top left corner of channel 3 ROI 
c3_recy2= c3_recy1+400;


if Nfile >= 1
        % Read all images and store in a cell array
        for i= 1: Nfile
            images{i} = imread(fullfile(place, name{i}));
        end
        Imatrix = cat(3, Imatrix, images);%concatenate all images in a folder into a 3D matrix
        for f = 1 : Nfile
            Z= Imatrix(f); %Read each image from the concatenated 3d matrix
            Z=cell2mat(Z);
            Z0= double(Z); %Convert uint16 to double
            I_buf_subtracted = Z0 - buf_cart; %Subtract buffer-filled cartridge image
            I_norm = I_buf_subtracted./uni_norm; %Divide by uniform fluorescent sample image

            
            rawc1_roi(:,:,f)= Z0(c1_recy1:c1_recy2,c1_recx1:c1_recx2); %submatrix of chosen ROI intensities from uncorrected image channel 1
            rawc2_roi(:,:,f)= Z0(c2_recy1:c2_recy2,c2_recx1:c2_recx2); %submatrix of chosen ROI intensities from uncorrected image channel 2
            rawc3_roi(:,:,f)= Z0(c3_recy1:c3_recy2,c3_recx1:c3_recx2); %submatrix of chosen ROI intensities from uncorrected image channel 3
                     
            norm1_roi(:,:,f)= I_norm(c1_recy1:c1_recy2,c1_recx1:c1_recx2); %submatrix of chosen ROI intensities from normalized image channel 1
            norm2_roi(:,:,f)= I_norm(c2_recy1:c2_recy2,c2_recx1:c2_recx2); %submatrix of chosen ROI intensities from normalized image channel 2
            norm3_roi(:,:,f)= I_norm(c3_recy1:c3_recy2,c3_recx1:c3_recx2); %submatrix of chosen ROI intensities from normalized image channel 3            
        end
end

raw1=[];
raw2=[];
raw3=[];
norm1=[];
norm2=[];
norm3=[];
for f = 1 : Nfile
    raw1(f)= mean(rawc1_roi(:,:,f), 'all'); %mean intensity of ROI from uncorrected image channel 1
    raw2(f)= mean(rawc2_roi(:,:,f), 'all'); %mean intensity of ROI from uncorrected image channel 2
    raw3(f)= mean(rawc3_roi(:,:,f), 'all'); %mean intensity of ROI from uncorrected image channel 3
    norm1(f)= mean(norm1_roi(:,:,f), 'all'); %mean intensity of ROI from normalized image channel 1
    norm2(f)= mean(norm2_roi(:,:,f), 'all'); %mean intensity of ROI from normalized image channel 2
    norm3(f)= mean(norm3_roi(:,:,f), 'all'); %mean intensity of ROI from normalized image channel 3
end

intensity = zeros(360,10);
x1=linspace(0,60,360);%1D array of times of image acquisition in seconds
intensity (:,1)= x1';
intensity(:,2)= raw1';
intensity(:,3)= raw2';
intensity(:,4)= raw3';
intensity(:,5)= norm1';
intensity(:,6)= norm2';
intensity(:,7)= norm3';
intensity(:,8)= raw1'/intensity(1,2);
intensity(:,9)= raw2'/intensity(1,3);
intensity(:,10)= raw3'/intensity(1,4);
intensity(:,11)= norm1'/intensity(1,5);
intensity(:,12)= norm2'/intensity(1,6);
intensity(:,13)= norm3'/intensity(1,7);
