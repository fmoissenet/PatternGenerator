% =========================================================================
% =========================================================================
% FIT NORMAL GAIT: Predict kinematics based on walking speed, age, sex, BMI
% =========================================================================
% Function: quinticSpline
% =========================================================================
% Authors: F. Moissenet
% Creation: 06 July 2017
% Version: v1.0
% =========================================================================
% =========================================================================

function fit = quinticSpline(DP,fig,ekin1,ekin2,eDP2)

if fig == 1
    figure; hold on;
end

% =========================================================================
% Spline fitting procedure
% =========================================================================
for i = 1:size(DP,1)-1
    
%     % General resolution for 3th order quintic splines
%     % ---------------------------------------------------------------------
%     X = [1 DP(i,1) DP(i,1)^2 DP(i,1)^3;...
%         0 1 2*DP(i,1) 3*DP(i,1)^2;...
%         0 0 2 6*DP(i,1);...
%         1 DP(i+1,1) DP(i+1,1)^2 DP(i+1,1)^3;...
%         0 1 2*DP(i+1,1) 3*DP(i+1,1)^2;...
%         0 0 2 6*DP(i+1,1)];
%     Y = [DP(i,2);DP(i,3);DP(i,4);DP(i+1,2);DP(i+1,3);DP(i+1,4)];
%     coeff(:,i) = X\Y;
%     
%     % Compute the parameters (angle, velocity, acceleration) from the
%     % resulting spline between DP_i and DP_i+1
%     % ---------------------------------------------------------------------
%     if i == size(DP,1)-1
%         for x = DP(i,1):DP(i+1,1)
%             pA(x) =  [1 x x^2 x^3] * coeff(:,i);
%             pdA(x) = [0 1 2*x 3*x^2] * coeff(:,i);
%             pddA(x) = [0 0 2 6*x] * coeff(:,i);
%         end
%     else
%         for x = DP(i,1):DP(i+1,1)-1
%             pA(x) =  [1 x x^2 x^3] * coeff(:,i);
%             pdA(x) = [0 1 2*x 3*x^2] * coeff(:,i);
%             pddA(x) = [0 0 2 6*x] * coeff(:,i);
%         end
%     end
    
    % General resolution for 5th order quintic splines
    % ---------------------------------------------------------------------
    X = [1 DP(i,1) DP(i,1)^2 DP(i,1)^3 DP(i,1)^4 DP(i,1)^5;...
         0 1 2*DP(i,1) 3*DP(i,1)^2 4*DP(i,1)^3 5*DP(i,1)^4;...
         0 0 2 6*DP(i,1) 12*DP(i,1)^2 20*DP(i,1)^3;...
         1 DP(i+1,1) DP(i+1,1)^2 DP(i+1,1)^3 DP(i+1,1)^4 DP(i+1,1)^5;...
         0 1 2*DP(i+1,1) 3*DP(i+1,1)^2 4*DP(i+1,1)^3 5*DP(i+1,1)^4;...
         0 0 2 6*DP(i+1,1) 12*DP(i+1,1)^2 20*DP(i+1,1)^3];
    Y = [DP(i,2);DP(i,3);DP(i,4);DP(i+1,2);DP(i+1,3);DP(i+1,4)];
    coeff(:,i) = X\Y;
    
    % Compute the parameters (angle, velocity, acceleration) from the
    % resulting spline between DP_i and DP_i+1
    % ---------------------------------------------------------------------
    if i == size(DP,1)-1
        for x = DP(i,1):DP(i+1,1)
            pA(x) =  [1 x x^2 x^3 x^4 x^5] * coeff(:,i);
            pdA(x) = [0 1 2*x 3*x^2 4*x^3 5*x^4] * coeff(:,i);
            pddA(x) = [0 0 2 6*x 12*x^2 20*x^3] * coeff(:,i);
        end
    else
        for x = DP(i,1):DP(i+1,1)-1
            pA(x) =  [1 x x^2 x^3 x^4 x^5] * coeff(:,i);
            pdA(x) = [0 1 2*x 3*x^2 4*x^3 5*x^4] * coeff(:,i);
            pddA(x) = [0 0 2 6*x 12*x^2 20*x^3] * coeff(:,i);
        end
    end
    
    if fig == 1
        subplot(3,1,1); hold on;
        plot(DP(i,1),DP(i,2),'Marker','x');
        plot(DP(i+1,1),DP(i+1,2),'Marker','x');
        subplot(3,1,2); hold on;
        plot(DP(i,1),DP(i,3),'Marker','x');
        plot(DP(i+1,1),DP(i+1,3),'Marker','x');
        subplot(3,1,3); hold on;
        plot(DP(i,1),DP(i,4),'Marker','x');
        plot(DP(i+1,1),DP(i+1,4),'Marker','x');
        subplot(3,1,1); hold on; title('Angle');
        subplot(3,1,2); hold on; title('Angular velocity');
        subplot(3,1,3); hold on; title('Angular acceleration');
    end
    if nargin >= 5
        subplot(3,1,1); hold on;
        plot(eDP2(i,1),eDP2(i,2),'Marker','o');
        plot(eDP2(i+1,1),eDP2(i+1,2),'Marker','o');
        subplot(3,1,2); hold on;
        plot(eDP2(i,1),eDP2(i,3),'Marker','o');
        plot(eDP2(i+1,1),eDP2(i+1,3),'Marker','o');
        subplot(3,1,3); hold on;
        plot(eDP2(i,1),eDP2(i,4),'Marker','o');
        plot(eDP2(i+1,1),eDP2(i+1,4),'Marker','o');
    end
end

if fig == 1
    subplot(3,1,1); hold on;
    plot(1:101,pA,'blue');
    subplot(3,1,2); hold on;
    plot(1:101,pdA,'blue');
    subplot(3,1,3); hold on;
    plot(1:101,pddA,'blue');
    subplot(3,1,1); hold on; title('Angle');
    subplot(3,1,2); hold on; title('Angular velocity');
    subplot(3,1,3); hold on; title('Angular acceleration');
end
if nargin >= 3
    A(1,:) = ekin1';
    dA(1,:) = diff(A(1,:));
    ddA(1,:) = diff(dA(1,:));
    subplot(3,1,1); hold on;
    plot(1:101,A,'red');
    subplot(3,1,2); hold on;
    plot(1:100,dA,'red');
    subplot(3,1,3); hold on;
    plot(1:99,ddA,'red');
end
if nargin >= 4
    B(1,:) = ekin2';
    dB(1,:) = diff(B(1,:));
    ddB(1,:) = diff(dB(1,:));
    subplot(3,1,1); hold on;
    plot(1:101,B,'green');
    subplot(3,1,2); hold on;
    plot(1:100,dB,'green');
    subplot(3,1,3); hold on;
    plot(1:99,ddB,'green');
end

% =========================================================================
% Export angle
% =========================================================================
fit = pA;