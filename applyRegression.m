% =========================================================================
% =========================================================================
% FIT NORMAL GAIT: Predict kinematics based on walking speed, age, sex, BMI
% =========================================================================
% Function: applyRegression
% =========================================================================
% Authors: F. Moissenet
% Creation: 06 July 2017
% Version: v1.0
% =========================================================================
% =========================================================================

function DP = applyRegression(X,Predictors)

% =========================================================================
% Compute discrete points value based on regressions
% =========================================================================
for i = 1:size(Predictors,1)
    for j = 1:size(Predictors,2)  
        b3 = [];
        for k = 1:size(Predictors,3)
            b3 = [b3 Predictors(i,j,k).value];
        end
        DP(i,j,:) = [ones(size(X,1),1) X]*b3';
        if j == 1
            DP(i,j,:) = round(DP(i,j,:));
        end
        clear b3;
    end
end