% =========================================================================
% =========================================================================
% FIT NORMAL GAIT: Predict kinematics based on walking speed, age, sex, BMI
% =========================================================================
% Function: prepareData
% =========================================================================
% Authors: F. Moissenet
% Creation: 06 July 2017
% Version: v1.0
% =========================================================================
% =========================================================================

function Sort = prepareData(Raw,minVf,maxVf)

% =========================================================================
% Initialisation
% =========================================================================
Sort.kinematics = [];
Sort.walkingSpeed = [];
Sort.stepLength = [];
Sort.cadence = [];
Sort.IFS1 = [];
Sort.IFS2 = [];
Sort.IFO = [];
Sort.CFS = [];
Sort.CFO = [];
Sort.age = [];
Sort.sex = [];
Sort.BMI = [];
Sort.LL = [];

% =========================================================================
% Prepare data for treatment
% =========================================================================

% Sort raw data by ascending walking speed
% -------------------------------------------------------------------------
[S,I] = sort(Raw.walkingSpeed);
skinematics = Raw.kinematics(:,I);
sstepLength = Raw.stepLength(:,I);
scadence = Raw.cadence(:,I);
swalkingSpeed = S;
sIFS1 = Raw.IFS1(:,I);
sIFS2 = Raw.IFS2(:,I);
sIFO = Raw.IFO(:,I);
sCFS = Raw.CFS(:,I);
sCFO = Raw.CFO(:,I);
sage = Raw.age(:,I);
ssex = Raw.sex(:,I);
sBMI = Raw.BMI(:,I);
sLL = Raw.LL(:,I);

% Remove extreme walking speed values
% -------------------------------------------------------------------------
index = find(Raw.walkingSpeed >= minVf & Raw.walkingSpeed < maxVf);
Sort.kinematics = skinematics(:,index);
Sort.walkingSpeed = swalkingSpeed(:,index);
Sort.stepLength = sstepLength(:,index);
Sort.cadence = scadence(:,index);
Sort.IFS1 = sIFS1(:,index);
Sort.IFS2 = sIFS2(:,index);
Sort.IFO = sIFO(:,index);
Sort.CFS = sCFS(:,index);
Sort.CFO = sCFO(:,index);
Sort.age = sage(:,index);
Sort.sex = ssex(:,index);
Sort.BMI = sBMI(:,index);
Sort.LL = sLL(:,index);