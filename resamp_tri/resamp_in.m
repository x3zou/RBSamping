
%datafilename    = '/Volumes/DriveThree/Imperial/T84/int_050821_050925/geo_new.unw';
%losfilename     = '/Volumes/DriveThree/Imperial/T84/int_050821_050925/geo_incidence.unw';

%faultfilename   = {'/Volumes/DriveThree/Imperial/T84/int_050821_050925/resample_fault.mat'};
%demfilename= '';
%savestructname = '050821_050925.mat';
%savexyname      = '';  %Output ascii xyfile name (or null)

%scaleval     = 5;     % used during 0-paddding to size = power of 2
%zone         = '11S';  % zone = 0 forces data loading to check zone
%azo          = 0;      % 1 if using azimuth offsets instead of interferogram
%const_los    = 0;      % if no los file (may be broken)
%limitny      = 0;      % option in load_any_data -usually 0
%minhgt       = 200;    % hgt cutoff to use in hgt scaling (only if demfile is set)
%maskdist     = 10e3;    % distance around fault trace to mask data, m
%throwout     = 10;      % throw out resamp boxes with < throwout percent points

%Lp          = 10;
%Wp          = 10;
%maxnp       = 1100;     % maximum # points in resampling (could end up as a few more)
%smoo        = 1;
%xzone       = [];
%yzone       = [];

%getcov      = 2;       %1 is just diag, 2 is full cov



scaleval     = 0;     % used during 0-paddding to size = power of 2, default 5
zone         = '43N';  % zone = 0 forces data loading to check zone
azo          = 0;      % 1 if using azimuth offsets instead of interferogram
const_los    = 0;      % if no los file (may be broken)
limitny      = 0;      % option in load_any_data -usually 0
minhgt       = 200;    % hgt cutoff to use in hgt scaling (only if demfile is set)
maskdist     = 10e3;    % distance around fault trace to mask data, m
throwout     = 10;      % throw out resamp boxes with < throwout percent points

Lp          = 10; %km
Wp          = 10; %km
maxnp       = 850;     % maximum # points in resampling (could end up as a few more)
smoo        = 1;
xzone       = [];
yzone       = [];

getcov      = 2;       %1 is just diag, 2 is full cov
%N           = 0;
