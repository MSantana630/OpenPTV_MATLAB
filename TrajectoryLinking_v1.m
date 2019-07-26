%Created by Michael Alejandro Santana
%As supporting code towards his masters thesis in Mechanical Engineering at
%CSU Sacramento,CA. 
%
%BEGINNING OF CODE
%
%lets find all the termal points and starting points of every trajectory
%
j=1;
    for i=1:length(PVID)-1
        if PVID(4,i) ~= PVID(4,i+1)
           lastPointHeads(j)=i;
           TailLocation(j)=i+1;
          %pointBeforeLastHead(j)=i-1;
           Htemp(:,j)=PVID(1:8,i);
           Ttemp(:,j)=PVID(1:8,i+1);
          %Hlastpoint(:,j)=PVID([1:3],i);
           j=j+1;
        end
    end

%head trajectories
%stick the position of the i-1 frame at the bottom
H=vertcat(Htemp,lastPointHeads);

%tail trajectories
T=vertcat(Ttemp,TailLocation);

%request frame time for velocity calculations
fprintf('What is the time between frames in seconds? \n');
prompt='For example 500frames-per-second is 1/500 or 0.002sec: ';

ftime=input(prompt);
if abs(ftime) >= 10
    fprintf('Entered a time greater than 10seconds \n');
    fprintf('Setting time between frames to 1 second \n');
    fprintf('If this is an error, please comment out this section LINE 39 \n');
    ftime =1;
elseif ftime < 10
    fprintf('The frame time entered was: %g\n',ftime);
end

frame_time=ftime;
clear 'ftime';

%The logic for finding the links requires we determine a radius around the
%heads point where we look for possible tails-points to link to. We must
%choose this radius. Here it is done by evaluating lengths along every
%tail-point and every head-point within three frams of their respective
%starting and ending point. We choose the maximum distance after evaluating
%every heads and tails length, then average this result. 

fprintf('The following will set the max search radius to look for around each broken trajectory. \n\n');
%Head Distance Eval
for f=1:length(H)
    Hdij(f)  = sqrt((PVID(1,H(9,f))-  (PVID(1,H(9,f)-1)))^2+ (PVID(2,H(9,f))-(PVID(2,H(9,f)-1)))^2+  (PVID(3,H(9,f))-  (PVID(3,H(9,f)-1)))^2);
    Hdij1(f) = sqrt((PVID(1,H(9,f)-1)-(PVID(1,H(9,f)-2)))^2+ (PVID(2,H(9,f)-1)-(PVID(2,H(9,f)-2)))^2+(PVID(3,H(9,f)-1)-(PVID(3,H(9,f)-2)))^2);
    Hdij2(f) = sqrt((PVID(1,H(9,f)-2)-(PVID(1,H(9,f)-3)))^2+ (PVID(2,H(9,f)-2)-(PVID(2,H(9,f)-3)))^2+(PVID(3,H(9,f)-2)-(PVID(3,H(9,f)-3)))^2);
end
%Tail Distance Eval
for r=1:length(T)
    Tdij(r)  = sqrt((PVID(1,T(9,r)+1)-  (PVID(1,T(9,r))))^2+  (PVID(2,T(9,r)+1)-(PVID(2,T(9,r))))^2+  (PVID(3,T(9,r)+1)-(PVID(3,T(9,r))))^2);
    Tdij1(r) = sqrt((PVID(1,T(9,r)+2)-(PVID(1,T(9,r)+1)))^2+(PVID(2,T(9,r)+2)-(PVID(2,T(9,r)+1)))^2+(PVID(3,T(9,r)+2)-(PVID(3,T(9,r)+1)))^2);
    Tdij2(r) = sqrt((PVID(1,T(9,r)+3)-(PVID(1,T(9,r)+2)))^2+(PVID(2,T(9,r)+3)-(PVID(2,T(9,r)+2)))^2+(PVID(3,T(9,r)+3)-(PVID(3,T(9,r)+2)))^2);
end

