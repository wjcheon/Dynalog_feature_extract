% Author: Wonjoong Cheon 
% Version: 2.0
% Date: 2017.07.01
clc
clear
close all
%% Load RTPlan
[RTPlanInformation, RTplanFileName, RTplanPathName] = readRTPlan();
%
MLCPosition_RTPlan_Item1_bankA = RTPlanInformation.Item_1.MLCPosition_bankA;
MLCPosition_RTPlan_Item1_bankB = RTPlanInformation.Item_1.MLCPosition_bankB;
CumulativeMetersetWeight_RTplan = RTPlanInformation.Item_1.CumulativeMetersetWeight;
DoseRate = RTPlanInformation.Item_1.doseRate;
gantryRotation = RTPlanInformation.Item_1.gantryRotation;
diff_gantryRotation = diff(gantryRotation);
%

fDrawMLC_gui(MLCPosition_RTPlan_Item1_bankA, MLCPosition_RTPlan_Item1_bankB, RTplanFileName);
%% Load Dynalog
addpath('LB_Dynalog')
dynConstants
[BankAFileName,BankAPathName,BankAFilterIndex] = uigetfile('a*.dlg','Select Dynalog file (A Bank)');
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
%
fDrawMLC_gui_sub(bankA_pos, bankB_pos,BankAFileName);
%% Plot the first mlc position of bank A
figure, subplot(1,3,1), plot(MLCPosition_RTPlan_Item1_bankA(1,:)), ylim([0 70]), xlim([0 60]), title('RTplan pos'), grid on
subplot(1,3,2), plot(bankA.actualPosition(1,:)), ylim([0 70]), xlim([0 60]), title('Actual pos'), grid on
% subplot(1,3,2), plot(bankA.planPosition(1,:)), ylim([0 70]), xlim([0 60]), title('Expected pos')
bankADifference= MLCPosition_RTPlan_Item1_bankA(1,:)- bankA.planPosition(1,:);
max_bankADifference = max(abs(bankADifference));
subplot(1,3,3), plot(bankADifference), xlim([0 60]), ylim([-(max_bankADifference*1.2) max_bankADifference*1.2]), grid on, title('Difference pos')

%% Dynalog file mapping 
scaledRatio = bankA.doseFraction(end);
CumulativeMetersetWeight_RTplan_scaled= round(CumulativeMetersetWeight_RTplan.*numFraction);
CumulativeMetersetWeight_RTplan_scaled(1) = CumulativeMetersetWeight_RTplan_scaled(1) +1;

% CumulativeMetersetWeight_RTplan_scaled_int = (CumulativeMetersetWeight_RTplan_scaled)
%% Dynalog file mapping 
MLCPosition_DynalogFileMapping = zeros(numFraction,numLeaves);
for iter11 = 1: size(CumulativeMetersetWeight_RTplan_scaled,1)
    MLCPosition_DynalogFileMapping(CumulativeMetersetWeight_RTplan_scaled(iter11),:) = MLCPosition_RTPlan_Item1_bankA(iter11,:);
end
%%
close all
p = randperm(size(CumulativeMetersetWeight_RTplan_scaled,1),1);
figure,subplot(1,7,1), plot(bankA.planPosition(CumulativeMetersetWeight_RTplan_scaled(p(1)),:)), title('Dynalog')
subplot(1,7,2), plot(MLCPosition_DynalogFileMapping(CumulativeMetersetWeight_RTplan_scaled(p(1)-2),:)), title('before 2')
subplot(1,7,3), plot(MLCPosition_DynalogFileMapping(CumulativeMetersetWeight_RTplan_scaled(p(1)-1),:)), title('before 1')
subplot(1,7,4), plot(MLCPosition_DynalogFileMapping(CumulativeMetersetWeight_RTplan_scaled(p(1)),:)), title('Same position')
subplot(1,7,5), plot(MLCPosition_DynalogFileMapping(CumulativeMetersetWeight_RTplan_scaled(p(1)+1),:)), title('after 2')
subplot(1,7,6), plot(MLCPosition_DynalogFileMapping(CumulativeMetersetWeight_RTplan_scaled(p(1)+2),:)), title('after 2')
subplot(1,7,7), plot((round(bankA.planPosition(CumulativeMetersetWeight_RTplan_scaled(p(1)),:)*10)/10)-...
    MLCPosition_DynalogFileMapping(CumulativeMetersetWeight_RTplan_scaled(p(1)),:)), title('Discrepancy')

