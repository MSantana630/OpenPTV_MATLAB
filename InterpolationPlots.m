%Created by Michael Alejandro Santana
%As supporting code towards his masters thesis in Mechanical Engineering at
%CSU Sacramento,CA. 

%CREATE PLOTS OF INTERPOLATED POINTS
%After successfully running LinkedPairsInterpolation_V2.m
%You can run this in order to see the plots making sure that the variables
%SLP2Points SLP3Points SLP4Points and SLP5Points are still active

%below is a test for just the repaired points
%just hide and the current selection ex: lines 10-15
%and reveal the selection you wish to plot ex: lines 16-21
fig=gcf;clf
% arg = SLP2Points;
% uniqueId2 = unique(arg(4, :));%tail points
% hold on
% for i = uniqueId2
%     plot(arg(1, arg(4, :) == i), arg(2, arg(4, :) == i), 'LineWidth',1,'Color','k'); 
% end
arg = SLP3Points;
uniqueId3 = unique(arg(4, :));%tail points
hold on
for i = uniqueId3
    plot(arg(1, arg(4, :) == i), arg(2, arg(4, :) == i), 'LineWidth',1,'Color','k'); 
end
% arg = SLP4Points;
% uniqueId4 = unique(arg(4, :));%head points
% hold on
% for i = uniqueId4
%     plot(arg(1, arg(4, :) == i), arg(2, arg(4, :) == i), 'LineWidth',1,'Color','k');
% end
% arg = SLP5Points;
% uniqueId5 = unique(arg(4, :));%connection
% hold on
for i = uniqueId5
    plot(arg(1, arg(4, :) == i), arg(2, arg(4, :) == i), 'LineWidth',3,'Color','k');
end
axis tight
hold off
% xlim([min(arg(1,:)) max(arg(1,:))])
% ylim([min(arg(2,:)) max(arg(2,:))])
title('Collection of Two Interpolated Points, maxDij = 0.0321, \theta\leq30')
ylabel('Y (mm)')
xlabel('X (mm)')
set(fig.Children, ...
    'FontName',     'Times', ...
    'FontSize',     12);
%scaling
fig.Units = 'centimeters';
fig.Position(3)= 8;
fig.Position(4)= 6;
%export png
print(['img/interpolation/' 'InterpolationStack'],'-dpng','-r1000')
%END of Interpolation Plotting


%%%PLOT REPAIRED POINTS ALONGSIDE THE ORIGINAL BROKEN TRAJECTORIES

%LEADINGLINK = HEAD TRAJECTORY
%TRAILINGLING = TAIL TRAJECTORY
%HEAD FOLLOWS TAILS
%these are all the points that make up the broken trajectories
i=1;
j=i;
for k=1:length(sortedLinkedPairs)
    for i=1:length(PVID)
        if sortedLinkedPairs(1,k) == PVID(4,i)
            LeadingLink(1:5,j)=vertcat(PVID(1:3,i),sortedLinkedPairs(1,k),PVID(8,i));
            j=j+1;
        end
    end
end
k=1;
i=1;
j=i;
for k=1:length(sortedLinkedPairs)
    for i=1:length(PVID)
        if sortedLinkedPairs(4,k) == PVID(4,i)
            TrailingLink(1:5,j)=vertcat(PVID(1:3,i),sortedLinkedPairs(3,k),PVID(8,i));
            j=j+1;
        end
    end
end
%plot below

fig=gcf;clf
arg = TrailingLink;
uniqueIdsT = unique(arg(4, :));%tail points
hold on
for i = uniqueIdsT
    plot(arg(1, arg(4, :) == i), arg(2, arg(4, :) == i), 'LineWidth',0.5,'Color','r'); 
end
arg = LeadingLink;
uniqueIdsL = unique(arg(4, :));%head points
for i = uniqueIdsL
    plot(arg(1, arg(4, :) == i), arg(2, arg(4, :) == i), 'LineWidth',0.5,'Color','b');
end
arg = SLP2Points;
uniqueIdsT = unique(arg(4, :));
hold on
for i = uniqueIdsT
    plot(arg(1, arg(4, :) == i), arg(2, arg(4, :) == i), 'LineWidth',1,'Color','k'); 
end
arg = SLP3Points;
uniqueIdsT = unique(arg(4, :));
hold on
for i = uniqueIdsT
    plot(arg(1, arg(4, :) == i), arg(2, arg(4, :) == i), 'LineWidth',1,'Color','k'); 
end
arg = SLP4Points;
uniqueIdsL = unique(arg(4, :));
% hold on
for i = uniqueIdsL
    plot(arg(1, arg(4, :) == i), arg(2, arg(4, :) == i), 'LineWidth',1,'Color','k');
end
arg = SLP5Points;
uniqueIdsT = unique(arg(4, :));
% hold on
for i = uniqueIdsT
    plot(arg(1, arg(4, :) == i), arg(2, arg(4, :) == i), 'LineWidth',1,'Color','k');
end
axis tight
xlim([min(arg(1,:)) max(arg(1,:))])
ylim([min(arg(2,:)) max(arg(2,:))])
%dummy points for legend
L(1) = plot(nan, nan, 'r');
L(2) = plot(nan, nan, 'b');
L(3) = plot(nan, nan, 'k');
legend(L, {'Future Trajectory','Previous Trajectory','New Created Link'})
hold off

title('All Repaired Trajectories, maxDij = 0.0321, \theta\leq30')
ylabel('Y (mm)')
xlabel('X (mm)')
set(fig.Children, ...
    'FontName',     'Times', ...
    'FontSize',     12);
%scaling
fig.Units = 'centimeters';
fig.Position(3)= 8;
fig.Position(4)= 6;
%export png
print(['img/interpolation/' 'AllRepairedPoints'],'-dpng','-r600')


