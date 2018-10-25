% =========================================================================
% =========================================================================
% FIT NORMAL GAIT: Predict kinematics based on walking speed, age, sex, BMI
% =========================================================================
% Function: computeRegression
% =========================================================================
% Authors: F. Moissenet
% Creation: 06 July 2017
% Version: v1.0
% =========================================================================
% =========================================================================

function [DP_reg,Predictors] = computeRegression(X,DP,correlations,pReg,fig)

% =========================================================================
% Multivariate regression procedure
% =========================================================================
for i = 1:size(DP,1)
    
    for j = 1:size(DP,2)
        
        % Values taken by the discrete point for each cycle
        % -----------------------------------------------------------------
        Y = permute(DP(i,j,:),[3,1,2]);
%         Y = permute(DP(i,j,:)-std(DP(i,j,:),1,3),[3,1,2]); %%TEST%%
        
        % Stepwise regression using entrance/exit tolerances with p<pReg
        % -----------------------------------------------------------------
        [~,~,pval,inmodel] = stepwisefit(X,Y-mean(Y),'penter',pReg,'premove',pReg,'Display','off');
        for k = 1:size(X,2)+1
            if k == 1
                Predictors(i,j,k).DP = ['DP',num2str(i)]; % DP number
                if j == 1
                    Predictors(i,j,k).variable = 'frame'; % DP frame
                elseif j == 2
                    Predictors(i,j,k).variable = 'angle'; % DP angle
                elseif j == 3
                    Predictors(i,j,k).variable = 'velocity'; % DP velocity
                elseif j == 4
                    Predictors(i,j,k).variable = 'acceleration'; % DP acceleration
                end
                Predictors(i,j,k).correlation = correlations(k); % Variable of correlation
                Predictors(i,j,k).value = []; % Regression coefficient for the variable of correlation
                Predictors(i,j,k).significance = []; % Significance of correlation for the variable / None for the contant term
                Predictors(i,j,k).inmodel = [];
            else
                Predictors(i,j,k).DP = ['DP',num2str(i)]; % DP number
                if j == 1
                    Predictors(i,j,k).variable = 'frame'; % DP frame
                elseif j == 2
                    Predictors(i,j,k).variable = 'angle'; % DP angle
                elseif j == 3
                    Predictors(i,j,k).variable = 'velocity'; % DP velocity
                elseif j == 4
                    Predictors(i,j,k).variable = 'acceleration'; % DP acceleration
                end
                Predictors(i,j,k).correlation = correlations(k); % Variable of correlation
                Predictors(i,j,k).value = []; % Regression coefficient for the variable of correlation
                Predictors(i,j,k).significance = pval(k-1); % Significance of correlation for the variable / None for the contant term
                Predictors(i,j,k).inmodel = inmodel(k-1);
            end
        end
        
        % Keep only the variables with significant correlation
        % -----------------------------------------------------------------
        X2 = [];
        l = 1;
        for k = 1:size(X,2)
            if inmodel(k) == 1
                X2(:,l) = X(:,k);
                l = l+1;
            end
        end
        
        % If no correlation exists, use the mean value across cycles
        % -----------------------------------------------------------------
        if isempty(X2)
            for k = 1:size(X,2)+1
                if k == 1
                    Predictors(i,j,k).value = mean(DP(i,j,:),3);
%                     Predictors(i,j,k).value = mean(DP(i,j,:),3)-std(DP(i,j,:),1,3); %%TEST%%
                else
                    Predictors(i,j,k).value = 0;
                end
                b3(k) = Predictors(i,j,k).value;
            end
            
        % If a correlation exists, use robust multilinear regression
        % -----------------------------------------------------------------
        else
            [b2 stats(i,j)] = robustfit(X2,Y);
            b3(1) = b2(1);
            l = 2;
            m = 2;
            for k = 1:size(X,2)
                if inmodel(k) == 1
                    b3(l) = b2(m);
                    m = m+1;
                else
                    b3(l) = 0;
                end
                l = l+1;
            end
            for k = 1:size(X,2)+1
                Predictors(i,j,k).value = b3(k);
            end
            clear inmodel;
        end
        
        % Compute the discrete point and round the related frame
        % -----------------------------------------------------------------
        DP_reg(i,j,:) = [ones(size(X,1),1) X]*b3';
        if j == 1
            DP_reg(i,j,:) = round(DP_reg(i,j,:));
        end
        clear b2 b3 X2 Y;
        
        % Plot
        % -----------------------------------------------------------------
        if fig == 1
            figure; hold on;
            plot(squeeze(DP(i,j,:)),'red');
            plot(squeeze(DP_reg(i,j,:)),'green');

        end
        
    end
    
end
stats