%% R-based sampling for GMTSAR Products
%% To plot them separately, go to plot_tri_output.m
%% Xiaoyu Zou, 05/28/2024
clear
addpath('/Volumes/T7/Research/PamirProject/Resample_Lohman/Mesh2d')
%% Save the output or not 
save = 0; % 0: don't save the output; 1: save the output
dir='/Volumes/T7/Research/PamirProject/real_data/SEN/';%path to loading and saving data

%% Load the data
data_type = 2; %1: ascending: 850 ; 2: descending: 700 max np
if data_type ==1 
    data = [dir,'asc/sen_asc_los_ll.grd'];
    lke = [dir,'asc/look/look_e.grd'];
    lkn = [dir,'asc/look/look_n.grd'];
    lku = [dir,'asc/look/look_u.grd'];
end

if data_type == 2
    data = [dir,'des/sen_asc_los_ll.grd'];
    lke = [dir,'des/look/look_e.grd'];
    lkn = [dir,'des/look/look_n.grd'];
    lku = [dir,'des/look/look_u.grd'];
end



%% Define some input parameters
resamp_in

%% Create a fault structure 
faultstruct=struct();
faultstruct.strike=30.55;%degree
faultstruct.L=25.57e3; %m, default 25.57e3
faultstruct.W=5e3; %m, default 5e3
faultstruct.dip=83.87;%degree
faultstruct.zt=6.86e3;%m, downword positive
faultstruct.vertices=[3.94e3,6.64e3];%midpoint of the fault, m

%% Create a data structure
% Convert X and Y into utm coordinates!! Check Ellis code for routines
% ref_point: (73.1603,38.1025), UTM zone: 43
[x,y,Z]=grdread2(data);
[X,Y]=meshgrid(x,y);
[xo,yo]=ll2xy(73.1603,38.1025,73.1603);
X=X(:);
Y=Y(:);
[X,Y]=ll2xy(X,Y,73.1603);
X=(X-xo);
Y=(Y-yo);
X=reshape(X,length(y),length(x));
Y=reshape(Y,length(y),length(x));
[~,~,look_e]=grdread2(lke);
[~,~,look_n]=grdread2(lkn);
[~,~,look_u]=grdread2(lku);
datastruct=struct();
datastruct.scale=80; % default:2
datastruct.hgt=[];
datastruct.X = X;
datastruct.Y = Y;
datastruct.data = Z;
datastruct.nx = length(x);
datastruct.ny = length(y);
datastruct.S = cat(3,look_e,look_n,look_u);


%% Not sure what this step does, but try it anyway:
%  S=[datastruct.S];
% S1=squeeze(S(:,:,1));
% id=find(S1<0.5);
% disp(length(id));
% S1(id)=NaN;
% 
%  S2=squeeze(S(:,:,2));
%  id=find(S2>0.2); %for S3
% disp(length(id))
% S2(id)=NaN;
%  id=find(S2<0); %for S2
% disp(length(id))
%  S2(id)=NaN;
% 
% S3=squeeze(S(:,:,3));
% id=find(S3<-0.83);
% disp(length(id));
% S3(id)=NaN;
% S(:,:,3)=S3;
% 
% S(:,:,1)=S1;
%  S(:,:,2)=S2;
%  datastruct.S=S;




%% Create a Patch Structure
[patchstruct,totLp,Wp]   = ver2patchconnect(faultstruct,Lp,Wp,length(faultstruct));
xfault                   = [[patchstruct.xfault]']';
yfault                   = [[patchstruct.yfault]']';
zfault                   = [[patchstruct.zfault]']';
id                       = find(zfault(1,:)==min(zfault(1,:)));
xfaultsurf               = xfault(:,id);
yfaultsurf               = yfault(:,id);

%% Perform the Sampling
disp('Beginning resampling')
[resampstruct,res,rhgt] = resampler_tri(datastruct,patchstruct,faultstruct);
%Var                = var(res(isfinite(res)));
%datastd            = Var./sqrt([resampstruct.count]);

%% Plot the sampled data
X = [resampstruct.X];
X= X/1e3;
Y = [resampstruct.Y];
Y = Y/1e3;
data = [resampstruct.data];
S = [resampstruct.S];
X = X';
Y = Y';
data = data';
S = S';
data_std = [resampstruct.data_std]';

figure()
scatter(X,Y,20,data,'filled');
colormap jet
colorbar
title('R-based Sampling')
xlabel('km')
ylabel('km')


%% Save the X,Y,data,looking angle (S). The newest results are saved to tri_output2 directory!

if save ==1

    if data_type == 1 %ascending
        writematrix(X,[dir,'asc/tri_output2/X.txt'])
        writematrix(Y,[dir,'asc/tri_output2/Y.txt'])
        writematrix(data,[dir,'asc/tri_output2/data.txt'])
        writematrix(S,[dir,'asc/tri_output2/look.txt'])
        writematrix(data_std,[dir,'asc/tri_output2/data_std.txt'])
    end

    if data_type == 2 %descending
        writematrix(X,[dir,'des/tri_output2/X.txt'])
        writematrix(Y,[dir,'des/tri_output2/Y.txt'])
        writematrix(data,[dir,'des/tri_output2/data.txt'])
        writematrix(S,[dir,'des/tri_output2/look.txt'])
        writematrix(data_std,[dir,'des/tri_output2/data_std.txt'])
    end

end



%% Cut the data and save the X,Y,data,looking angle (S)

% if save ==1
% 
%     if data_type == 2 %descending
%         polygonX = [-53 51 51 -53 -53];
%         polygonY = [-35 -35 48 48 -35];
%         [in, on] = inpolygon(X, Y, polygonX, polygonY);
%         X_in = X(in);
%         Y_in = Y(in);
%         data_in = data(in);
%         data_std_in = data_std(in);
%         S_in = S(in,:);
%         writematrix(X_in,'/Volumes/T7/Research/PamirProject/real_data/SEN/des/tri_output/X.txt')
%         writematrix(Y_in,'/Volumes/T7/Research/PamirProject/real_data/SEN/des/tri_output/Y.txt')
%         writematrix(data_in,'/Volumes/T7/Research/PamirProject/real_data/SEN/des/tri_output/data.txt')
%         writematrix(S_in,'/Volumes/T7/Research/PamirProject/real_data/SEN/des/tri_output/look.txt')
%         writematrix(data_std_in,'/Volumes/T7/Research/PamirProject/real_data/SEN/des/tri_output/data_std.txt')
%     end
% 
%     if data_type == 1 %ascending
%         polygonX = [-76 79 79 -76 -76];
%         polygonY = [-60 -60 67 67 -60];
%         [in, on] = inpolygon(X, Y, polygonX, polygonY);
%         X_in = X(in);
%         Y_in = Y(in);
%         data_in = data(in);
%         data_std_in = data_std(in);
%         S_in = S(in,:);
%         writematrix(X_in,'/Volumes/T7/Research/PamirProject/real_data/SEN/asc/tri_output/X.txt')
%         writematrix(Y_in,'/Volumes/T7/Research/PamirProject/real_data/SEN/asc/tri_output/Y.txt')
%         writematrix(data_in,'/Volumes/T7/Research/PamirProject/real_data/SEN/asc/tri_output/data.txt')
%         writematrix(S_in,'/Volumes/T7/Research/PamirProject/real_data/SEN/asc/tri_output/look.txt')
%         writematrix(data_std_in,'/Volumes/T7/Research/PamirProject/real_data/SEN/asc/tri_output/data_std.txt')
%     end
% 
% end

    