avgDIJ = mean(Hdij+Hdij1+Hdij2+Tdij+Tdij1+Tdij2);
stdDIJ = std(Hdij+Hdij1+Hdij2+Tdij+Tdij1+Tdij2);
maxAvgDIJ = ((max(Hdij)+max(Hdij1)+max(Hdij2)+max(Tdij)+max(Tdij1)+max(Tdij2))/6);

fprintf('The current Average Maximum Distance Dij is equal to: %4f \n', maxAvgDIJ);
fprintf('The Average Distance is %4f.',avgDIJ);
fprintf('The Standard Deviation is %4f. \n', stdDIJ);
fprintf('The Range is %4f. \n', range(Hdij+Hdij1+Hdij2+Tdij+Tdij1+Tdij2));
clear avgDIJ stdDIJ maxAvgDIJ;

%request the modifier for the max distance threshold
prompt='By what amount do you wish to modify our max ditance threshold Dij? \n 1.0 is no change, 0.5 is half: ';
distance_modifier=input(prompt);
fprintf('The distance modifier value entered was: %g\n',distance_modifier);
maxDij= abs(distance_modifier)*((max(Hdij)+max(Hdij1)+max(Hdij2)+max(Tdij)+max(Tdij1)+max(Tdij2))/6);
fprintf('The Minimum Distance Dij is now equal to: %4f \n', maxDij);
clear Hdij Hdij1 Hdij2 Tdij Tdij1 Tdij2;

%request search angle
%the future atan2() function treats negative values as positive.
prompt='Set the limiting search angle for potential links in degrees.  \n Its recommended to choose something between 10-30degrees:';
theta=input(prompt);
fprintf('The angle entered is: %g\n',theta);

t=1;
i=1;
for f=1:length(H)%time step 1
    for r=1:length(T)
        if ((T(8,r)-H(8,f))==1 ) && ( T(4,r)~=H(4,f) ) 
            xpred = H(1,f) + PVID(5,H(9,f)-1)*(frame_time);
            ypred = H(2,f) + PVID(6,H(9,f)-1)*(frame_time); 
            zpred = H(3,f) + PVID(7,H(9,f)-1)*(frame_time);
            upred = PVID(5,H(9,f)-1); %ending velocity is from the n-1 point, because last positions have no velocity
            vpred = PVID(6,H(9,f)-1); %last points  velocity
            wpred = PVID(7,H(9,f)-1);
            xTails = T(1,r); %tails points positions
            yTails = T(2,r);
            zTails = T(3,r);
            uTails = T(5,r);%tail point velocities
            vTails = T(6,r);
            wTails = T(7,r); %distance calculation below
            Dij(i)=sqrt( ( (xpred-xTails)^2+(ypred-yTails)^2+(zpred-zTails)^2)+( (sqrt((upred-uTails)^2+(vpred-vTails)^2+(wpred-wTails)^2)*frame_time) )^2); 
            a=[PVID(1,H(9,f))- PVID(1,(H(9,f)-2));PVID(2,H(9,f))-PVID(2,(H(9,f)-2));PVID(3,H(9,f))-PVID(3,(H(9,f)-2))];%vector along heads point, from 't-2' to 'last point at (t)'
            b=[xTails-H(1,f);yTails-H(2,f);zTails-H(3,f)]; %vector from final point to Tails point
            angle(i)=atan2(norm(cross(b,a)), dot(b,a))*(180/pi); %calculate angle between [an] and [bn]
            if ( Dij(i) <= maxDij )
                if angle(i) <=theta; %max angle negative and positive
                HLinks(1:3,t)=H([4 8 9],f); %save two arrays
                TLinks(1:3,t)=T([4 8 9],r);
                DijLinks(t)=Dij(i);
               %LinkedAngle(t)=angle(i); for debugging
                t=t+1;
                end
            end
            i=i+1;
        end
    end
end
clear a b xpred ypred zpred upred vpred wpred xTails yTails zTails uTails;
clear vTails wTails Dij angle t i f r j;

