%% R-based sampling, itertively based on the best-fitting model.
%% To plot them separately, go to plot_tri_output.m
%% Xiaoyu Zou, 05/28/2024
clear
addpath('/Volumes/T7/Research/PamirProject/Resample_Lohman/Mesh2d')
%% Save the output or not 
save = 0; % 0: don't save the output; 1: save the output
iint=4;%number of iterations
data_type = 2; %1: ascending: 850 ; 2: descending: 700 max np
dir='/Volumes/T7/Research/PamirProject/real_data/SEN/';%path to loading and saving data


%% Create a fault structure (remember to update those parameters once you start a new iteration!)
faultstruct=struct();
faultstruct.strike=23.45;%degree
faultstruct.L=26.27e3; %m, default 25.57e3
faultstruct.W=10.72e3; %m, default 5e3
faultstruct.dip=74.31;%degree
faultstruct.zt=2.02e3;%m, downword positive
faultstruct.vertices=[4.72e3,8.04e3];%midpoint of the fault, m

%% Load the data
if data_type == 1
    data = [dir,'asc/sen_asc_los_ll.grd'];
    model = [dir,'asc/model',num2str(iint),'.txt'];
    lke = [dir,'asc/look/look_e.grd'];
    lkn = [dir,'asc/look/look_n.grd'];
    lku = [dir,'asc/look/look_u.grd'];
end

if data_type == 2
    data = [dir,'des/sen_asc_los_ll.grd'];
    model = [dir,'des/model',num2str(iint),'.txt'];
    lke = [dir,'des/look/look_e.grd'];
    lkn = [dir,'des/look/look_n.grd'];
    lku = [dir,'des/look/look_u.grd'];
end



%% Define some input parameters
resamp_in



%% Create a data structure
% Convert X and Y into utm coordinates!! Check Ellis code for routines
% ref_point: (73.1603,38.1025), UTM zone: 43
[x,y,Z]=grdread2(data);
model = importdata(model);
[X,Y]=meshgrid(x,y);
[xo,yo]=ll2xy(73.1603,38.1025,73.1603);
X=X(:);
Y=Y(:);


[X,Y]=ll2xy(X,Y,73.1603);
X=(X-xo);
Y=(Y-yo);
X=reshape(X,length(y),length(x));
Y=reshape(Y,length(y),length(x));
model = reshape(model,length(x),length(y)).';
[~,~,look_e]=grdread2(lke);
[~,~,look_n]=grdread2(lkn);
[~,~,look_u]=grdread2(lku);
datastruct=struct();
datastruct.scale=2; % default: 2
datastruct.hgt=[];
datastruct.X = X;
datastruct.Y = Y;
datastruct.newX=X;%X after filtering out the region with highly bad pixels
datastruct.newY=Y;%Y after filtering out the region with highly bad piexels
datastruct.data = Z;
datastruct.nx = length(x);
datastruct.ny = length(y);
datastruct.S = cat(3,look_e,look_n,look_u);
datastruct.model = model;
datastruct.sampled_ori_data=Z;


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
[resampstruct,res,rhgt] = resampler_tri_BF(datastruct,patchstruct,faultstruct);
%Var                = var(res(isfinite(res)));
%datastd            = Var./sqrt([resampstruct.count]);

%% Plot the sampled data
%X = [resampstruct.X];
X = [resampstruct.newX];
X= X/1e3;
%Y = [resampstruct.Y];
Y = [resampstruct.newY];
Y = Y/1e3;
data = [resampstruct.data];
S = [resampstruct.S];
X = X';
Y = Y';
data = data';
S = S';
data_std = [resampstruct.data_std]';

sampled_ori_data = [resampstruct.sampled_ori_data]';

figure()
scatter(X,Y,20,sampled_ori_data,'filled');
colormap jet
colorbar
title('Resolution and Model based Sampling')
xlabel('km')
ylabel('km')

figure()
scatter(X,Y,20,data,'filled');
colormap jet
colorbar
title('Sampled Model')
xlabel('km')
ylabel('km')


%% Save the X,Y,data,looking angle (S). The newest results are saved to resample_tri_BF* directory!

if save ==1

    if data_type == 1 %ascending
        writematrix(X,[dir,'asc/tri_output_BF',num2str(iint),'/X.txt'])
        writematrix(Y,[dir,'asc/tri_output_BF',num2str(iint),'/Y.txt'])
        writematrix(sampled_ori_data,[dir,'asc/tri_output_BF',num2str(iint),'/data.txt'])
        writematrix(S,[dir,'asc/tri_output_BF',num2str(iint),'/look.txt'])
        writematrix(data_std,[dir,'asc/tri_output_BF',num2str(iint),'/data_std.txt'])
    end

    if data_type == 2 %descending
        writematrix(X,[dir,'des/tri_output_BF',num2str(iint),'/X.txt'])
        writematrix(Y,[dir,'des/tri_output_BF',num2str(iint),'/Y.txt'])
        writematrix(sampled_ori_data,[dir,'des/tri_output_BF',num2str(iint),'/data.txt'])
        writematrix(S,[dir,'des/tri_output_BF',num2str(iint),'/look.txt'])
        writematrix(data_std,[dir,'des/tri_output_BF',num2str(iint),'/data_std.txt'])
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

    






