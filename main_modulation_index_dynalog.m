clc
clear
close all
%
% Load Dynalog
addpath('LB_Dynalog')
dynConstants
[BankAFileName,BankAPathName,BankAFilterIndex] = uigetfile('a*.dlg','Select Dynalog file (A Bank)');
bankA_list = dir(fullfile(BankAPathName, 'a*.dlg'))
MCSv_list = [];
MLC_Error_list = [];
for iter2 = 1 : size(bankA_list, 1)
    BankAFileName = bankA_list(iter2).name
    bankA = dynRead(fullfile(BankAPathName,BankAFileName));
    BankAFileName(1) = [];
    bankBName = strcat('B', BankAFileName);
    bankB = dynRead(fullfile(BankAPathName,bankBName));
    %
    numLeaves = bankA.numLeaves;
    numFraction = bankA.numFractions;
    %
    bankA_pos = bankA.planPosition;
    bankB_pos = bankB.planPosition;
    if size(bankA_pos,1) - size(bankB_pos,1) ~= 0
        disp('pass')
        continue
    end
    
    if size(bankA_pos,2) - size(bankB_pos,2) ~= 0
        disp('pass')
        continue
    end
    %
%     fDrawMLC_gui_sub(bankA_pos, bankB_pos,BankAFileName);
    % TEST
    % cp_index = 550
    % [ LSV_cp ] = cal_LSV_cp( cp_index, bankA_pos, bankB_pos)
    % [ AVV_cp ] = cal_AAV_cp( cp_index, bankA_pos, bankB_pos)
    
    number_of_control_point = size(bankA_pos, 1);
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
        MU_component = bankA.doseFraction(iter1)./sum(bankA.doseFraction);
        MCSv = MCSv + (AAV_component * LSV_component * MU_component);
    end
    MCSv_list(iter2) = MCSv;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MLC_Error_bankA = abs(bankA.actualPosition - bankA.planPosition);
    MLC_Error_bankB = abs(bankB.actualPosition - bankB.planPosition);
    MLC_Error_Sum_Vec = [MLC_Error_bankA ; MLC_Error_bankB];
    MLC_Error_avg = mean(MLC_Error_Sum_Vec(:));
    MLC_Error_list(iter2) = MLC_Error_avg
     
    clear MLC_Error_bankA MLC_Error_bankB MLC_Error_Sum_Vec MLC_Error_avg
end

%
mean_MCSv_list = mean(MCSv_list);
mean_MLC_Error_list = mean(MLC_Error_list);
[mean_MCSv_list, mean_MLC_Error_list]

%%
MCSv_list(MCSv_list==0) = []
figure, histogram(MCSv_list), xlim([0 , 1]), grid on, 
xlabel('Modulation index')
ylabel('Frequency')
title('Analysis Dynalog as modulation index')
