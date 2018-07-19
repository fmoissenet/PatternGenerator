% =========================================================================
% =========================================================================
% FIT NORMAL GAIT: Predict kinematics based on walking speed, age, sex, BMI
% =========================================================================
% Function: MAIN_fitGait
% =========================================================================
% Authors: F. Moissenet
% Creation: 06 July 2017
% Version: v2.0
% =========================================================================
% =========================================================================

clearvars;
clc;
warning ('off','all');
cd('C:\Users\florent.moissenet\Documents\Professionnel\publications\articles\1- en cours\Moissenet - Generateur de pattern\Matlab');
addpath('C:\Users\florent.moissenet\Documents\Professionnel\publications\articles\1- en cours\Moissenet - Generateur de pattern\Matlab');
addpath('C:\Users\florent.moissenet\Documents\Professionnel\publications\articles\1- en cours\Moissenet - Generateur de pattern\Matlab\Data');

% =========================================================================
% Initialisation
% =========================================================================

% Constant variables
% -------------------------------------------------------------------------
N = 52; % number of subjects
C = 30; % maximum cycles per subject (arbitrary value)
V = 5; % number of walking speed conditions
T = 101; % number of frames
J = 1; % selected joint
minVf = 0.1; % Froude velocity minimum threshold => selected to have an almost constant walk ratio among the data
maxVf = 0.8; % Froude velocity maximum threshold => selected to have an almost constant walk ratio among the data + Martin et al. 2014
stepVf = 0.05; % Froude velocity increment
pReg = 0.01; % level of significance p-value threshold for correlations
correlations = {'Constant','Walking speed','Age','Sex','BMI'};

% Load data merged by walking speed conditions
% -------------------------------------------------------------------------
File(1) = load('Norm_V1.mat');
File(2) = load('Norm_V2.mat');
File(3) = load('Norm_V3.mat');
File(4) = load('Norm_V4.mat');
File(5) = load('Norm_V5.mat');

% =========================================================================
% Lower limb kinematic data
% =========================================================================

% -------------------------------------------------------------------------
% Define indices to find data related to each subject in inputs
% -------------------------------------------------------------------------
icycle = nan(N,C,V);
isubject = nan(1000,V);
for v = 1:V
    n = 1;
    last_cycle = 1;
    current_name = 'empty';
    for i = 1:size(File(v).Normatives.Kinematics.sujets,2)
        temp = [];
        previous_name = current_name;
        current_name = File(v).Normatives.Kinematics.sujets(i);
        if strcmp(previous_name,'empty') || ~strcmp(current_name,previous_name)
            if (v == 1 && i == 261) || (v == 2 && i == 255) || (v == 3 && i == 257) ...
                    || (v == 4 && i == 259) || (v == 5 && i == 259)
                n_cycles = 10;
                temp = find(strcmp(File(v).Normatives.Kinematics.sujets,current_name));  
                icycle(n,1:n_cycles,v) = temp(1:1+n_cycles-1);  
            elseif (v == 1 && i == 423) || (v == 2 && i == 413) || (v == 3 && i == 413) ...
                    || (v == 4 && i == 415) || (v == 5 && i == 415)
                if v == 3
                    n_cycles = 8;
                else
                    n_cycles = 10;
                end
                temp = find(strcmp(File(v).Normatives.Kinematics.sujets,current_name));  
                icycle(n,1:n_cycles,v) = temp(11:11+n_cycles-1);    
            else
                n_cycles = length(find(strcmp(File(v).Normatives.Kinematics.sujets,current_name)));
                icycle(n,1:n_cycles,v) = find(strcmp(File(v).Normatives.Kinematics.sujets,current_name));    
            end
            n = n+1;
        end
    end
    temp = [];
    index = 1;
    for i = 1:size(File(v).Normatives.Kinematics.sujets,2)
        if i ~= size(File(v).Normatives.Kinematics.sujets,2)
            if ~strcmp(File(v).Normatives.Kinematics.sujets(i),File(v).Normatives.Kinematics.sujets(i+1))
                temp = [temp; index];
                index = index+1;
            else
                temp = [temp; index];
            end
        else
            temp = [temp; index];
        end
    end
    isubject(1:size(temp,1),v) = temp;
end
clear v n last_cycle current_name i temp previous_name current_name n_cycles index temp;

