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
cd('C:\Users\florent.moissenet\Documents\Professionnel\routines\github\PatternGenerator');
addpath('C:\Users\florent.moissenet\Documents\Professionnel\routines\github\PatternGenerator');
addpath('C:\Users\florent.moissenet\Documents\Professionnel\routines\github\PatternGenerator\Data');

% =========================================================================
% Initialisation
% =========================================================================

% Constant variables
% -------------------------------------------------------------------------
N = 52; % number of subjects
C = 30; % maximum cycles per subject (arbitrary value)
V = 5; % number of walking speed conditions
T = 101; % number of frames
J = 2; % selected joint
minVf = 0.1; % Froude velocity minimum threshold => selected to have an almost constant walk ratio among the data
maxVf = 0.8; % Froude velocity maximum threshold => selected to have an almost constant walk ratio among the data + Martin et al. 2014
stepVf = 0.05; % Froude velocity increment
pReg = 0.01; % level of significance p-value threshold for correlations
% correlations = {'Constant','Walking speed'};
correlations = {'Constant','Walking speed','Age','Sex','BMI'};

% Load data merged by walking speed conditions
% -------------------------------------------------------------------------
File(1) = load('Norm_V1.mat');
File(2) = load('Norm_V2.mat');
File(3) = load('Norm_V3.mat');
File(4) = load('Norm_V4.mat');
File(5) = load('Norm_V5.mat');
for i = 1:5 % error on the height of one subject (0.8 instead of 1.8 m)
    File(i).Population.height.data(33) = 1.8;
