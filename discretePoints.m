% =========================================================================
% =========================================================================
% FIT NORMAL GAIT: Predict kinematics based on walking speed, age, sex, BMI
% =========================================================================
% Function: discretePoints
% =========================================================================
% Authors: F. Moissenet
% Creation: 06 July 2017
% Version: v1.0
% =========================================================================
% =========================================================================

function DP = discretePoints(DOF,data,IFS,IFO,CFS,CFO,fig)

% =========================================================================
% Initialisation
% =========================================================================
A(1,:) = data'; % angle
dA(1,:) = diff([data; (data(1)+data(101))/2])'; % velocity
ddA(1,:) = diff(diff([data; ... % acceleration
    (data(1)+data(101))/2; ...
    (data(2)+data(101))/2]))';

%{
% =========================================================================
% TEST: effect of the number of points
% =========================================================================
k = 1;
for i = unique(round(linspace(1,101,101))) % 101, 81, 61, 41, 21, 11:5
    DP(k,1) = i;
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
end
%}
    
%%{
% =========================================================================
% Hip
% =========================================================================
% Sagittal plane: Hip flexion angle
% =========================================================================
if strcmp(DOF,'FE4')
    k = 1;
    DP(k,1) = round(IFS(1)); % HIS1
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    DP(k,1) = round(IFO/2); % HIS2
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    [~,I] = min(A(round(IFS(1)):round(IFO))); % HIS3
    DP(k,1) = I+round(IFS(1))-1;
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    DP(k,1) = round(IFO); % HIS4
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    [~,I] = max(A(round(IFO+(IFS(2)-IFO)/4*1):round(IFO+(IFS(2)-IFO)/4*3))); % HIS5
    DP(k,1) = I+round(IFO+(IFS(2)-IFO)/4*1)-1;
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    DP(k,1) = round(IFS(2)); % HIS6
    DP(k,2) = A(DP(1,1));
    DP(k,3) = dA(DP(1,1));
    DP(k,4) = ddA(DP(1,1));
end

% =========================================================================
% Knee
% =========================================================================
% Sagittal plane: Knee flexion angle
% =========================================================================
if strcmp(DOF,'FE3')
    k = 1;
    DP(k,1) = round(IFS(1)); % KNS1
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    [~,I] = max(A(round(IFS(1)):round(IFO/2))); % KNS2
    DP(k,1) = I+round(IFS(1))-1;
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    [~,I] = min(A(round(IFO/2):round(IFO))); % KNS3
    DP(k,1) = I+round(IFO/2)-1;
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    DP(k,1) = round((IFS(1)+IFO)/4*3); % KNS4
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    DP(k,1) = round(IFO); % KNS5
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    [~,I] = max(A(round(IFO):round(IFS(2)))); % KNS6
    DP(k,1) = I+round(IFO)-1;
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    DP(k,1) = round(IFO+(IFS(2)-IFO)/4*3); % KNS7
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    DP(k,1) = round(IFS(2)); % KNS8
    DP(k,2) = A(DP(1,1));
    DP(k,3) = dA(DP(1,1));
    DP(k,4) = ddA(DP(1,1));
end

% =========================================================================
% Ankle
% =========================================================================
% Sagittal plane: Ankle dorsiflexion angle
% =========================================================================
if strcmp(DOF,'FE2')
    k = 1;
    DP(k,1) = round(IFS(1)); % ANS1
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    [~,I] = min(A(round(IFS(1)):round(CFO))); % ANS2
    DP(k,1) = I+round(IFS(1))-1;
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    DP(k,1) = round(IFO/2); % ANS3
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    [~,I] = max(A(round(IFS(1)):round(IFO))); % ANS4
    DP(k,1) = I+round(IFS(1))-1;
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    [~,I] = min(A(round(CFS):round(IFO+(IFS(2)-IFO)/2))); % ANS5
    DP(k,1) = I+round(CFS)-1;
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    [~,I] = max(A(round(IFO):round(IFO+(IFS(2)-IFO)/4*3))); % ANS6
    DP(k,1) = I+round(IFO)-1;
    DP(k,2) = A(DP(k,1));
    DP(k,3) = dA(DP(k,1));
    DP(k,4) = ddA(DP(k,1));
    k = k+1;
    DP(k,1) = round(IFS(2)); % ANS7
    DP(k,2) = A(DP(1,1));
    DP(k,3) = dA(DP(1,1));
    DP(k,4) = ddA(DP(1,1));
end
%}

% =========================================================================
% Plot
% =========================================================================
if fig == 1
    figure; hold on;
    subplot(3,1,1); hold on; xlim([1,101]);
    plot(A);
    for i = 1:size(DP(:,:),1)
        plot(DP(i,1),DP(i,2),'Marker','o');
    end
    subplot(3,1,2); hold on; xlim([1,101]);
    plot(dA);
    for i = 1:size(DP(:,:),1)
        plot(DP(i,1),DP(i,3),'Marker','o');
    end
    subplot(3,1,3); hold on; xlim([1,101]);
    plot(ddA);
    for i = 1:size(DP(:,:),1)
        plot(DP(i,1),DP(i,4),'Marker','o');
    end
end