% -------------------------------------------------------------------------
% Define joints
% -------------------------------------------------------------------------
Joint(1).name = 'Ankle';
Joint(1).code = 'FE2';
Joint(1).sign = 1;
Joint(2).name = 'Knee';
Joint(2).code = 'FE3';
Joint(2).sign = -1;
Joint(3).name = 'Hip';
Joint(3).code = 'FE4';
Joint(3).sign = 1;

% -------------------------------------------------------------------------
% Estimate the correlations and the population variance
% -------------------------------------------------------------------------

% Define the sublist of subjects
% -------------------------------------------------------------------------
rsubject = 0;
subject_sub = 1:N; % no subject removed

% Extract data
% -------------------------------------------------------------------------
Raw = extractData(File,Joint,icycle,isubject,subject_sub,rsubject,N,V,T,J,'training');
Sort = prepareData(Raw,minVf,maxVf);
% for i = 1:size(Sort.kinematics,2)
%     Sort.kinematics(:,i) = Sort.kinematics(:,i) - Sort.kinematics(1,i);
% end
save('Sort.mat','Sort');

% Compute mean and standard deviation of each parameter for the population
% -------------------------------------------------------------------------
[Mean,Population] = computeMean(Sort,minVf,maxVf,stepVf);
save('Population.mat','Population','Mean');

% Determine discrete points
% -------------------------------------------------------------------------
for i = 1:size(Sort.kinematics,2)
    Fit.DP(:,:,i) = discretePoints(Joint(J).code,Sort.kinematics(:,i),...
        [Sort.IFS1(:,i); Sort.IFS2(:,i)],Sort.IFO(:,i),Sort.CFS(:,i),Sort.CFO(:,i),0);
end
clear i;

% Compute fitting quintic splines
% -------------------------------------------------------------------------
for i = 1:size(Sort.kinematics,2)
    Fit.kinematics(:,i) = quinticSpline(Fit.DP(:,:,i),0);%,1,Sort.kinematics(:,i));
end
% mean(sqrt(mean((Fit.kinematics(:,:)-Sort.kinematics(:,:)).^2)))
% std(sqrt(mean((Fit.kinematics(:,:)-Sort.kinematics(:,:)).^2)))
save('Fitting.mat','Fit');
clear i;

% Compute the multivariate regression
% -------------------------------------------------------------------------
X = [Sort.walkingSpeed' Sort.age' Sort.sex' Sort.BMI'];
[Reg.DP,Predictors] = computeRegression(X,Fit.DP,correlations,pReg,0);
save('Predictors.mat','Predictors');

% Compute regression quintic splines
% -------------------------------------------------------------------------
for i = 1:size(Sort.kinematics,2)
    Reg.kinematics(:,i) = quinticSpline(Reg.DP(:,:,i),0);
end
% for i = 1:20:size(Sort.kinematics,2)
%     figure;
%     Reg.kinematics(:,i) = quinticSpline(Reg.DP(:,:,i),1,Sort.kinematics(:,i),Fit.kinematics(:,i),Fit.DP(:,:,i));
% end
save('Regression.mat','Reg');
clear i;

% Export correlations
% -------------------------------------------------------------------------
filename = 'tableCorrelations.csv';
% exportCorrelations(Joint,Predictors,J,filename);

%%
clearvars -except N C V T J minVf maxVf stepVf pReg File Joint icycle isubject correlations