end

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
% X = [Sort.walkingSpeed'];
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
%     X = [Sort.walkingSpeed'];
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
%     X = [Sort.walkingSpeed'];
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
close all;
fig = figure('pos',[10 10 1100 300]);

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
    title('RMSE');
%     xlabel('Non-dimensionalised walking speed');
%     ylabel('Ankle DF/PF (°)');
%     ylabel('Knee Flex/Ext (°)');
    ylabel('Hip Flex/Ext (°)');
    box on;
    grid on;
    errorbar(vf,mean(temp2),std(temp2),'kx');
%     ylim([0 11]); % ankle
%     ylim([0 14]); % knee
    ylim([0 10]); % hip
    population_mean = [population_mean Population.RMSE(k).mean];
    population_std = [population_std Population.RMSE(k).std];
    subplot(1,3,2);
    hold on;
    title('R2');
%     xlabel('Non-dimensionalised walking speed');
%     ylabel('Ankle DF/PF');
%     ylabel('Knee Flex/Ext');
    ylabel('Hip Flex/Ext');
    box on;
    grid on;
    errorbar(vf,mean(temp3),std(temp3),'kx');
    plot([0:0.1:0.8],0.3*ones(size([0:0.1:0.8])),'Linestyle','--','Color','black');
    plot([0:0.1:0.8],0.6*ones(size([0:0.1:0.8])),'Linestyle','--','Color','black');
    plot([0:0.1:0.8],0.9*ones(size([0:0.1:0.8])),'Linestyle','--','Color','black');
    ylim([0 1]);
%     errorbar(vf,Population.R2(k).mean,Population.R2(k).std,'rx');  
%         population_mean = [population_mean Population.R2(k).mean];
%         population_std = [population_std Population.R2(k).std];
    subplot(1,3,3);
    hold on;
    title('VAF');
%     xlabel('Non-dimensionalised walking speed');
%     ylabel('Ankle DF/PF (%)');
%     ylabel('Knee Flex/Ext (%)');
    ylabel('Hip Flex/Ext (%)');
    box on;
    grid on;
    errorbar(vf,mean(temp5),std(temp5),'kx');
    plot([0:0.1:0.8],80*ones(size([0:0.1:0.8])),'Linestyle','--','Color','black');
    ylim([0 100]);
%     errorbar(vf,Population.VAF(k).mean,Population.VAF(k).std,'rx');  
%         population_mean = [population_mean Population.VAF(k).mean];
%         population_std = [population_std Population.VAF(k).std];
    k = k+1;
end
subplot(1,3,1);
corridor(population_mean',population_std',minVf,stepVf,0.75,'black');  
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
X = [walkingSpeed];
% X = [walkingSpeed age sex BMI];
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


%% HIP / Predictors' contribution
close all;
clearvars -except File minVf maxVf stepVf;
load('Population.mat');
load('Sort.mat');
load('Regression.mat');
load('Fitting.mat');
load('Predictors.mat');
fig = figure('pos',[10 10 1450 300]);
fig.PaperSize = [20 5];

% Walking speed
clear kin Test X
j = 1;
for i = minVf:stepVf:maxVf 
    walkingSpeed = i;
    age = median(Sort.age);
    sex = median(Sort.sex);
    BMI = median(Sort.BMI);
    X = [walkingSpeed age sex BMI];
    Test(j).DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test(j).DP,0);
    j = j+1;
end
h1 = subplot(1,4,1);
set(h1,'Position',[0.1295,0.35,0.1575,0.6]);
ylabel('Hip Flex(+)/Ext (°)');
set(get(h1,'xlabel'),'Position',[52 -25 0]);
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(median(kin,2),'Linestyle','--','Color','black');
hold on;
x = [1:1:101 101:-1:1]';
pMax = max(kin,[],2);
pMin = min(kin,[],2);
y = [pMax;pMin(end:-1:1)];
A = fill(x,y,'black','LineStyle','none','Facealpha',0.3);
for i = 1:size(kin,2)
    for j = 1:size(Test(1,1).DP,1) % number of key points
        plot(Test(1,i).DP(j,1),Test(1,i).DP(j,2),'Marker','.','color',D(i,:),'Markersize',15);
    end
end
% Amplitude of key point angular value
disp('Walking speed')
for i = 1:size(Test(1,1).DP,1)
    temp = [];
    for j = 1:size(kin,2)
        temp = [temp Test(1,j).DP(i,2)]; 
    end
    max(temp)-min(temp)
end
xlim([0 101]);
ylim([-25 35]);

% Age
clear kin Test X
j = 1;
for i = min(Sort.age):4:65%max(Sort.age) 
    walkingSpeed = median(Sort.walkingSpeed);
    age = i;
    sex = median(Sort.sex);
    BMI = median(Sort.BMI);
    X = [walkingSpeed age sex BMI];
    Test(j).DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test(j).DP,0);
    j = j+1;
end
h2 = subplot(1,4,2);
set(h2,'Position',[0.33,0.35,0.1575,0.6]);
set(get(h2,'xlabel'),'Position',[52 -25 0]);
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(median(kin,2),'Linestyle','--','Color','black');
hold on;
x = [1:1:101 101:-1:1]';
pMax = max(kin,[],2);
pMin = min(kin,[],2);
y = [pMax;pMin(end:-1:1)];
A = fill(x,y,'black','LineStyle','none','Facealpha',0.3);
for i = 1:size(kin,2)
    for j = 1:size(Test(1,1).DP,1) % number of key points
        plot(Test(1,i).DP(j,1),Test(1,i).DP(j,2),'Marker','.','color',D(i,:),'Markersize',15);
    end
end
% Amplitude of key point angular value
disp('Age')
for i = 1:size(Test(1,1).DP,1)
    temp = [];
    for j = 1:size(kin,2)
        temp = [temp Test(1,j).DP(i,2)]; 
    end
    max(temp)-min(temp)
end
xlim([0 101]);
ylim([-25 35]);

% Sex
clear kin Test X
j = 1;
for i = [0 1]
    walkingSpeed = median(Sort.walkingSpeed);
    age = median(Sort.age);
    sex = i;
    BMI = median(Sort.BMI);
    X = [walkingSpeed age sex BMI];
    Test(j).DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test(j).DP,0);
    j = j+1;
