% Write kinematics into JSON files

cd('C:\Users\florent.moissenet\Documents\Professionnel\routines\github\PatternGenerator\Results');
file = 'data_walking_speed.json';
fid = fopen(file,'w');
fprintf(fid,'%s\n','{');
fprintf(fid,'\t%s \n\n','"Right_Ankle": [');
clear variation;
load('walkingSpeed_variation.mat');
for i = 1:length(variation)
    clear kin;
    load('ankle_walkingSpeed.mat');
    if i ~= length(variation)
        fprintf(fid,'\t\t%s','[');
        for j = 1:100
            fprintf(fid,'%12.10f%s',kin(j,i),',');
        end
        fprintf(fid,'%12.10f',kin(101,i));
        fprintf(fid,'%s\n','],');
        fprintf(fid,'\n');
    else
        fprintf(fid,'\t\t%s','[');
        for j = 1:100
            fprintf(fid,'%12.10f%s',kin(j,i),',');
        end
        fprintf(fid,'%12.10f',kin(101,i));
        fprintf(fid,'%s\n',']');
        fprintf(fid,'\n');
        fprintf(fid,'\t%s\n','],');
    end
end
fprintf(fid,'\n');
fprintf(fid,'\t%s \n\n','"Right_Knee": [');
clear variation;
load('walkingSpeed_variation.mat');
for i = 1:length(variation)
    clear kin;
    load('knee_walkingSpeed.mat');
    if i ~= length(variation)
        fprintf(fid,'\t\t%s','[');
        for j = 1:100
            fprintf(fid,'%12.10f%s',kin(j,i),',');
        end
        fprintf(fid,'%12.10f',kin(101,i));
        fprintf(fid,'%s\n','],');
        fprintf(fid,'\n');
    else
        fprintf(fid,'\t\t%s','[');
        for j = 1:100
            fprintf(fid,'%12.10f%s',kin(j,i),',');
        end
        fprintf(fid,'%12.10f',kin(101,i));
        fprintf(fid,'%s\n',']');
        fprintf(fid,'\n');
        fprintf(fid,'\t%s\n','],');
    end
end
fprintf(fid,'\n');
fprintf(fid,'\t%s \n\n','"Right_Hip": [');
clear variation;
load('walkingSpeed_variation.mat');
for i = 1:length(variation)
    clear kin;
    load('hip_walkingSpeed.mat');
    if i ~= length(variation)
        fprintf(fid,'\t\t%s','[');
        for j = 1:100
            fprintf(fid,'%12.10f%s',kin(j,i),',');
        end
        fprintf(fid,'%12.10f',kin(101,i));
        fprintf(fid,'%s\n','],');
        fprintf(fid,'\n');
    else
        fprintf(fid,'\t\t%s','[');
        for j = 1:100
            fprintf(fid,'%12.10f%s',kin(j,i),',');
        end
        fprintf(fid,'%12.10f',kin(101,i));
        fprintf(fid,'%s\n',']');
        fprintf(fid,'\n');
        fprintf(fid,'\t%s\n','],');
    end
end
fprintf(fid,'\n');
fprintf(fid,'\t%s \n','"Duration": [');
fprintf(fid,'\t%s\n',']');
fprintf(fid,'%s','}');
fclose(fid);