% =========================================================================
% Leave-one-out validation
% =========================================================================
s = 1;
for rsubject = 1:N
    
    clear Predictors;
    clc;
    disp(['Removed subject: ',num2str(rsubject)]);
    
    % =====================================================================
    % Training dataset : All subjects except rsubject
    % =====================================================================
    
    % Define the sublist of subjects
    % ---------------------------------------------------------------------
    if rsubject == 0
        subject_sub(:,s) = 1:N;
    elseif rsubject == 1
        subject_sub(:,s) = 2:N;
    elseif rsubject == N
        subject_sub(:,s) = 1:N-1;
    else
        subject_sub(:,s) = [1:rsubject-1 rsubject+1:N];
    end
    
    % Extract data
    % ---------------------------------------------------------------------
    Raw = extractData(File,Joint,icycle,isubject,subject_sub(:,s),rsubject,N,V,T,J,'training');
    Sort = prepareData(Raw,minVf,maxVf);
    for i = 1:size(Sort.kinematics,2)
        Sort.kinematics(:,i) = Sort.kinematics(:,i) - Sort.kinematics(1,i);
    end
        
    % Determine discrete points
    % ---------------------------------------------------------------------
    for i = 1:size(Sort.kinematics,2)
        Fit.DP(:,:,i) = discretePoints(Joint(J).code,Sort.kinematics(:,i),...
            [Sort.IFS1(:,i); Sort.IFS2(:,i)],Sort.IFO(:,i),Sort.CFS(:,i),Sort.CFO(:,i),0);
    end
    clear i;
    
    % Compute fitting quintic splines
    % ---------------------------------------------------------------------
    for i = 1:size(Sort.kinematics,2)
        Fit.kinematics(:,i) = quinticSpline(Fit.DP(:,:,i),0);%1,Sort.kinematics(:,i));
    end
    clear i;
    
    % Compute the multivariate regression
    % ---------------------------------------------------------------------
    X = [Sort.walkingSpeed' Sort.age' Sort.sex' Sort.BMI'];
    [Reg.DP,Predictors] = computeRegression(X,Fit.DP,correlations,pReg,0);
    clear X;
    
    % Compute regression quintic splines
    % ---------------------------------------------------------------------
    for i = 1:size(Sort.kinematics,2)
        Reg.kinematics(:,i) = quinticSpline(Reg.DP(:,:,i),0);%1,Sort.kinematics(:,i),Fit.kinematics(:,i),Fit.DP(:,:,i));
    end
    clear i;
    
    % =====================================================================
    % Testing dataset : Try regressions on rsubject
    % =====================================================================
    clearvars -except N C V T J minVf maxVf stepVf pReg File Joint icycle isubject rsubject Predictors s subject_sub Validation correlations
    
    % Extract data
    % ---------------------------------------------------------------------
    Raw = extractData(File,Joint,icycle,isubject,subject_sub(:,s),rsubject,N,V,T,J,'testing');
    Sort = prepareData(Raw,minVf,maxVf);
    for i = 1:size(Sort.kinematics,2)
        Sort.kinematics(:,i) = Sort.kinematics(:,i) - Sort.kinematics(1,i);
    end
    
    % Apply the multivariate regression
    % ---------------------------------------------------------------------
    X = [Sort.walkingSpeed' Sort.age' Sort.sex' Sort.BMI'];
    Reg.DP = applyRegression(X,Predictors);
    clear X;
    
    % Determine discrete points (only use for validation)
    % ---------------------------------------------------------------------
    for i = 1:size(Sort.kinematics,2)
        Fit.DP(:,:,i) = discretePoints(Joint(J).code,Sort.kinematics(:,i),...
            [Sort.IFS1(:,i); Sort.IFS2(:,i)],Sort.IFO(:,i),Sort.CFS(:,i),Sort.CFO(:,i),0);
    end
    clear i;
    
    % Compute regression quintic splines and the associate error
    % ---------------------------------------------------------------------
    for i = 1:size(Sort.kinematics,2)
        Reg.kinematics(:,i) = quinticSpline(Reg.DP(:,:,i),0);%1,Sort.kinematics(:,i));
        Validation(s).Speed(i) = Sort.walkingSpeed(:,i);
        Validation(s).RMSE(i) = sqrt(mean((Reg.kinematics(:,i)-Sort.kinematics(:,i)).^2));
        Validation(s).R2(i) = 1 - sum((Reg.kinematics(:,i)-Sort.kinematics(:,i)).^2)/...
            sum((Reg.kinematics(:,i)-mean(Sort.kinematics(:,i),1)).^2);
        Validation(s).MAX(i) = abs(max(Reg.kinematics(:,i)-Sort.kinematics(:,i)));
        Validation(s).VAF(i) = (1-var(Reg.kinematics(:,i)-Sort.kinematics(:,i))/var(Reg.kinematics(:,i)))*100;
%         Validation(s).DP1(i) = abs(Reg.DP(1,2,i)-Fit.DP(1,2,i));
    end
    clear i;
    
    s = s+1;
    
end
%%
% =========================================================================
% Results of the validation
% =========================================================================
load('Population.mat');
figure;

k = 1;
% stepVf = 0.01;
temp2_full = [];
population_mean = [];
population_std = [];
for vf = minVf:stepVf:0.75%maxVf   
    temp1 = [];
    temp2 = [];
    temp3 = [];
    temp4 = [];
    temp5 = [];