end
h3 = subplot(1,4,3);
set(h3,'Position',[0.53,0.35,0.1575,0.6]);
set(get(h3,'xlabel'),'Position',[52 -25 0]);
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(median(kin,2),'Linestyle','--','Color','black');
hold on;
x = [1:1:101 101:-1:1]';
pMax = max(kin,[],2);
pMin = min(kin,[],2);
y = [pMax;pMin(end:-1:1)];
A = fill(x,y,'black','LineStyle','none','Facealpha',0.3);
for i = 1:size(kin,2)
    for j = 1:size(Test(1,1).DP,1) % number of key points
        plot(Test(1,i).DP(j,1),Test(1,i).DP(j,2),'Marker','.','color',D(i,:),'Markersize',15);
    end
end
% Amplitude of key point angular value
disp('Sex')
for i = 1:size(Test(1,1).DP,1)
    temp = [];
    for j = 1:size(kin,2)
        temp = [temp Test(1,j).DP(i,2)]; 
    end
    max(temp)-min(temp)
end
xlim([0 101]);
ylim([-25 35]);

% BMI
clear kin Test X
j = 1;
for i = 17:1:31 
    walkingSpeed = median(Sort.walkingSpeed);
    age = median(Sort.age);
    sex = median(Sort.sex);
    BMI = i;
    X = [walkingSpeed age sex BMI];
    Test(j).DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test(j).DP,0);
    j = j+1;
end
h4 = subplot(1,4,4);
set(h4,'Position',[0.73,0.35,0.1575,0.6]);
set(get(h4,'xlabel'),'Position',[52 -25 0]);
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(median(kin,2),'Linestyle','--','Color','black');
hold on;
x = [1:1:101 101:-1:1]';
pMax = max(kin,[],2);
pMin = min(kin,[],2);
y = [pMax;pMin(end:-1:1)];
A = fill(x,y,'black','LineStyle','none','Facealpha',0.3);
for i = 1:size(kin,2)
    for j = 1:size(Test(1,1).DP,1) % number of key points
        plot(Test(1,i).DP(j,1),Test(1,i).DP(j,2),'Marker','.','color',D(i,:),'Markersize',15);
    end
end
% Amplitude of key point angular value
disp('BMI')
for i = 1:size(Test(1,1).DP,1)
    temp = [];
    for j = 1:size(kin,2)
        temp = [temp Test(1,j).DP(i,2)]; 
    end
    max(temp)-min(temp)
end
xlim([0 101]);
ylim([-25 35]);

%% KNEE / Predictors' contribution
close all;
clearvars -except File minVf maxVf stepVf;
load('Population.mat');
load('Sort.mat');
load('Regression.mat');
load('Fitting.mat');
load('Predictors.mat');
fig = figure('pos',[10 10 1450 300]);
fig.PaperSize = [20 5];

% Walking speed
clear kin Test X
j = 1;
for i = minVf:stepVf:maxVf 
    walkingSpeed = i;
    age = median(Sort.age);
    sex = median(Sort.sex);
    BMI = median(Sort.BMI);
    X = [walkingSpeed age sex BMI];
    Test(j).DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test(j).DP,0);
    j = j+1;
end
h1 = subplot(1,4,1);
set(h1,'Position',[0.1295,0.35,0.1575,0.6]);
ylabel('Knee Flex(+)/Ext (°)');
set(get(h1,'xlabel'),'Position',[52 -25 0]);
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(median(kin,2),'Linestyle','--','Color','black');
hold on;
x = [1:1:101 101:-1:1]';
pMax = max(kin,[],2);
pMin = min(kin,[],2);
y = [pMax;pMin(end:-1:1)];
A = fill(x,y,'black','LineStyle','none','Facealpha',0.3);
for i = 1:size(kin,2)
    for j = 1:size(Test(1,1).DP,1) % number of key points
        plot(Test(1,i).DP(j,1),Test(1,i).DP(j,2),'Marker','.','color',D(i,:),'Markersize',15);
    end
end
% Amplitude of key point angular value
disp('Walking speed')
for i = 1:size(Test(1,1).DP,1)
    temp = [];
    for j = 1:size(kin,2)
        temp = [temp Test(1,j).DP(i,2)]; 
    end
    max(temp)-min(temp)
