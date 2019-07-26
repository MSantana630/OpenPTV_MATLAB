%Created by Michael Alejandro Santana
%As supporting code towards his masters thesis in Mechanical Engineering at
%CSU Sacramento,CA. 

%This is provided as a teaching aid so that interested parties are able to
%quickly create a meaningful plots and finish
%the OpenPTV->FlowTracks->MATLAB workflow.

%readh5file.m is expecting a location of a "xxx.h5" file formatted by
%FLowTracks which processed the 'ptv_is' data created in OpenPTV.

%use the info command to use the workspace and manually search for the
%data within all the arrays. 

%info = hdf5info('minlength50traj2.h5');

%once the data is found within the "xxx.h5" file, most likely only
%'/particles', then we access this by using the 'h5read' command.

data = h5read('minlength25traj2.h5','/particles');

time = data.time;
velocity = data.velocity;
trajid = data.trajid;
position = data.pos;
acceleration = data.accel;

%make id into a row vector with double data type
id = double(transpose(trajid));
frametime = double(transpose(time));

%PVID == PositionVelocityID = [X,Y,ID,U,V.frametime] This contains all the
%data needed to plot.

idpos = vertcat(position,id);
PVID= sortrows(vertcat(idpos,velocity,frametime)',4)';
%PAID= sortrows(vertcat(idpos,acceleration,frametime)',4)';

%sort PAID via ID's in ascending order

% [~,idsort]=sort(PAID(4,:));
% PAID =PAID(:,idsort);

IDrow = PVID(4,1:length(PVID)); 
IDrowcount = unique(IDrow); 
res = histc(IDrow,IDrowcount);
trajectories = vertcat(IDrowcount,res);

fprintf('We have %d trajectories in our PVID array\n',length(trajectories));

%clear vars when done creating PVID
clear 'newarray' 'data' 'frametime' 'id' 'idpos' 'position' 'time' 'trajid'
clear 'velocity' 'idsort' 'IDrow' 'IDrowcount' 'res' 'trajectories' 'acceleration'
disp('Cleared all variables in readh5file.m except PVID');