% 
% figure,plot(MLCPositionRTPlan_DynalogFileMapping,'r*'), hold on
% plot((bankA.doseFraction./scaledRatio).*numFraction)

%% Trajectory file mapping 
DynalogBankAPlanPosition = bankA.planPosition;
MLCPosition_TrajectoryFileMapping = zeros(numFraction,numLeaves);
MLCPosition_RTPlan_Item1_bankA = RTPlanInformation.Item_1.MLCPosition_bankA;
for iter2 = 1: size(MLCPosition_RTPlan_Item1_bankA,1)
    line_MLCPosition_RTPlan_Item1_bankA = MLCPosition_RTPlan_Item1_bankA(iter2,:);
    ErrorMatrix = zeros(size(DynalogBankAPlanPosition,1),1);
    for iter1 = 1: size(DynalogBankAPlanPosition,1)
        Diferences = (DynalogBankAPlanPosition(iter1,:) - line_MLCPosition_RTPlan_Item1_bankA);
        ErrorMatrix(iter1) = mean(Diferences.^2);
    end
    [M,I] = min(ErrorMatrix);
    MLCPosition_TrajectoryFileMapping(I,:) = line_MLCPosition_RTPlan_Item1_bankA;
    I_total(iter2) = I; 
    clear I M    
end

%%
% close all
p = randperm(size(I_total,2),1);
figure(210),subplot(1,7,1), plot(bankA.planPosition(I_total(p(1)),:)), title('Dynalog')
subplot(1,7,2), plot(MLCPosition_TrajectoryFileMapping(I_total(p(1)-2),:)), title('before 2')
subplot(1,7,3), plot(MLCPosition_TrajectoryFileMapping(I_total(p(1)-1),:)), title('before 1')
subplot(1,7,4), plot(MLCPosition_TrajectoryFileMapping(I_total(p(1)),:)), title('Same position')
subplot(1,7,5), plot(MLCPosition_TrajectoryFileMapping(I_total(p(1)+1),:)), title('after 1')
subplot(1,7,6), plot(MLCPosition_TrajectoryFileMapping(I_total(p(1)+2),:)), title('after 2')
% subplot(1,7,7), plot(bankA.planPosition(I_total(p(1)),:)-MLCPosition_TrajectoryFileMapping(I_total(p(1)),:)), title('Discrepancy'), ylim([-1 1])
subplot(1,7,7), plot(round(bankA.planPosition(I_total(p(1)),:)*10)/10-...
    MLCPosition_TrajectoryFileMapping(I_total(p(1)),:)), title('Discrepancy'), ylim([-1 1])

%% Comparison Dynalog file mapping and Trajectory file mapping 
figure(100), plot(I_total), hold on
plot(CumulativeMetersetWeight_RTplan_scaled, 'r*'), grid on, 
legend('Trajectory file mapping','Dynalog file mapping'), xlabel('Number of MLC segment in RTplan')
ylabel('Number of MLC segment in Dynalog')
%
%% Interpolation: Dynalog file mapping 
% sample line example
interpolation_method = {'linear';'nearest'; 'next';'previous' ;'spline' ;'pchip' ;'cubic'};
interpolation_method_user_selected = interpolation_method{6};
LINE_NUMBER = 30;
line_MLCPosition_DynalogFileMapping = transpose(MLCPosition_DynalogFileMapping(:,LINE_NUMBER));
line_MLCPosition_DynalogFileMapping(line_MLCPosition_DynalogFileMapping==0) = NaN;
[sx_ori, sy_ori] = size(line_MLCPosition_DynalogFileMapping);
[rr_non, cc_non] = find(isnan(line_MLCPosition_DynalogFileMapping));
[rr_not_non, cc_not_non] = find(~isnan(line_MLCPosition_DynalogFileMapping));
cc_set = sort([cc_non, cc_not_non]);
val_not_non = line_MLCPosition_DynalogFileMapping(cc_not_non);

vq_line = interp1(cc_not_non,val_not_non ,cc_set,interpolation_method_user_selected);
figure, plot(cc_not_non,val_not_non,'o',cc_set,vq_line,':.'), hold on
plot(bankA.planPosition(:,LINE_NUMBER)), title('Method: Dynalog file mapping'), grid on
hold off