end
xlim([0 101]);
ylim([-5 70]);

% Age
clear kin Test X
j = 1;
for i = 20:4:65%min(Sort.age):4:max(Sort.age) 
    walkingSpeed = median(Sort.walkingSpeed);
    age = i;
    sex = median(Sort.sex);
    BMI = median(Sort.BMI);
    X = [walkingSpeed age sex BMI];
    Test(j).DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test(j).DP,0);
    j = j+1;
end
h2 = subplot(1,4,2);
set(h2,'Position',[0.33,0.35,0.1575,0.6]);
set(get(h2,'xlabel'),'Position',[52 -25 0]);
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(median(kin,2),'Linestyle','--','Color','black');
hold on;
x = [1:1:101 101:-1:1]';
pMax = max(kin,[],2);
pMin = min(kin,[],2);
y = [pMax;pMin(end:-1:1)];
A = fill(x,y,'black','LineStyle','none','Facealpha',0.3);
for i = 1:size(kin,2)
    for j = 1:size(Test(1,1).DP,1) % number of key points
        plot(Test(1,i).DP(j,1),Test(1,i).DP(j,2),'Marker','.','color',D(i,:),'Markersize',15);
    end
end
% Amplitude of key point angular value
disp('Age')
for i = 1:size(Test(1,1).DP,1)
    temp = [];
    for j = 1:size(kin,2)
        temp = [temp Test(1,j).DP(i,2)]; 
    end
    max(temp)-min(temp)
end
xlim([0 101]);
ylim([-5 70]);

% Sex
clear kin Test X
j = 1;
for i = [0 1]
    walkingSpeed = median(Sort.walkingSpeed);
    age = median(Sort.age);
    sex = i;
    BMI = median(Sort.BMI);
    X = [walkingSpeed age sex BMI];
    Test(j).DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test(j).DP,0);
    j = j+1;
end
h3 = subplot(1,4,3);
set(h3,'Position',[0.53,0.35,0.1575,0.6]);
set(get(h3,'xlabel'),'Position',[52 -25 0]);
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(median(kin,2),'Linestyle','--','Color','black');
hold on;
x = [1:1:101 101:-1:1]';
pMax = max(kin,[],2);
pMin = min(kin,[],2);
y = [pMax;pMin(end:-1:1)];
A = fill(x,y,'black','LineStyle','none','Facealpha',0.3);
for i = 1:size(kin,2)
    for j = 1:size(Test(1,1).DP,1) % number of key points
        plot(Test(1,i).DP(j,1),Test(1,i).DP(j,2),'Marker','.','color',D(i,:),'Markersize',15);
    end
end
% Amplitude of key point angular value
disp('Sex')
for i = 1:size(Test(1,1).DP,1)
    temp = [];
    for j = 1:size(kin,2)
        temp = [temp Test(1,j).DP(i,2)]; 
    end
    max(temp)-min(temp)
end
xlim([0 101]);
ylim([-5 70]);

% BMI
clear kin Test X
j = 1;
for i = 17:1:31 
    walkingSpeed = median(Sort.walkingSpeed);
    age = median(Sort.age);
    sex = median(Sort.sex);
    BMI = i;
    X = [walkingSpeed age sex BMI];
    Test(j).DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test(j).DP,0);
    j = j+1;
end
h4 = subplot(1,4,4);
set(h4,'Position',[0.73,0.35,0.1575,0.6]);
set(get(h4,'xlabel'),'Position',[52 -25 0]);
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(median(kin,2),'Linestyle','--','Color','black');
hold on;
x = [1:1:101 101:-1:1]';
pMax = max(kin,[],2);
pMin = min(kin,[],2);
y = [pMax;pMin(end:-1:1)];
A = fill(x,y,'black','LineStyle','none','Facealpha',0.3);
for i = 1:size(kin,2)
    for j = 1:size(Test(1,1).DP,1) % number of key points
        plot(Test(1,i).DP(j,1),Test(1,i).DP(j,2),'Marker','.','color',D(i,:),'Markersize',15);
    end
