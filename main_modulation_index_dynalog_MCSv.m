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
%%
for iter2 = 1 : size(bankA_list, 1)
    % load Dynalog-pair 
    BankAFileName = bankA_list(iter2).name
    bankA = dynRead(fullfile(BankAPathName,BankAFileName));
    BankAFileName(1) = [];
    bankBName = strcat('B', BankAFileName);
    bankB = dynRead(fullfile(BankAPathName,bankBName));
    %
    %
    %
    bankA_pos = bankA.actualPosition;
    bankB_pos = bankB.actualPosition;
    numLeaves = bankA.numLeaves;
    numFraction = bankA.numFractions;
    %
    %
    % remove Error-contained Dynalog.
    if size(bankA_pos,1) - size(bankB_pos,1) ~= 0
        disp('pass')
        continue
    end
    
    if size(bankA_pos,2) - size(bankB_pos,2) ~= 0
        disp('pass')
        continue
    end
    %
    % Feature extraction #1 AAV_max 
    [AAVPlan, AAVActual] = dynAAV(bankA, bankB) ;
    AAVActual_per_fraction = [];
    for iter1 = 1: size(AAVActual,3)
        AAVActual_per_fraction(iter1) = sum(sum(AAVActual(:,:,iter1)));
    end
    AAV_max = max(AAVActual_per_fraction);
    %
    %
    %
    %
    %
    %
    %
    % Calculated MSCv
    number_of_control_point = size(bankA_pos, 1);
    MCSv = 0;
    %
    for iter1 = 1: numFraction-1
        cp_index = iter1;
        %
        LSV_component = (cal_LSV_cp_v3( cp_index, bankA_pos, bankB_pos) + ...
            cal_LSV_cp_v3( cp_index+1, bankA_pos, bankB_pos))/2;
        %
        AAV_component = (cal_AAV_cp_v2( cp_index, AAVActual, AAV_max) + ...
            cal_AAV_cp_v2(cp_index+1, AAVActual, AAV_max))/2;
        %
        MU_component_bw_cp_norm = diff(bankA.doseFraction)./max(bankA.doseFraction);
        MU_component_bw_cp_norm = abs(MU_component_bw_cp_norm);
        MU_component = MU_component_bw_cp_norm(cp_index);
%         MU_component_bw_cp_B = diff(bankB.doseFraction)
        
        MCSv = MCSv + (AAV_component * LSV_component * MU_component);
        
        MCSv_tt(iter1) = (AAV_component * LSV_component * MU_component);
        AAV_component_tt(iter1) = AAV_component;
        LSV_component_tt(iter1) = LSV_component;
        MU_component(iter1) = MU_component;
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
