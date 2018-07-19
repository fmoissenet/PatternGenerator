% =========================================================================
% =========================================================================
% FIT NORMAL GAIT: Predict kinematics based on walking speed, age, sex, BMI
% =========================================================================
% Function: computeMean
% =========================================================================
% Authors: F. Moissenet
% Creation: 06 July 2017
% Version: v1.0
% =========================================================================
% =========================================================================

function [Mean,Population] = computeMean(Sort,minVf,maxVf,stepVf)

% =========================================================================
% Initialisation
% =========================================================================
Mean.kinematics = [];
Mean.walkingSpeed = [];
Mean.stepLength = [];
Mean.cadence = [];
Mean.IFS1 = [];
Mean.IFS2 = [];
Mean.IFO = [];
Mean.CFS = [];
Mean.CFO = [];
Mean.age = [];
Mean.sex = [];
Mean.BMI = [];

% =========================================================================
% Compute mean values data per % of the Froude velocity
% =========================================================================
temp1 = [];
temp2 = [];
temp3 = [];
temp4 = [];
temp5 = [];
temp6 = [];
temp7 = [];
temp8 = [];
temp9 = [];
temp10 = [];
temp11 = [];
temp12 = [];
temp13 = [];
j = 1;
for v = minVf:stepVf:maxVf
    
    % Find a velocity closed to a Froud velocity
    % ---------------------------------------------------------------------
    sSpeed = [];
    for i = 1:length(Sort.walkingSpeed)
        if abs(Sort.walkingSpeed(i)-v) < stepVf/2
            temp1 = [temp1 Sort.kinematics(:,i)];
            temp2 = [temp2 Sort.walkingSpeed(i)];
            temp3 = [temp3 Sort.stepLength(i)];
            temp4 = [temp4 Sort.cadence(i)];
            temp5 = [temp5 Sort.IFS1(i)];
            temp6 = [temp6 Sort.IFS2(i)];
            temp7 = [temp7 Sort.IFO(i)];
            temp8 = [temp8 Sort.CFS(i)];
            temp9 = [temp9 Sort.CFO(i)];
            temp10 = [temp10 Sort.age(i)];
            temp11 = [temp11 Sort.sex(i)];
            temp12 = [temp12 Sort.BMI(i)];
            temp12 = [temp13 Sort.LL(i)];
        end
    end
    
    % Compute mean
    % ---------------------------------------------------------------------
    if ~isempty(temp1)
        Mean.kinematics(:,j) = mean(temp1,2);
        Mean.walkingSpeed(:,j) = mean(temp2,2);
        Mean.stepLength(:,j) = mean(temp3,2);
        Mean.cadence(:,j) = mean(temp4,2);
        Mean.IFS1(:,j) = mean(temp5,2);
        Mean.IFS2(:,j) = mean(temp6,2);
        Mean.IFO(:,j) = mean(temp7,2);
        Mean.CFS(:,j) = mean(temp8,2);
        Mean.CFO(:,j) = mean(temp9,2);
        Mean.age(:,j) = mean(temp10,2);
        Mean.sex(:,j) = mean(temp11,2);
        Mean.BMI(:,j) = mean(temp12,2);
        Mean.LL(:,j) = mean(temp13,2);
    end
    
    % Compute descriptive statistics
    % ---------------------------------------------------------------------
    if ~isempty(temp1)
        for i = 1:size(temp1,2)
            iRMSE(i) = sqrt(mean((temp1(:,i)-Mean.kinematics(:,j)).^2));
            iR2(i) = 1 - sum((temp1(:,i)-Mean.kinematics(:,j)).^2)/...
                sum((temp1(:,i)-mean(temp1(:,i),1)).^2);
            iMAX(i) = abs(max(temp1(:,i)-Mean.kinematics(:,j)));
            iVAF(i) = (1-var(temp1(:,i)-Mean.kinematics(:,j))/var(temp1(:,i)))*100;
        end
        Population.velocity(j) = v;
        Population.RMSE(j).mean = mean(iRMSE);
        Population.RMSE(j).std = std(iRMSE);
        Population.R2(j).mean = mean(iR2);
        Population.R2(j).std = std(iR2);
        Population.MAX(j).mean = mean(iMAX);
        Population.MAX(j).std = std(iMAX);
        Population.VAF(j).mean = mean(iVAF);
        Population.VAF(j).std = std(iVAF);
        j = j+1;
    end
    
end