end
% Amplitude of key point angular value
disp('BMI')
for i = 1:size(Test(1,1).DP,1)
    temp = [];
    for j = 1:size(kin,2)
        temp = [temp Test(1,j).DP(i,2)]; 
    end
    max(temp)-min(temp)
end
xlim([0 101]);
ylim([-5 70]);

%% ANKLE / Predictors' contribution
close all;
clearvars -except File minVf maxVf stepVf;
load('Population.mat');
load('Sort.mat');
load('Regression.mat');
load('Fitting.mat');
load('Predictors.mat');
fig = figure('pos',[10 10 1450 300]);
fig.PaperSize = [20 5];

% Walking speed
clear kin Test X
j = 1;
for i = minVf:stepVf:maxVf 
    walkingSpeed = i;
    age = median(Sort.age);
    sex = median(Sort.sex);
    BMI = median(Sort.BMI);
    X = [walkingSpeed age sex BMI];
    Test(j).DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test(j).DP,0);
    j = j+1;
end
h1 = subplot(1,4,1);
set(h1,'Position',[0.1295,0.35,0.1575,0.6]);
title('Non-dimensionalised walking speed');
xlabel('Gait cycle (%)');
ylabel('Ankle DF(+)/PF (°)');
set(get(h1,'title'),'Position',[52 -43 0],'FontWeight','Normal');
set(get(h1,'xlabel'),'Position',[52 -25 0]);
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(median(kin,2),'Linestyle','--','Color','black');
hold on;
x = [1:1:101 101:-1:1]';
pMax = max(kin,[],2);
pMin = min(kin,[],2);
y = [pMax;pMin(end:-1:1)];
A = fill(x,y,'black','LineStyle','none','Facealpha',0.3);
for i = 1:size(kin,2)
    for j = 1:size(Test(1,1).DP,1) % number of key points
        plot(Test(1,i).DP(j,1),Test(1,i).DP(j,2),'Marker','.','color',D(i,:),'Markersize',15);
    end
end
% Amplitude of key point angular value
disp('Walking speed')
for i = 1:size(Test(1,1).DP,1)
    temp = [];
    for j = 1:size(kin,2)
        temp = [temp Test(1,j).DP(i,2)]; 
    end
    max(temp)-min(temp)
end
xlim([0 101]);
ylim([-20 20]);
colorbar('Location','southoutside','Position',[0.1295,0.15,0.1575,0.02],'TickLabels',{'0.10','0.45','0.80'},'TickDirection','in');
colormap(h1,'jet');

% Age
clear kin Test X
j = 1;
for i = min(Sort.age):4:65%max(Sort.age) 
    walkingSpeed = median(Sort.walkingSpeed);
    age = i;
    sex = median(Sort.sex);
    BMI = median(Sort.BMI);
    X = [walkingSpeed age sex BMI];
    Test(j).DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test(j).DP,0);
    j = j+1;
end
h2 = subplot(1,4,2);
set(h2,'Position',[0.33,0.35,0.1575,0.6]);
title('Age (years)');
xlabel('Gait cycle (%)');
set(get(h2,'title'),'Position',[52 -43 0],'FontWeight','Normal');
set(get(h2,'xlabel'),'Position',[52 -25 0]);
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(median(kin,2),'Linestyle','--','Color','black');
hold on;
x = [1:1:101 101:-1:1]';
pMax = max(kin,[],2);
pMin = min(kin,[],2);
y = [pMax;pMin(end:-1:1)];
A = fill(x,y,'black','LineStyle','none','Facealpha',0.3);
for i = 1:size(kin,2)
    for j = 1:size(Test(1,1).DP,1) % number of key points
        plot(Test(1,i).DP(j,1),Test(1,i).DP(j,2),'Marker','.','color',D(i,:),'Markersize',15);
    end
end
% Amplitude of key point angular value
disp('Age')
for i = 1:size(Test(1,1).DP,1)
    temp = [];
    for j = 1:size(kin,2)
        temp = [temp Test(1,j).DP(i,2)]; 
    end
    max(temp)-min(temp)
