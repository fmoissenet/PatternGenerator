% =========================================================================
% =========================================================================
% FIT NORMAL GAIT: Predict kinematics based on walking speed, age, sex, BMI
% =========================================================================
% Function: extractData
% =========================================================================
% Authors: F. Moissenet
% Creation: 06 July 2017
% Version: v1.0
% =========================================================================
% =========================================================================

function Raw = extractData(File,Joint,icycle,isubject,subject_sub,rsubject,N,V,T,J,type)

% =========================================================================
% Initialisation
% =========================================================================
Raw.kinematics = [];
Raw.walkingSpeed = [];
Raw.stepLength = [];
Raw.cadence = [];
Raw.IFS1 = [];
Raw.IFS2 = [];
Raw.IFO = [];
Raw.CFS = [];
Raw.CFO = [];
Raw.age = [];
Raw.sex = [];
Raw.BMI = [];
Raw.LL = [];

% =========================================================================
% Merge data related to each walking speed condition
% =========================================================================
walkingSpeed_froude = [];
for v = 1:V
    
    % Store parameters
    % ---------------------------------------------------------------------
    if strcmp(type,'training')
        temp = reshape(icycle(subject_sub,:,v)',1,...
            size(icycle(subject_sub,:,v),1)*size(icycle(subject_sub,:,v),2));
        temp2 = [temp(~isnan(temp)) nan(1,600-length(temp(~isnan(temp))))];
        temp2 = temp2(~isnan(temp2));
    elseif strcmp(type,'testing')
        temp = reshape(icycle(rsubject,:,v)',1,size(icycle(rsubject,:,v),1)*size(icycle(rsubject,:,v),2));
        temp2 = [temp(~isnan(temp)) nan(1,600-length(temp(~isnan(temp))))];
        temp2 = temp2(~isnan(temp2));
    end
    Raw.kinematics = [Raw.kinematics ...
        File(v).Normatives.Kinematics.(Joint(J).code).data(:,temp2)*(Joint(J).sign)];
    Raw.walkingSpeed = [Raw.walkingSpeed ...
        File(v).Normatives.Gaitparameters.mean_velocity.data(:,temp2)];
    Raw.stepLength = [Raw.stepLength ...
        File(v).Normatives.Gaitparameters.step_length.data(:,temp2)];
    Raw.cadence = [Raw.cadence ...
        File(v).Normatives.Gaitparameters.cadence.data(:,temp2)];
    Raw.IFS1 = [Raw.IFS1 repmat(1,[1 size(Raw.walkingSpeed,2)])];
    Raw.IFS2 = [Raw.IFS2 repmat(T,[1 size(Raw.walkingSpeed,2)])];
    Raw.IFO = [Raw.IFO File(v).Normatives.Phases.p5.data(:,temp2)];
    Raw.CFS = [Raw.CFS File(v).Normatives.Phases.p4.data(:,temp2)];
    Raw.CFO = [Raw.CFO File(v).Normatives.Phases.p2.data(:,temp2)];
    clear temp temp2;
    
    % Store predictors
    % ---------------------------------------------------------------------
    temp = [];
    if strcmp(type,'training')
        for i = 1:size(isubject(:,v),1)
            if isubject(i,v) ~= rsubject && ...
                    ~isnan(isubject(i,v)) && ...
                    isubject(i,v) <= N
                temp = [temp isubject(i,v)];
            end
        end
    elseif strcmp(type,'testing')
        for i = 1:size(isubject(:,v),1)
            if isubject(i,v) == rsubject && ...
                    ~isnan(isubject(i,v)) && ...
                    isubject(i,v) <= N
                temp = [temp isubject(i,v)];
            end
        end
    end
    for i = 1:length(temp)
        temp1(1,i) = sqrt(File(v).Population.L0.data(temp(i))*9.81); % Froude velocity
        temp2(1,i) = File(v).Population.age.data(temp(i));
        temp3(1,i) = File(v).Population.gender.data(temp(i));
        temp4(1,i) = File(v).Population.height.data(temp(i));
        temp5(1,i) = File(v).Population.weight.data(temp(i));
        temp6(1,i) = File(v).Population.L0.data(temp(i));
    end
    walkingSpeed_froude = [walkingSpeed_froude temp1];
    Raw.age = [Raw.age temp2];
    Raw.sex = [Raw.sex temp3];
    Raw.BMI = [Raw.BMI temp5./temp4.^2];
    Raw.LL = [Raw.LL temp6];
    clear temp1 temp2 temp3 temp4 temp5 temp6 temp;
    
end

% =========================================================================
% Express walking speed as a fraction of the Froude velocity
% =========================================================================
Raw.walkingSpeed = Raw.walkingSpeed./walkingSpeed_froude;
Raw.stepLength = Raw.stepLength./Raw.LL;
Raw.cadence = Raw.cadence./sqrt(9.81./Raw.LL);