t=1;
i=1;
for f=1:length(H)%time step 2
    for r=1:length(T)
        if ((T(8,r)-H(8,f))==2 ) && ( T(4,r)~=H(4,f) ) 
            xpred = H(1,f) + PVID(5,H(9,f)-1)*(2*frame_time); %2frame search
            ypred = H(2,f) + PVID(6,H(9,f)-1)*(2*frame_time); 
            zpred = H(3,f) + PVID(7,H(9,f)-1)*(2*frame_time);
            upred = PVID(5,H(9,f)-1); 
            vpred = PVID(6,H(9,f)-1); 
            wpred = PVID(7,H(9,f)-1);
            xTails = T(1,r); %tails points
            yTails = T(2,r);
            zTails = T(3,r);
            uTails = T(5,r);
            vTails = T(6,r);
            wTails = T(7,r);   %distance calculation
            Dij(i)=sqrt( ( (xpred-xTails)^2+(ypred-yTails)^2+(zpred-zTails)^2)+( (sqrt((upred-uTails)^2+(vpred-vTails)^2+(wpred-wTails)^2)*2*frame_time) )^2); 
            a=[PVID(1,H(9,f))- PVID(1,(H(9,f)-2));PVID(2,H(9,f))-PVID(2,(H(9,f)-2));PVID(3,H(9,f))-PVID(3,(H(9,f)-2))];%vector along heads point, from 't-2' to 'last point at (t)'
            b=[xTails-H(1,f);yTails-H(2,f);zTails-H(3,f)]; %vector from final point to Tails ppoint
            angle(i)=atan2(norm(cross(b,a)), dot(b,a))*(180/pi); %calculate angle between [an] and [bn]
            if ( Dij(i) <= maxDij )
                if angle(i) <=theta; %max angle negative and positive
                HLinks2(1:3,t)=H([4 8 9],f);
                TLinks2(1:3,t)=T([4 8 9],r);
                DijLinks2(t)=Dij(i);
%                 LinkedAngle2(t)=angle(i);
                t=t+1;
                end
            end
            i=i+1;
        end
    end
end
clear a b xpred ypred zpred upred vpred wpred xTails yTails zTails uTails;
clear vTails wTails Dij angle t i f r j;

t=1;
i=1;
for f=1:length(H)%time step 3
    for r=1:length(T)
        if ((T(8,r)-H(8,f))==3 ) && ( T(4,r)~=H(4,f) ) %3frame search
            xpred = H(1,f) + PVID(5,H(9,f)-1)*(3*frame_time);
            ypred = H(2,f) + PVID(6,H(9,f)-1)*(3*frame_time); 
            zpred = H(3,f) + PVID(7,H(9,f)-1)*(3*frame_time);
            upred = PVID(5,H(9,f)-1); 
            vpred = PVID(6,H(9,f)-1);
            wpred = PVID(7,H(9,f)-1);
            xTails = T(1,r); %tails points
            yTails = T(2,r);
            zTails = T(3,r);
            uTails = T(5,r);
            vTails = T(6,r);
            wTails = T(7,r);   %distance calculation
            Dij(i)=sqrt( ( (xpred-xTails)^2+(ypred-yTails)^2+(zpred-zTails)^2)+( (sqrt((upred-uTails)^2+(vpred-vTails)^2+(wpred-wTails)^2)*3*frame_time) )^2); 
            a=[PVID(1,H(9,f))- PVID(1,(H(9,f)-2));PVID(2,H(9,f))-PVID(2,(H(9,f)-2));PVID(3,H(9,f))-PVID(3,(H(9,f)-2))];%vector along heads point, from 't-2' to 'last point at (t)'
            b=[xTails-H(1,f);yTails-H(2,f);zTails-H(3,f)]; %vector from final point to Tails ppoint
            angle(i)=atan2(norm(cross(b,a)), dot(b,a))*(180/pi); %calculate angle between [an] and [bn]
            if ( Dij(i) <= maxDij )
                if angle(i) <=theta; %max angle negative and positive
                HLinks3(1:3,t)=H([4 8 9],f);
                TLinks3(1:3,t)=T([4 8 9],r);
                DijLinks3(t)=Dij(i);