%% Interpolation: Trajectory file mapping 
interpolation_method = {'linear';'nearest'; 'next';'previous' ;'spline' ;'pchip' ;'cubic'};
interpolation_method_user_selected = interpolation_method{6};
LINE_NUMBER = 30;
line_MLCPosition_TrajectoryFileMapping = transpose(MLCPosition_TrajectoryFileMapping(:,LINE_NUMBER));
line_MLCPosition_TrajectoryFileMapping(line_MLCPosition_TrajectoryFileMapping==0) = NaN;
[sx_ori, sy_ori] = size(line_MLCPosition_TrajectoryFileMapping);
[rr_non, cc_non] = find(isnan(line_MLCPosition_TrajectoryFileMapping));
[rr_not_non, cc_not_non] = find(~isnan(line_MLCPosition_TrajectoryFileMapping));
cc_set = sort([cc_non, cc_not_non]);
val_not_non = line_MLCPosition_TrajectoryFileMapping(cc_not_non);

vq_line = interp1(cc_not_non,val_not_non ,cc_set,interpolation_method_user_selected);
figure, plot(cc_not_non,val_not_non,'o',cc_set,vq_line,':.'), hold on, grid on
plot(bankA.planPosition(:,LINE_NUMBER)), title('Method: Trajectory file mapping')
hold off

%% 
diff_idotal = diff(I_total);
diff_CumulativeMetersetWeight_RTplan_scaled = diff(CumulativeMetersetWeight_RTplan_scaled);
figure, subplot(1,3,1), plot(diff_idotal), subplot(1,3,2), plot(diff_CumulativeMetersetWeight_RTplan_scaled)
diffdiff = diff_CumulativeMetersetWeight_RTplan_scaled-transpose(diff_idotal);
subplot(1,3,3), plot(diffdiff)

%%
figure, plot(bankA.doseFraction), title('Dose fraction of bank A'), grid on 

%% COST
% CumulativeMetersetWeight_RTplan_scaled_round = round(CumulativeMetersetWeight_RTplan_scaled);
% CumulativeMetersetWeight_RTplan_scaled_round(1) = CumulativeMetersetWeight_RTplan_scaled_round(1) + 1;
% for iter3 = 1: size(CumulativeMetersetWeight_RTplan_scaled_round,1)
%     MLCPositionExtractedFromDynalog(iter3,:) = bankA.planPosition(CumulativeMetersetWeight_RTplan_scaled_round(iter3),:);
% end
% MLCPositionExtractedFromDynalog_Unscaled = MLCPositionExtractedFromDynalog
% MLCPositionExtractedFromRTPlan = MLCPosition_RTPlan_Item1_bankA;
% 
% %% 
% close all
% points = 1.65:0.000001:2.0;
% cost_value = zeros(1,size(points,2));
% for iter4 = 1: size(points,2)
%     cost_value(iter4) = sum(sum(((MLCPositionExtractedFromDynalog_Unscaled(1,:).*(points(iter4)))-MLCPositionExtractedFromRTPlan(1,:)).^2));
% end
% [min_value, min_index] = min(cost_value);
% figure, plot(points,cost_value), grid on, title('Cost function of leaf scale factor'), xlim([points(1), points(end)]), hold on,
% plot(points(min_index), min_value, 'r*')
% 
% %%
% NewlyScaledPosition = MLCPositionExtractedFromDynalog_Unscaled.*points(min_index);

%%
% figure(100), hold on
% for ii = 1: 1584
%     subplot(1,2,1), plot(bankA.planPosition)
% end
%%
close all
figure(100), plot(I_total), hold on
plot(CumulativeMetersetWeight_RTplan_scaled, 'r*'), grid on, 
legend('Trajectory file mapping','Dynalog file mapping'), xlabel('Number of MLC segment in RTplan')
ylabel('Number of MLC segment in Dynalog')
%%
close all
RTPlanDataSet_detail = xlsread('RTplan_detail.xlsx');
GantryRtn_ = RTPlanDataSet_detail(1:179,1);
GantryRtn_diff = diff(GantryRtn_);
GantryRtn_diff(:) = 2;
GantryRtn_diff(end+1) = 2;
DoseRate_ = RTPlanDataSet_detail(1:179,2)./60;    % MU/second 
GantrySpeed = RTPlanDataSet_detail(1:179,3);
Second_per_2degree = GantryRtn_diff./GantrySpeed;  % second
counter1 = 0;
for iter100 = 0.0:0.001:5.0
%     Second_per_2degree(1) = 0.416666666666667;     % 79.3841 second 
    Second_per_2degree(1) = iter100;
    Count_Second_per_2degree = Second_per_2degree./0.05;
    total_treatment_time_cal = sum(Count_Second_per_2degree);
    Count_Second_per_2degree_sum = Count_Second_per_2degree.*0;    % number of log
