%Created by Michael Alejandro Santana
%As supporting code towards his masters thesis in Mechanical Engineering at
%CSU Sacramento,CA. 

%This code has no owner, it is provided as a teaching aid so that
%interested parties are able to quickly create a meaningful plot and finish
%the OpenPTV->FlowTracks->MATLAB workflow.

%It is assumed that readh5file.m, TrajectoryLinking.m, and
%LinkErrorCheck.m have been run at  this point. and all the necessary arrays
%are loaded in the MATLAB Workspace.

%%% Here we create our linear velocity component to colorize the data
%%% depending on which iteration of the PVID array you have. You dont even
%%% need to do any linking or interpolation, just use the original PVID
%%% array and move forward with plotting!

%LinkedPVID=PVID;
%accel=PAID(5:6,:);
LinkedPVID=sortedNewPVID;
k=1;
for i = 1:length(LinkedPVID)
linvel(k) = (LinkedPVID(5,i)^2+LinkedPVID(6,i)^2)^(1/2);
k=k+1;
end
% stdlinvel=std(linvel);
vbulk=0.4;%bulk vel 0.4mm/s
linvel = linvel ./vbulk;
sPVID=vertcat(LinkedPVID,linvel);
uvel=LinkedPVID(5,:);
vvel=LinkedPVID(6,:);
%sPVID=vertcat(sPVID,uvel,vvel);

%sPVID=vertcat(sPVID,accel);

%Below we are doing a normal distribution of the velocities to truncate the
%outlying values allowing us to scale the colors better
veltest=linvel;
pd=makedist('Normal',mean(veltest),std(veltest));
veltestpdf=pdf(pd,veltest);
A=icdf(pd,0.9999);

% scatter(veltest,veltestpdf)

upd=makedist('Normal',mean(uvel),std(uvel));
uveltestpdf=pdf(upd,uvel);
B=icdf(upd,0.9999);
BB=icdf(upd,0.0001);

vpd=makedist('Normal',mean(vvel),std(vvel));
vveltestpdf=pdf(vpd,vvel);
C=icdf(vpd,0.9999);
CC=icdf(vpd,0.0001);

axpd=makedist('Normal',mean(accel(1,:)),std(accel(1,:)));
accelpdf=pdf(axpd,accel(1,:));
D=icdf(axpd,0.99);
DD=icdf(axpd,0.01);
%scatter(accel(1,:),accelpdf)
aypd=makedist('Normal',mean(accel(2,:)),std(accel(2,:)));
accelpdf2=pdf(aypd,accel(2,:));
E=icdf(aypd,0.9);
EE=icdf(aypd,0.1);

%%%Extract Trajectories Based off Time%%%
%Here we are extracting trajectories from sPVID between j=12500:12700 and
%saving them in an array. These values can be changed to any frame span one
%chooses. Please remember to change the name of the array you are saving so
%that it makes sense.

k=1;
for i=1:length(sPVID)
    for j=10001:11000
        if sPVID(8,i) == j
            Flow10001_11000(1:9,k) = sPVID(1:9,i);
            k=k+1;
        end
    end
end
%%%CREATE PLOT
%This section takes our previously created array 'Flow10001_11000' and the
%unique id values in the fourth row of 'Flow10001_11000'. These are set to
%arg and ids, respectfully, in the first three lines of the proceeding
%code.


fig=gcf;clf
arg= Flow10001_11000;
ids = unique(arg(4,:));
a = colormap(jet); %we set the color map, Blue = slow, Red = fast.
for i = 1:numel(ids)
    x = arg(1, arg(4,:) == ids(i));
    y = arg(2, arg(4,:) == ids(i));
    z = zeros(size(x)); %our 2D case has zeros for the z points
    col = arg(9, arg(4,:) == ids(i));  % This is the color set by our
    %velocity above
%we utilize a surface plot because it already handles our desire to
%colorize our plots quite well with no added changes.
    surface([x;x],[y;y],[z;z],[col;col],...
        'facecol','no',...
        'edgecol','interp',...
        'linew',1);
    hold on
%Here we get rid of as much erroneous white space
%     xlimit(1) = min(min(x), xlimit(1));
%     xlimit(2) = max(max(x), xlimit(2));
%     ylimit(1) = min(min(y), ylimit(1));
%     ylimit(2) = max(max(y), ylimit(2));
end
hold off
%This is the color bar on the right hand side of the plot
caxis([0 A]);
colorbar;
xlim([0.1 2.4])
ylim([-0.27 1.4])
h = colorbar;
ylabel(h,'|vel| /Vel_{bluk}','fontsize',12,'fontweight','bold')
set(gca,'fontsize',12,'fontweight','bold');
title('Frames 1 to 1000','fontsize',12,'fontweight','bold')
ylabel('Y (mm)','fontsize',12,'fontweight','bold')
xlabel('X (mm)','fontsize',12,'fontweight','bold')
set(fig.Children, ...
    'FontName',     'Times', ...
    'FontSize',     12);