%     temp6 = [];
    for i = 1:size(Validation,2)
        for j = 1:size(Validation(1,i).Speed,2)     
            if abs(Validation(1,i).Speed(j)-vf) < stepVf/2
                temp1 = [temp1 Validation(1,i).Speed(j)];
                temp2 = [temp2 Validation(1,i).RMSE(j)];
                    temp2_full = [temp2_full Validation(1,i).RMSE(j)];
                temp3 = [temp3 Validation(1,i).R2(j)];
                temp4 = [temp4 Validation(1,i).MAX(j)];
                temp5 = [temp5 Validation(1,i).VAF(j)];
%                 temp6 = [temp6 Validation(1,i).DP5(j)];
            end
        end
    end
    subplot(1,3,1);
    hold on;
    title('RMSE (°)');
    box on;
    errorbar(vf,mean(temp2),std(temp2),'kx');
    population_mean = [population_mean Population.RMSE(k).mean];
    population_std = [population_std Population.RMSE(k).std];
    subplot(1,3,2);
    hold on;
    title('R2');
    box on;
    errorbar(vf,mean(temp3),std(temp3),'kx');
%     errorbar(vf,Population.R2(k).mean,Population.R2(k).std,'rx');  
%         population_mean = [population_mean Population.R2(k).mean];
%         population_std = [population_std Population.R2(k).std];
    subplot(1,3,3);
    hold on;
    title('VAF (%)');
    box on;
    errorbar(vf,mean(temp5),std(temp5),'kx');
%     errorbar(vf,Population.VAF(k).mean,Population.VAF(k).std,'rx');  
%         population_mean = [population_mean Population.VAF(k).mean];
%         population_std = [population_std Population.VAF(k).std];
    k = k+1;
end
subplot(1,3,1);
corridor(population_mean',population_std',minVf,stepVf,0.75,'red');  
%%
% RMSE per subject
% figure;
hold on;
xlabel('Subject');
ylabel('RMSE (°)');

for i = 1:size(Validation,2)   
    temp2 = [];
    for j = 1:size(Validation(1,i).RMSE,2)     
        temp2 = [temp2 Validation(1,i).RMSE(j)];
    end
    errorbar(i,mean(temp2),std(temp2),'bx');
end
%%
% =========================================================================
% Try it yourself !
% =========================================================================
load('Predictors.mat');
% stepLength = 0.2;%input('Step length? ');
% cadence = stepLength/0.0076;%input('Cadence? ');
% walkRatio = stepLength/cadence;
walkingSpeed = 0.3;
age = 34;%input('Subject age? ');
sex = 0;%input('Subject gender (0: man, 1: woman)? ');
size = 1.64;%input('Subject size (m)? ');
legLength = 0.8;%input('Subject leg length (m)? ');
weight = 65;%input('Subject weight (kg)? ');
BMI = weight/size^2;
X = [walkingSpeed age sex BMI];
Test.DP = applyRegression(X,Predictors);
Reg.kinematics = quinticSpline(Test.DP,1);
%%
% =========================================================================
% Plot angular variations per walking speed
% =========================================================================
clearvars -except File minVf maxVf stepVf;
load('Population.mat');
load('Sort.mat');
load('Regression.mat');
load('Fitting.mat');
load('Predictors.mat');
% figure;
% hold on;