for iter23 = 1: size(Count_Second_per_2degree,1)
    Count_Second_per_2degree_sum(iter23) = sum(round(Count_Second_per_2degree(1:iter23)));
end
    counter1 = counter1+1;
%     buffer_wj =Count_Second_per_2degree_sum./max(Count_Second_per_2degree_sum).*1584;
    buffer_wj =Count_Second_per_2degree_sum./max(Count_Second_per_2degree_sum).*total_treatment_time_cal;
    costs(counter1) = mean((transpose(buffer_wj)-I_total).^2);
    parameters(counter1) = iter100;
    total_treatment_time_cal_iter(counter1) = total_treatment_time_cal;
end
[cost_val cost_index] = min(costs);
OptimizedParameters = parameters(cost_index);
OptimizedTotal_treatment_time_cal = total_treatment_time_cal_iter(cost_index);
figure, plot(0.0:0.001:5.0, costs), grid on, xlabel('Parameters'), ylabel('Cost (RMSE)'),
hold on, plot(OptimizedParameters, cost_val, 'r*')
title(sprintf('Optimzed parameters: %1.4f',OptimizedParameters))
clear Count_Second_per_2degree_sum
%
%
GantryRtn_ = RTPlanDataSet_detail(1:179,1);
GantryRtn_diff = diff(GantryRtn_);
GantryRtn_diff(:) = 2;
GantryRtn_diff(end+1) = 2;
DoseRate_ = RTPlanDataSet_detail(1:179,2)./60;    % MU/second 
GantrySpeed = RTPlanDataSet_detail(1:179,3);
Second_per_2degree = GantryRtn_diff./GantrySpeed;  % second
% Second_per_2degree(1) = 0.416666666666667;     % 79.3841 second 
Second_per_2degree(1) = OptimizedParameters;                % update

Count_Second_per_2degree = Second_per_2degree./0.05;
Count_Second_per_2degree_sum = Count_Second_per_2degree.*0;    % number of log
for iter23 = 1: size(Count_Second_per_2degree,1)
    Count_Second_per_2degree_sum(iter23) = sum(round(Count_Second_per_2degree(1:iter23)));
end
% CalculatedMLCPositionOnTimeDomain = Count_Second_per_2degree_sum./max(Count_Second_per_2degree_sum).*1584;
CalculatedMLCPositionOnTimeDomain = Count_Second_per_2degree_sum./max(Count_Second_per_2degree_sum).*OptimizedTotal_treatment_time_cal;
%
figure, plot(I_total), hold on,
plot(CalculatedMLCPositionOnTimeDomain)
legend('Correlation method (Trajectory file mapping)','DoseRate and Gantry speed (calculated)'), grid on
%
figure, plot(I_total-transpose(CalculatedMLCPositionOnTimeDomain))
xlabel('Number of segment in RTplan'), ylabel('Discrepancy [count]'), grid on,
title('Correlated method - Calculated method')
%% Cummulative meterset weight 
Count_Second_per_2degree_withMU = Count_Second_per_2degree.*DoseRate_;
Count_Second_per_2degree_withMU_sum = Count_Second_per_2degree_withMU.*0;
for iter22 = 1: size(Count_Second_per_2degree_withMU,1)
    Count_Second_per_2degree_withMU_sum(iter22) = sum(Count_Second_per_2degree_withMU(1:iter22));
end
Calculated_CumulativeMetersetWeight = Count_Second_per_2degree_withMU_sum./max(Count_Second_per_2degree_withMU_sum);

%
figure(101), plot(Calculated_CumulativeMetersetWeight)
hold on, plot(CumulativeMetersetWeight_RTplan)
legend('Calculated', 'RTPlan'), grid on
xlabel('Number of segment'), ylabel('Cumulative Meterset Weight (norm)')

%%

%%

































