%scaling
%this scaling allows you to export a large scaled image
fig.Units = 'centimeters';
fig.Position(3)= 8;
fig.Position(4)= 6;
%export png
%remember to change 'img/' to a folder within you default directory,
%possibly 'bin' within your MATLAB installation. We save as a high quality
%PNG file with a DPI set to 600. Alternatively you can save in any image
%format you wish. 
print(['img/final/velocityplots/' 'linvel_1000'],'-dpng','-r600')


%This should be enough to get a plot showing trajectories and colorizing
%them. Below is duplicated code you can fill in to separate the u and v
%components of velocity, as well as acceleration components below.

%%%%%%%  U V Plotting %%%%%%
fig=gcf;clf
arg= Flow10500_10750;
ids = unique(arg(4,:));

a = colormap(jet); %we set the color map, Blue = slow, Red = fast.
for i = 1:numel(ids)
    x = arg(1, arg(4,:) == ids(i));
    y = arg(2, arg(4,:) == ids(i));
    z = zeros(size(x)); %our 2D case has zeros for the z points
    col = arg(6, arg(4,:) == ids(i));  % This is the color set by our
    %velocity above
%we utilize a surface plot because it already handles our desire to
%colorize our plots quite well with no added changes.
    surface([x;x],[y;y],[z;z],[col;col],...
        'facecol','no',...
        'edgecol','interp',...
        'linew',1);
    hold on
%Here we get rid of as much erroneous white space
%     xlimit(1) = min(min(x), xlimit(1));
%     xlimit(2) = max(max(x), xlimit(2));
%     ylimit(1) = min(min(y), ylimit(1));
%     ylimit(2) = max(max(y), ylimit(2));
end
hold off
%This is the color bar on the right hand side of the plot
caxis([BB B]);
colorbar;
xlim([0.1 2.4])
ylim([-0.27 1.4])
h = colorbar;
set(gca,'fontsize',12,'fontweight','bold');
ylabel(h,'v/Vel_{bluk}','fontsize',12,'fontweight','bold')
title('Frames 500 to 750','fontsize',12,'fontweight','bold')
ylabel('Y (mm)','fontsize',12,'fontweight','bold')
xlabel('X (mm)','fontsize',12,'fontweight','bold')
set(fig.Children, ...
    'FontName',     'Times', ...
    'FontSize',     12);
%scaling
%this scaling allows you to export a large scaled image
fig.Units = 'centimeters';
fig.Position(3)= 8;
fig.Position(4)= 6;
%export png
%remember to change 'img/' to a folder within you default directory,
%possibly 'bin' within your MATLAB installation. We save as a high quality
%PNG file.
print(['img/final/velocityplots/' 'vFlow500_750'],'-dpng','-r600')

%%%%%%%  Acceleration Plotting %%%%%%
fig=gcf;clf
arg= Flow10000_10100;
ids = unique(arg(4,:));

a = colormap(jet); %we set the color map, Blue = slow, Red = fast.
xlimit = [100 -100];
ylimit = xlimit;
for i = 1:numel(ids)
    x = arg(1, arg(4,:) == ids(i));
    y = arg(2, arg(4,:) == ids(i));
    z = zeros(size(x)); %our 2D case has zeros for the z points
    col = arg(13, arg(4,:) == ids(i));  % This is the color set by our
    %velocity above
%we utilize a surface plot because it already handles our desire to
%colorize our plots quite well with no added changes.
    surface([x;x],[y;y],[z;z],[col;col],...
        'facecol','no',...
        'edgecol','interp',...
        'linew',1);
    hold on
%Here we get rid of as much erroneous white space
%     xlimit(1) = min(min(x), xlimit(1));
%     xlimit(2) = max(max(x), xlimit(2));
%     ylimit(1) = min(min(y), ylimit(1));
%     ylimit(2) = max(max(y), ylimit(2));
end
hold off
%This is the color bar on the right hand side of the plot
caxis([EE E]);
colorbar;
xlim(xlimit)
ylim(ylimit)
h = colorbar;
set(gca,'fontsize',12,'fontweight','bold');
ylabel(h,'a_{y}','fontsize',12,'fontweight','bold')
title('Frames 1 to 100','fontsize',12,'fontweight','bold')
ylabel('Y (mm)','fontsize',12,'fontweight','bold')
xlabel('X (mm)','fontsize',12,'fontweight','bold')
set(fig.Children, ...
    'FontName',     'Times', ...
    'FontSize',     12);
%scaling
%this scaling allows you to export a large scaled image
fig.Units = 'centimeters';
fig.Position(3)= 8;
fig.Position(4)= 6;
%export png
%remember to change 'img/' to a folder within you default directory,
%possibly 'bin' within your MATLAB installation. We save as a high quality
%PNG file.
print(['img/' 'ayFlowe0000_0100'],'-dpng','-r600')