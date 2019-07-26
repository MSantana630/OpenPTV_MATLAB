%Created by Michael Alejandro Santana
%As supporting code towards his masters thesis in Mechanical Engineering at
%CSU Sacramento,CA. 

%LEAST SQUARES INTERPOLATION of sortedLinkedPairs

%Make sure you have atleast done the LinkErrorCheck.m atleast once before
%Expecting PVID,PAID,and sortedLinkedPairs.
%
%Interpolation is done here, then we can insert these additional points
%into the original PVID array. Doing this prior to running a linkederror
%check will result in extra points and not work as written.
%
%separate the sorted linked pairs based of missing frames. Frames of 1 are
%not going to be touched, as there is no missing point in between. A frame
%distance of 2-5 will be fixed with a parabolic interpolation function due
%to most of the points being to sensitive to minor pertibations when using
%a cubic or higher polynomial.
%
%
%The General Equation we are solving
% X = xpoints';
% Y = ypoints';
% L = [ones(length(Y),1),X]; 
% A = (L'*L)\L'*Y; coefficients
%Yinterpolation = A(1)+A(2)*xinterp*A(3)*xinterp^2
%
%
%X and Y points will be from 9 points on either side of the gap.
%xinterp points will vary depending on number of points to interpolate
%between the gap. We feed these points into the function once we have the
%coefficients.
%

a=1;b=1;c=1;d=1;e=1;
for i=1:length(sortedLinkedPairs)
    if sortedLinkedPairs(8,i)==1
        SLP(1:8,a)=sortedLinkedPairs(:,i);
        a=a+1;
    elseif sortedLinkedPairs(8,i)==2
        SLP2(1:8,b) = sortedLinkedPairs(:,i);
        b=b+1;
    elseif sortedLinkedPairs(8,i)==3
        SLP3(1:8,c)=sortedLinkedPairs(:,i);
         c=c+1;
    elseif sortedLinkedPairs(8,i)==4
        SLP4(1:8,d)=sortedLinkedPairs(:,i);
         d=d+1;
    elseif sortedLinkedPairs(8,i)==5
        SLP5(1:8,e)=sortedLinkedPairs(:,i);
         e=e+1;
    end
end
clear a b c d e;
%SLP = [unique-id, frame-number, location-within-PVID,unique-id,
%frame-number, location-within-PVID, distanceDIJ,frame-gap]

%SLP has no points in between the segments so a linear fit is required
%SLP2 has a missing point between the segments
%SLP3 has two missing points, SLP4 has three missing points, SLP5 has four
%we need to use the values in rows 3 and 6 to get points on both sides

%%slp2 (only 1 missing point)
SLP2Points=[0;0;0;0;0;0;0;0];
for r=1:length(SLP2)
t=1;
for s=0:9
Ending(:,t)=(PVID(1:8,SLP2(3,r)+(s-9)));
t=t+1;
end
t=1;
for s=0:9
Starting(:,t)=(PVID(1:8,SLP2(6,r)+s));
t=t+1;
end
%least squares fitting
%Y-position
X = horzcat(Starting(1,:),Ending(1,:))';
Y = horzcat(Starting(2,:),Ending(2,:))';
a = [ones(length(Y),1),X];
c = (a'*a)\a'*Y;
%missing X points
xinterp = (Ending(1,10)+Starting(1,1))/2;
%interpolate missing y points
Yinterp = c(1)+c(2)*xinterp;
%missing u points
uinterp = (Ending(5,10)+(Starting(5,1))/2);
%interpolate missing v points
Vinterp = (Starting(2,1)-Yinterp)/0.002;
%create our dummy point
interpPoint=[xinterp,Yinterp,0,Ending(4,10),uinterp,Vinterp,0,Ending(8,10)+1]';
%interpPoints=horzcat(Ending,interpPoint,Starting);
%save this new interpolated point
SLP2Points=horzcat(SLP2Points,interpPoint);
clear X Y L A xinterp Yinterp U V Lu Au uinterp Vinterp interpPoint;
clear interpPoints interpPoint uinterp intSegment t s Ending Starting;
end
clear r;
SLP2Points( :, all(~SLP2Points,1) ) = [];


%%%slp3 (two missing points)
SLP3Points=[0;0;0;0;0;0;0;0];
for r=1:length(SLP3)
t=1;
for s=0:9
Ending(:,t)=(PVID(1:8,SLP3(3,r)+(s-9)));
t=t+1;
end
t=1;
for s=0:9
Starting(:,t)=(PVID(1:8,SLP3(6,r)+s));
t=t+1;
end
%least squares fitting
%Y-position
X = horzcat(Starting(1,:),Ending(1,:))';
Y = horzcat(Starting(2,:),Ending(2,:))';
a = [ones(length(Y),1),X,X.^2];
c = (a'*a)\a'*Y;
%missing X points
xinterp = (Ending(1,10)+Starting(1,1))/2;
xinterp1=(Ending(1,10)+xinterp)/2;
xinterp2= (xinterp+Starting(1,1))/2;
%interpolate missing y points
Yinterp1 = c(1)+c(2)*xinterp1+c(3)*xinterp1^2;
Yinterp2 = c(1)+c(2)*xinterp2+c(3)*xinterp2^2;
%missing u points
uinterp1 = (xinterp1-Ending(1,10))/0.002;
uinterp2 = (Starting(1,1)-xinterp2)/0.002;
%interpolate missing v points
Vinterp1 = (Yinterp1-Ending(2,10))/0.002;
Vinterp2 = (Starting(2,1)-Yinterp2)/0.002;
%predict where the next value will be on both ends
interpPoint1=[xinterp1,Yinterp1,0,Ending(4,10),uinterp1,Vinterp1,0,Ending(8,10)+1]';
interpPoint2=[xinterp2,Yinterp2,0,Ending(4,10),uinterp2,Vinterp2,0,Ending(8,10)+2]';
%interpPoints=horzcat(Ending,interpPoint1,interpPoint2,Starting);
%save this new interpolated point
SLP3Points=horzcat(SLP3Points,interpPoint1,interpPoint2);
clear X Y L A xinterp Yinterp1 U V Lu Au uinterp Vinterp1 interpPoint1;
clear interpPoints interpPoint2 uinterp intSegment t s Ending Starting;
clear uinterp1 uinterp2 xinterp1 xinterp2 Yinterp2 Vinterp2;
end
SLP3Points( :, all(~SLP3Points,1) ) = [];

%%%%slp4 (3 missing points)
SLP4Points=[0;0;0;0;0;0;0;0];
for r=1:length(SLP4)
t=1;
for s=0:9
Ending(:,t)=(PVID(1:8,SLP4(3,r)+(s-9)));
t=t+1;
end
t=1;
for s=0:9
Starting(:,t)=(PVID(1:8,SLP4(6,r)+s));
t=t+1;
end
%least squares fitting
%Y-position
X = horzcat(Starting(1,:),Ending(1,:))';
Y = horzcat(Starting(2,:),Ending(2,:))';
a = [ones(length(Y),1),X,X.^2];
c = (a'*a)\a'*Y;
%missing X points
xinterp = (Ending(1,10)+Starting(1,1))/2; %middlepoint
xinterp1= (Ending(1,10)+xinterp)/2; %left point
xinterp2= (xinterp+Starting(1,1))/2;%right point
%interpolate missing y points
Yinterp =  c(1)+c(2)*xinterp+c(3)*xinterp^2; %middle
Yinterp1 = c(1)+c(2)*xinterp1+c(3)*xinterp1^2;%left
Yinterp2 = c(1)+c(2)*xinterp2+c(3)*xinterp2^2;%right
%interpolate missing u points
uinterp1 = (xinterp1-Ending(1,10))/0.002; %left
uinterp2 = (xinterp-xinterp1)/0.002; %middle
uinterp3 = (Starting(1,1)-xinterp2)/0.002; %right
%interpolate missing v points
Vinterp1 =  (Yinterp1-Ending(2,10))/0.002; %left
Vinterp2 =  (Yinterp-Yinterp1)/0.002; %middle
Vinterp3 =  (Starting(2,1)-Yinterp2)/0.002; %right
%predict where the next value will be on both ends
interpPoint1=[xinterp1,Yinterp1,0,Ending(4,10),uinterp1,Vinterp1,0,Ending(8,10)+1]';
interpPoint2=[xinterp,Yinterp,0,Ending(4,10),uinterp2,Vinterp2,0,Ending(8,10)+2]';
interpPoint3=[xinterp2,Yinterp2,0,Ending(4,10),uinterp3,Vinterp3,0,Ending(8,10)+3]';
%interpPoints=horzcat(Ending,interpPoint1,interpPoint2,interpPoint3,Starting);
%save this new interpolated point
SLP4Points=horzcat(SLP4Points,interpPoint1,interpPoint2,interpPoint3);
clear X Y L A xinterp Yinterp1 U V Lu Au uinterp Vinterp1 interpPoint;
clear interpPoints interpPoint uinterp intSegment t s Ending Starting;
clear uinterp1 uinterp2 xinterp1 xinterp2 Yinterp2 Vinterp2;
clear Vinterp Vinterp3 uinterp3 interpPoint1 interpPoint2 interpPoint3;
end
SLP4Points( :, all(~SLP4Points,1) ) = [];

%%%%%slp5 (4 missing points)
SLP5Points=[0;0;0;0;0;0;0;0];
for r=1:length(SLP5)
t=1;
for s=0:9
Ending(:,t)=(PVID(1:8,SLP5(3,r)+(s-9)));
t=t+1;
end
t=1;
for s=0:9
Starting(:,t)=(PVID(1:8,SLP5(6,r)+s));
t=t+1;
end
%least squares fitting
%Y-position
X = horzcat(Ending(1,:),Starting(1,:))';
Y = horzcat(Ending(2,:),Starting(2,:))';
a = [ones(length(Y),1),X,X.^2];
c = (a'*a)\a'*Y;
%missing X points
xinterp = (Ending(1,10)+Starting(1,1))/2; %midline
xinterp1= (Ending(1,10)+xinterp)/2; %leftmidline
xinterp2= (Starting(1,1)+xinterp)/2; %rightmidline
%points below
xinterp3= (Ending(1,10)+xinterp1)/2;%left point1
xinterp4= (xinterp+xinterp1)/2;%left point2
xinterp5= (xinterp+xinterp2)/2; %right point1
xinterp6= (Starting(1,1)+xinterp2)/2; %right point2
%interpolate missing y points
Yinterp1 =  c(1)+c(2)*xinterp3+c(3)*xinterp3^2; %left1
Yinterp2 = c(1)+c(2)*xinterp4+c(3)*xinterp4^2;%left2
Yinterp3 = c(1)+c(2)*xinterp5+c(3)*xinterp5^2;%right1
Yinterp4 = c(1)+c(2)*xinterp6+c(3)*xinterp6^2;%right2
%interpolate missing u points
uinterp1 = (xinterp3-Ending(1,10))/0.002; %left1
uinterp2 = (xinterp4-xinterp3)/0.002; %left2
uinterp3 = (xinterp5-xinterp4)/0.002; %right1
uinterp4 = (Starting(1,1)-xinterp6)/0.002; %right2
%interpolate missing v points
Vinterp1 =  (Yinterp1-Ending(2,10))/0.002; %left1
Vinterp2 =  (Yinterp2-Yinterp1)/0.002; %left2
Vinterp3 =  (Yinterp3-Yinterp2)/0.002; %right1
Vinterp4 =  (Starting(2,1)-Yinterp4)/0.002; %right2
%predict where the next value will be on both ends
interpPoint1=[xinterp3,Yinterp1,0,Ending(4,10),uinterp1,Vinterp1,0,Ending(8,10)+1]';%left1
interpPoint2=[xinterp4,Yinterp2,0,Ending(4,10),uinterp2,Vinterp2,0,Ending(8,10)+2]';%left2
interpPoint3=[xinterp5,Yinterp3,0,Ending(4,10),uinterp3,Vinterp3,0,Ending(8,10)+3]';%right1
interpPoint4=[xinterp6,Yinterp4,0,Ending(4,10),uinterp4,Vinterp4,0,Ending(8,10)+4]';%right2
%interpPoints=horzcat(Ending,interpPoint1,interpPoint2,interpPoint3,interpPoint4,Starting);
%save this new interpolated point
SLP5Points=horzcat(SLP5Points,interpPoint1,interpPoint2,interpPoint3,interpPoint4);
clear X Y L A xinterp Yinterp1 uinterp4 uinterp Vinterp1 interpPoint;
clear interpPoints interpPoint uinterp intSegment t s Ending Starting;
clear uinterp1 uinterp2 xinterp1 xinterp2 Yinterp2 Vinterp2 Yinterp4;
clear Vinterp Vinterp3 uinterp3 interpPoint1 interpPoint2 interpPoint3;
clear uinterpp4 Vinterp4 xinterp3 xinterp4 xinterp5 xinterp6 Yinterp3;
clear interpPoint4 Yinterp;
end
clear r s t;
SLP5Points( :, all(~SLP5Points,1) ) = [];

%This array contains all the interpolated points we need to introduced back
%into the original PVID vector to obtain final plots.
NewSLPPoints=horzcat(SLP2Points,SLP3Points,SLP4Points,SLP5Points);
clear SLP SLP2 SLP3 SLP4 SLP5;
tempSortedNewPVID = sortrows(horzcat(sortedNewPVID,NewSLPPoints)',4)';
disp('Creating our new PVID array with all the interpolated points');
for e = 1:length(sortedLinkedPairs) %run through SortedLinkedPairs array 
    for ee = 1:length(tempSortedNewPVID) %run through altPVID array
        if tempSortedNewPVID(4,ee) == sortedLinkedPairs(1,e)
                %if the ID in the altPVID array is equal to the ID in the LinkedPairs array
                tempSortedNewPVID(4,ee) = sortedLinkedPairs(4,e); %when equal replace id values
        end
    end
end

[~,index]=sort(tempSortedNewPVID(4,:));
LinkedPVID = tempSortedNewPVID(:,index); 

clear tempSortedNewPVID e ee a b c;
%use this script if you want to see the connections plotted
% arg = SLP5Points;
% uniqueIdsT = unique(arg(4, :));
% hold on
% for i = uniqueIdsT
%     plot(arg(1, arg(4, :) == i), arg(2, arg(4, :) == i), 'LineWidth', 1);
% end
% hold off;


%Below is an example using the output from SLP5Points first entry when r=1
%just set r=1, run the inside code and you should have every array filled
%with data. This gives you access to 'interpPoints' with a size 8rows and
%24columns.

% maxX=max(horzcat(Starting(1,:),Ending(1,:)));
% minX=min(horzcat(Starting(1,:),Ending(1,:)));
% xs=minX:0.0005:maxX;
% for i = 1:length(xs)
% ys(i) =  c(1)+c(2)*xs(i)+c(3)*xs(i)^2;
% end
% xvals=horzcat(Starting(1,:),Ending(1,:));
% yvals=horzcat(Starting(2,:),Ending(2,:));
% points=horzcat(Ending,Starting);
% %the above script makes the interpolated line of our least squares polynomial
% 
% %below is the script to make two subplots
% fig=gcf;clf
% figure
% subplot(2,1,1);
% title('Broken Trajectory Requiring 4 Interpolated Frames')
% hold on
% plot(points(1,1:10),points(2,1:10),'k','LineWidth',2);
% plot(points(1,11:20),points(2,11:20),'b','LineWidth',2);
% plot(xs,ys,'-ro');
% hold off
% axis tight
% xlim([min(points(1,:)) max(points(1,:))])
% ylim([min(points(2,:)) max(points(2,:))])
% ylabel('Y (mm)')
% xlabel('X (mm)')
% 
% legend('Ending Trajectory','Starting Trajectory','Least Squares Interpolation','Location','northeast')
% legend('boxoff')
% subplot(2,1,2)
% hold on
% title('Repaired Trajectory');
% plot(interpPoints(1,:),interpPoints(2,:),'k');
% scatter(interpPoints(1,11:14),interpPoints(2,11:14),'r','filled')
% hold off
% axis tight
% xlim([min(points(1,:)) max(points(1,:))])
% ylim([min(points(2,:)) max(points(2,:))])
% ylabel('Y (mm)')
% xlabel('X (mm)')
% set(fig.Children, ...
%     'FontName',     'Times', ...
%     'FontSize',     12);
% %scaling
% fig.Units = 'centimeters';
% fig.Position(3)= 8;
% fig.Position(4)= 6;
% %export png
% print(['img/interpolation/' '4PointRepairExample2'],'-dpng','-r600')