%                 LinkedAngle3(t)=angle(i);
                t=t+1;
                end
            end
            i=i+1;
        end
    end
end
clear a b xpred ypred zpred upred vpred wpred xTails yTails zTails uTails;
clear vTails wTails Dij angle t i f r j;

t=1;
i=1;
for f=1:length(H)%time step 4
    for r=1:length(T)
        if ((T(8,r)-H(8,f))==4 ) && ( T(4,r)~=H(4,f) ) %4frame search
            xpred = H(1,f) + PVID(5,H(9,f)-1)*(4*frame_time);
            ypred = H(2,f) + PVID(6,H(9,f)-1)*(4*frame_time); 
            zpred = H(3,f) + PVID(7,H(9,f)-1)*(4*frame_time);
            upred = PVID(5,H(9,f)-1); 
            vpred = PVID(6,H(9,f)-1); 
            wpred = PVID(7,H(9,f)-1);
            xTails = T(1,r); %tails points
            yTails = T(2,r);
            zTails = T(3,r);
            uTails = T(5,r);
            vTails = T(6,r);
            wTails = T(7,r);   %distance calculation
            Dij(i)=sqrt( ( (xpred-xTails)^2+(ypred-yTails)^2+(zpred-zTails)^2)+( (sqrt((upred-uTails)^2+(vpred-vTails)^2+(wpred-wTails)^2)*4*frame_time) )^2); 
            a=[PVID(1,H(9,f))- PVID(1,(H(9,f)-2));PVID(2,H(9,f))-PVID(2,(H(9,f)-2));PVID(3,H(9,f))-PVID(3,(H(9,f)-2))];%vector along heads point, from 't-2' to 'last point at (t)'
            b=[xTails-H(1,f);yTails-H(2,f);zTails-H(3,f)]; %vector from final point to Tails ppoint
            angle(i)=atan2(norm(cross(b,a)), dot(b,a))*(180/pi); %calculate angle between [an] and [bn]
            if ( Dij(i) <= maxDij )
                if angle(i) <=theta; %max angle negative and positive
                HLinks4(1:3,t)=H([4 8 9],f);
                TLinks4(1:3,t)=T([4 8 9],r);
                DijLinks4(t)=Dij(i);
%                 LinkedAngle3(t)=angle(i);
                t=t+1;
                end
            end
            i=i+1;
        end
    end
end
clear a b xpred ypred zpred upred vpred wpred xTails yTails zTails uTails;
clear vTails wTails Dij angle t i f r j;

t=1;
i=1;
for f=1:length(H)%time step 5
    for r=1:length(T)
        if ((T(8,r)-H(8,f))==5 ) && ( T(4,r)~=H(4,f) ) %5frame search
            xpred = H(1,f) + PVID(5,H(9,f)-1)*(5*frame_time);
            ypred = H(2,f) + PVID(6,H(9,f)-1)*(5*frame_time); 
            zpred = H(3,f) + PVID(7,H(9,f)-1)*(5*frame_time);
            upred = PVID(5,H(9,f)-1); 
            vpred = PVID(6,H(9,f)-1); 
            wpred = PVID(7,H(9,f)-1);
            xTails = T(1,r); %tails points
            yTails = T(2,r);
            zTails = T(3,r);
            uTails = T(5,r);
            vTails = T(6,r);
            wTails = T(7,r);   %distance calculation
            Dij(i)=sqrt( ( (xpred-xTails)^2+(ypred-yTails)^2+(zpred-zTails)^2)+( (sqrt((upred-uTails)^2+(vpred-vTails)^2+(wpred-wTails)^2)*5*frame_time) )^2); 
            a=[PVID(1,H(9,f))- PVID(1,(H(9,f)-2));PVID(2,H(9,f))-PVID(2,(H(9,f)-2));PVID(3,H(9,f))-PVID(3,(H(9,f)-2))];%vector along heads point, from 't-2' to 'last point at (t)'
            b=[xTails-H(1,f);yTails-H(2,f);zTails-H(3,f)]; %vector from final point to Tails ppoint
            angle(i)=atan2(norm(cross(b,a)), dot(b,a))*(180/pi); %calculate angle between [an] and [bn]
            if ( Dij(i) <= maxDij )
                if angle(i) <=theta; %max angle negative and positive
                HLinks5(1:3,t)=H([4 8 9],f);
                TLinks5(1:3,t)=T([4 8 9],r);
                DijLinks5(t)=Dij(i);