end
xlim([0 101]);
ylim([-20 20]);
colorbar('Location','southoutside','Position',[0.33,0.15,0.1575,0.02],'TickLabels',{'19','43','67'},'TickDirection','in');
colormap(h2,'jet');

% Sex
clear kin Test X
j = 1;
for i = [0 1]
    walkingSpeed = median(Sort.walkingSpeed);
    age = median(Sort.age);
    sex = i;
    BMI = median(Sort.BMI);
    X = [walkingSpeed age sex BMI];
    Test(j).DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test(j).DP,0);
    j = j+1;
end
h3 = subplot(1,4,3);
set(h3,'Position',[0.53,0.35,0.1575,0.6]);
title('Sex');
xlabel('Gait cycle (%)');
set(get(h3,'title'),'Position',[52 -43 0],'FontWeight','Normal');
set(get(h3,'xlabel'),'Position',[52 -25 0]);
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(median(kin,2),'Linestyle','--','Color','black');
hold on;
x = [1:1:101 101:-1:1]';
pMax = max(kin,[],2);
pMin = min(kin,[],2);
y = [pMax;pMin(end:-1:1)];
A = fill(x,y,'black','LineStyle','none','Facealpha',0.3);
for i = 1:size(kin,2)
    for j = 1:size(Test(1,1).DP,1) % number of key points
        plot(Test(1,i).DP(j,1),Test(1,i).DP(j,2),'Marker','.','color',D(i,:),'Markersize',15);
    end
end
% Amplitude of key point angular value
disp('Sex')
for i = 1:size(Test(1,1).DP,1)
    temp = [];
    for j = 1:size(kin,2)
        temp = [temp Test(1,j).DP(i,2)]; 
    end
    max(temp)-min(temp)
end
xlim([0 101]);
ylim([-20 20]);
colorbar('Location','southoutside','Position',[0.53,0.15,0.1575,0.02],'Limits',[0 1],'Ticks',[0 1],'TickLabels',{'Woman','Man'},'TickDirection','in');
colormap(h3,[0 0 1; 0 1 1]);

% BMI
clear kin Test X
j = 1;
for i = 17:1:31 
    walkingSpeed = median(Sort.walkingSpeed);
    age = median(Sort.age);
    sex = median(Sort.sex);
    BMI = i;
    X = [walkingSpeed age sex BMI];
    Test(j).DP = applyRegression(X,Predictors);
    kin(:,j) = quinticSpline(Test(j).DP,0);
    j = j+1;
end
h4 = subplot(1,4,4);
set(h4,'Position',[0.73,0.35,0.1575,0.6]);
title('BMI (kg.m-2)');
xlabel('Gait cycle (%)');
set(get(h4,'title'),'Position',[52 -43 0],'FontWeight','Normal');
set(get(h4,'xlabel'),'Position',[52 -25 0]);
D = colormap(jet(size(kin,2)));
set(gca, 'ColorOrder',  D, 'NextPlot', 'replacechildren');
plot(median(kin,2),'Linestyle','--','Color','black');
hold on;
x = [1:1:101 101:-1:1]';
pMax = max(kin,[],2);
pMin = min(kin,[],2);
y = [pMax;pMin(end:-1:1)];
A = fill(x,y,'black','LineStyle','none','Facealpha',0.3);
for i = 1:size(kin,2)
    for j = 1:size(Test(1,1).DP,1) % number of key points
        plot(Test(1,i).DP(j,1),Test(1,i).DP(j,2),'Marker','.','color',D(i,:),'Markersize',15);
    end
end
% Amplitude of key point angular value
disp('BMI')
for i = 1:size(Test(1,1).DP,1)
    temp = [];
    for j = 1:size(kin,2)
        temp = [temp Test(1,j).DP(i,2)]; 
    end
    max(temp)-min(temp)
end
xlim([0 101]);
ylim([-20 20]);
colorbar('Location','southoutside','Position',[0.73,0.15,0.1575,0.02],'TickLabels',{'17','24','31'},'TickDirection','in');
colormap(h4,'jet');