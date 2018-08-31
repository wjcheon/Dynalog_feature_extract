clc
clear
close all
%%
%% Load RTPlan for VMAT
[FileName,PathName,FilterIndex] = uigetfile('*.dcm');
%
RTplan_temp = dicominfo(fullfile(PathName, FileName));
%%
first_flag = true;
CP_size =  numel(fieldnames(RTplan_temp.BeamSequence.Item_1.ControlPointSequence));
MLC_position_set = zeros(120, CP_size);
Dose_fraction_set = zeros(1, CP_size);
for iter1 = 1: CP_size
    if (first_flag)
        eval(sprintf('MLC_position_set(1:120, %d) = RTplan_temp.BeamSequence.Item_1.ControlPointSequence.Item_%d.BeamLimitingDevicePositionSequence.Item_3.LeafJawPositions;', iter1, iter1))
        eval(sprintf('Dose_fraction_set(1, %d) = RTplan_temp.BeamSequence.Item_1.ControlPointSequence.Item_%d.CumulativeMetersetWeight;', iter1, iter1))
        %
        first_flag = false;
    else
        eval(sprintf('MLC_position_set(1:120, %d) = RTplan_temp.BeamSequence.Item_1.ControlPointSequence.Item_%d.BeamLimitingDevicePositionSequence.Item_1.LeafJawPositions;', iter1, iter1))
        eval(sprintf('Dose_fraction_set(1, %d) = RTplan_temp.BeamSequence.Item_1.ControlPointSequence.Item_%d.CumulativeMetersetWeight;', iter1, iter1))
        %
    end
end

bankA_pos = MLC_position_set(1:60, :);
bankB_pos = MLC_position_set(61:end, :);
bankA_pos = transpose(bankA_pos);
bankB_pos = transpose(bankB_pos);
%
Dose_fraction_set_diff = diff(Dose_fraction_set);
%%
numLeaves = size(bankA_pos, 1);
numFraction = size(bankA_pos, 2);

% if size(bankA_pos,1) - size(bankB_pos,1) ~= 0
%     disp('pass')
%     continue
% end
% 
% if size(bankA_pos,2) - size(bankB_pos,2) ~= 0
%     disp('pass')
%     continue
% end

number_of_control_point = size(bankA_pos, 2);
MCSv = 0;
for iter1 = 1: (number_of_control_point- 1)
    cp_index = iter1;
    %
    AAV_component = (cal_AAV_cp( cp_index, bankA_pos, bankB_pos) + ...
        cal_AAV_cp( cp_index+1, bankA_pos, bankB_pos))/2;
    
    %
    LSV_component = (cal_LSV_cp( cp_index, bankA_pos, bankB_pos) + ...
        cal_LSV_cp( cp_index+1, bankA_pos, bankB_pos))/2;
    %
    MU_component = Dose_fraction_set_diff(iter1);
    MCSv = MCSv + (AAV_component * LSV_component * MU_component);
end

    