%                 LinkedAngle3(t)=angle(i);
                t=t+1;
                end
            end
            i=i+1;
        end
    end
end
clear a b xpred ypred zpred upred vpred wpred xTails yTails zTails uTails;
clear vTails wTails Dij angle t i f r j;


disp('Creating our Sorted Linked Pairs array');
%This LinkPairs vector contains all the Heads and Tails that should be
%paired together.
%Row 1 = ID's of the Heads, Row 4 = ID's of the Tails.
%this sorts all the pairs in ascending order by value in row 1 and then
%by value in row 7 which is the distance Dij
LinkedPairs1=sortrows(vertcat(HLinks,TLinks,DijLinks)',[1 7])';
LinkedPairs2=sortrows(vertcat(HLinks2,TLinks2,DijLinks2)',[1 7])';
LinkedPairs3=sortrows(vertcat(HLinks3,TLinks3,DijLinks3)',[1 7])';
LinkedPairs4=sortrows(vertcat(HLinks4,TLinks4,DijLinks4)',[1 7])';
LinkedPairs5=sortrows(vertcat(HLinks5,TLinks5,DijLinks5)',[1 7])';
clear HLinks HLinks2 HLinks3 HLinks4 TLinks TLinks2 TLinks3 TLinks4;
clear DijLinks DijLinks2 DijLinks3 DijLinks4 DijLinks5 HLinks5;


%using the locations above, go into the sortedLinkedPairs() array at these
%positions and pull out the data. This gives an SLP array which has no
%duplicate values in the top row. These are all head points, so we now just
%have to evaluate tails points later.

fprintf('With a forward search time of 1 frame \n');
fprintf('We have %d potential linked pairs to check \n', length(LinkedPairs1)); 
fprintf('With a forward search time of 2 frames \n');
fprintf('We have %d potential linked pairs to check \n', length(LinkedPairs2)); 
fprintf('With a forward search time of 3 frames \n');
fprintf('We have %d potential linked pairs to check \n', length(LinkedPairs3)); 
fprintf('With a forward search time of 4 frames \n');
fprintf('We have %d potential linked pairs to check \n', length(LinkedPairs4));
fprintf('With a forward search time of 5 frames \n');
fprintf('We have %d potential linked pairs to check \n', length(LinkedPairs5));

%total-sorted-linked-pairs  all of them in one array
totalSLP = horzcat(LinkedPairs1,LinkedPairs2,LinkedPairs3,LinkedPairs4,LinkedPairs5);
framediff = totalSLP(5,:)-totalSLP(2,:);
totalSLP=sortrows(vertcat(totalSLP,framediff)',[1 7])';
clear framediff LinkedPairs1 LinkedPairs2 LinkedPairs3 LinkedPairs4 LinkedPairs5;

fprintf('Total Trajectories to Sort: %g \n',length(totalSLP));

%%%%%%%%% F I N A L - C O M P A R I S O N - S O R T %%%%%%%%%%%%%%%%
%take all the links and put them into one array
%sort them by TopID and DijDistance [1,7]
%
%Find the location of all the times that adjacent TopID's are different
%from eachother. By setting the first point in the totalSLP array to the
%original sorted value, we can eliminate all the times the top ID's are
%duplicated and truncate them based off the minimum distance. Check the
%locations in slplocation and check out what they do.
%
%We then sort totalSLP by TopID and FrameDifference [1,8] so that we can
%eliminate adjacent TopID points by minimum frame-time.
%
%Repeat the sorting for the bottomID [3,7] and [3,8] to eliminate
%duplicates in bottomID based off DijDistance[7] and minimum frame-time[8].
%This is repeated for every sorted linked pair in order to eliminate all
%duplicates and force eliminations based off distance and missing frames.

t=1;%filter top ID's based off max distance in row 7
for i=1:length(totalSLP)-1
        if totalSLP(1,i) ~= totalSLP(1,i+1)
           slplocation(t)=i+1;
           t=t+1;
        end
end
slplocation=horzcat(1,slplocation); %set first point as its already sorted
newstotalSLP=totalSLP(:,slplocation(:));%build the sorted array
sntSLP=sortrows(newstotalSLP',[1 8])';%sort based off frame distance

t=1;
for i=1:length(sntSLP)-1 %filter top ID's based off frame distance in row 8
        if sntSLP(1,i) ~= sntSLP(1,i+1)
           sntSLPlocation(t)=i+1;
           t=t+1;
        end
end

sntSLPlocation=horzcat(1,sntSLPlocation);%set first point
newsntSLP=sntSLP(:,sntSLPlocation);%build the array
newsntSLP=sortrows(newsntSLP(1:8,:)',[4 7])';%sort array off bottom ID and max distance again.

t=1;
for i=1:length(newsntSLP)-1
        if newsntSLP(4,i) ~= newsntSLP(4,i+1)
           slplocation2(t)=i+1;
           t=t+1;
        end
end

slplocation2=horzcat(1,slplocation2);
newSLP=newsntSLP(:,slplocation2);
newSLP=sortrows(newSLP(1:8,:)',[4 7])';

t=1;
for i=1:length(newSLP)-1
        if newSLP(4,i) ~= newSLP(4,i+1)
           sntSLPlocation2(t)=i+1;
           t=t+1;
        end
end
%this completes the sorting of all the SortedLinkedPairs. There should be
%no duplicates in either of the rows because we eliminate all the top IDs
%based of the maximum distance. If any top IDs are remaining, they are
%eliminated based off minimum frame distance, meaning only ONE top ID is 
%left behind
sntSLPlocation2=horzcat(1,sntSLPlocation2);
FinalSLP=sortrows(newSLP(:,sntSLPlocation2)',1)';

clear sntSLP sntSLPlocation sntSLPlocation2 newSLP newsntSLP newstotalSLP;

fprintf('We now have %d linked pairs in our sortedLinkedPairs array \n',length(FinalSLP));

%%%%%### F I N A L S T E P ###%%%%%
%lets overwrite the top ID's (heads) with the Tails ID's in row 3 and
%create a new PVID array which has all the linked trajectories
sortedLinkedPairs=FinalSLP;
altPVID=PVID; %duplicate PVID because we are going to make alterations in the next loop
disp('Creating our new PVID array');
for e = 1:length(sortedLinkedPairs) %run through SortedLinkedPairs array 
    for ee = 1:length(altPVID) %run through altPVID array
        if altPVID(4,ee) == sortedLinkedPairs(1,e)
                %if the ID in the altPVID array is equal to the ID in the LinkedPairs array
                altPVID(4,ee) = sortedLinkedPairs(4,e); %when equal replace id values
        end
    end
end
% altPVID has all the continuous paths with the same ID given by 
% sortedLinkPairs.
%Sort the newPVID array by id values in the 4th row for manual verification

[~,index]=sort(altPVID(4,:));
sortedNewPVID = altPVID(:,index); 
fprintf('Trajectory Linking operation has completed, cleared all erroneous variables. \n');
fprintf('The next step is to interpolate missing points or use data as is.');

clear e ee FinalSLP H Hlinks5 Htempp i index lastPointHeads prompt;
clear slplocation slplocation2 t T TailLocation theta TLinks5 totalSLP;
clear Ttemp Htemp altPVID;