% Population
figure;
hold on;
clear kin Test X
title('Population');
D = colormap(jet(size(Sort.kinematics(1,1:50:size(Sort.kinematics,2)),2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(Sort.kinematics(:,1:50:size(Sort.kinematics,2)));
xlim([0 101]);
% ylim([-20 20]);

% Fitting
figure;
hold on;
clear kin Test X
title('Fitting');
D = colormap(jet(size(Fit.kinematics(1,1:50:size(Fit.kinematics,2)),2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(Fit.kinematics(:,1:50:size(Fit.kinematics,2)));
xlim([0 101]);
% ylim([-20 20]);

% Regression
figure;
hold on;
clear kin Test X
title('Simulation');
D = colormap(jet(size(Reg.kinematics(1,1:50:size(Reg.kinematics,2)),2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(Reg.kinematics(:,1:50:size(Reg.kinematics,2)));
xlim([0 101]);
% ylim([-20 20]);
%%
% Walking speed
figure;
clear kin Test X
j = 1;
for i = minVf:stepVf:maxVf 
    walkingSpeed = i;
    stepLength = mean(Sort.stepLength);
    cadence = mean(Sort.cadence);
    wr = stepLength/cadence;
    age = mean(Sort.age);
    sex = 0;
    BMI = mean(Sort.BMI);
    legLength = mean(Sort.LL);
    X = [walkingSpeed age sex BMI];
    Test.DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test.DP,0);
    j = j+1;
end
% subplot(1,9,3);
title('Walking speed');
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(kin);
xlim([0 101]);
% ylim([-20 20]);

% Step length
clear kin Test X
j = 1;
for i = min(Sort.stepLength):(max(Sort.stepLength)-min(Sort.stepLength))/10:max(Sort.stepLength)
    walkingSpeed = mean(Sort.walkingSpeed);
    stepLength = i;
    cadence = mean(Sort.cadence);
    wr = stepLength/cadence;
    age = mean(Sort.age);
    sex = 0;
    BMI = mean(Sort.BMI);
    legLength = mean(Sort.LL);
    X = [walkingSpeed stepLength cadence wr age sex BMI];
    Test.DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test.DP,0);
    j = j+1;
end
subplot(1,9,4);
title('Step length');
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(kin);
xlim([0 101]);
ylim([-20 20]);

% Cadence
clear kin Test X
j = 1;
for i = min(Sort.cadence):(max(Sort.cadence)-min(Sort.cadence))/10:max(Sort.cadence)
    walkingSpeed = mean(Sort.walkingSpeed);
    stepLength = mean(Sort.stepLength);
    cadence = i;
    wr = stepLength/cadence;
    age = mean(Sort.age);
    sex = 0;
    BMI = mean(Sort.BMI);
    legLength = mean(Sort.LL);
    X = [walkingSpeed stepLength cadence wr age sex BMI];
    Test.DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test.DP,0);
    j = j+1;
end
subplot(1,9,5);
title('Cadence');
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(kin);
xlim([0 101]);
ylim([-20 20]);

% Walk ratio
clear kin Test X
j = 1;
for i = min(Sort.stepLength)/min(Sort.cadence):(max(Sort.stepLength)/max(Sort.cadence)-min(Sort.stepLength)/min(Sort.cadence))/10:max(Sort.stepLength)/max(Sort.cadence)
    walkingSpeed = mean(Sort.walkingSpeed);
    stepLength = mean(Sort.stepLength);
    cadence = mean(Sort.cadence);
    wr = i;
    age = mean(Sort.age);
    sex = 0;
    BMI = mean(Sort.BMI);
    legLength = mean(Sort.LL);
    X = [walkingSpeed stepLength cadence wr age sex BMI];
    Test.DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test.DP,0);
    j = j+1;
end
subplot(1,9,6);
title('Walk ratio');
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(kin);
xlim([0 101]);
ylim([-20 20]);

% Age
clear kin Test X
j = 1;
for i = min(Sort.age):(max(Sort.age)-min(Sort.age))/10:max(Sort.age)
    walkingSpeed = mean(Sort.walkingSpeed);
    stepLength = mean(Sort.stepLength);
    cadence = mean(Sort.cadence);
    wr = stepLength/cadence;
    age = i;
    sex = 0;
    BMI = mean(Sort.BMI);
    legLength = mean(Sort.LL);
    X = [walkingSpeed stepLength cadence wr age sex BMI];
    Test.DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test.DP,0);
    j = j+1;
end
subplot(1,9,7);
title('Age');
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(kin);
xlim([0 101]);
ylim([-20 20]);

% BMI
clear kin Test X
j = 1;
for i = min(Sort.BMI):(max(Sort.BMI)-min(Sort.BMI))/10:max(Sort.BMI)
    walkingSpeed = mean(Sort.walkingSpeed);
    stepLength = mean(Sort.stepLength);
    cadence = mean(Sort.cadence);
    wr = stepLength/cadence;
    age = mean(Sort.age);
    sex = 0;
    BMI = i;
    legLength = mean(Sort.LL);
    X = [walkingSpeed stepLength cadence wr age sex BMI];
    Test.DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test.DP,0);
    j = j+1;
end
subplot(1,9,8);
title('BMI');
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(kin);
xlim([0 101]);
ylim([-20 20]);

% Sex
clear kin Test X
j = 1;
for i = 0:1:1
    walkingSpeed = mean(Sort.walkingSpeed);
    stepLength = mean(Sort.stepLength);
    cadence = mean(Sort.cadence);
    age = mean(Sort.age);
    sex = i;
    BMI = mean(Sort.BMI);
    legLength = mean(Sort.LL);
    X = [walkingSpeed stepLength cadence wr age sex BMI];
    Test.DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test.DP,0);
    j = j+1;
end
subplot(1,9,9);
title('Sex');
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(kin);
xlim([0 101]);
ylim([-20 20]);