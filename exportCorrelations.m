% =========================================================================
% =========================================================================
% FIT NORMAL GAIT: Predict kinematics based on walking speed, age, sex, BMI
% =========================================================================
% Function: exportCorrelations
% =========================================================================
% Authors: F. Moissenet
% Creation: 06 July 2017
% Version: v1.0
% =========================================================================
% =========================================================================

function exportCorrelations(Joint,Predictors,J,filename)

% =========================================================================
% Build the table of correlations
% =========================================================================
k = 1;
for i = 1:size(Predictors,1)
    for j = 1:size(Predictors,2)
        exportTable{k,:} = {Joint(J).name Joint(J).code Predictors(i,j,1).DP Predictors(i,j,1).variable ...
            [Predictors(i,j,1).value] [Predictors(i,j,1).significance] ...
            [Predictors(i,j,2).value] [Predictors(i,j,2).significance] ...
            [Predictors(i,j,3).value] [Predictors(i,j,3).significance] ...
            [Predictors(i,j,4).value] [Predictors(i,j,4).significance] ...
            [Predictors(i,j,5).value] [Predictors(i,j,5).significance] ...
            [Predictors(i,j,6).value] [Predictors(i,j,6).significance] ...
            [Predictors(i,j,7).value] [Predictors(i,j,7).significance] ...
            [Predictors(i,j,8).value] [Predictors(i,j,8).significance]};
        k = k+1;
    end
end

% =========================================================================
% Write the table in a CSV file
% =========================================================================
fileID = fopen(filename,'w');
C = {'Joint' 'Angle' 'DP' 'Variable'...
    'Constant - coeff' 'Constant - sign' 'Walking speed - coeff' 'Walking speed - sign' 'Step length - coeff'...
    'Step length - sign' 'Cadence - coeff' 'Cadence - sign' 'Walking ratio - coeff' 'Walking ratio - sign' 'Age - coeff' 'Age - sign' 'Sex - coeff'...
    'Sex - sign' 'BMI - coeff' 'BMI - sign'};
fprintf(fileID,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',C{:});
formatSpec = '%s\n';
for i = 1:size(exportTable,1)
    for j = 1:20
        if j < 5
            C = {exportTable{i}{j}};
            fprintf(fileID,'%s,',C{:});
        elseif j >= 5 && j < 20
            C = {exportTable{i}{j}};
            fprintf(fileID,'%0.4f,',C{:});
        else
            C = {exportTable{i}{j}};
            fprintf(fileID,'%0.4f\n',C{:});
        end
    end
end
fclose(fileID);