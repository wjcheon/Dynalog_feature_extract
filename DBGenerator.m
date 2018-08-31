clc
clear
close all
%% Set parameters
SelectedNumberOfLogs= 60;
PrintPerIterative = 400;

%%
addpath('LB_Dynalog')
MKDIR_FALG = true;
%
dynConstants
[BankAFileName,BankAPathName,BankAFilterIndex] = uigetfile('a*.dlg','Select Dynalog file (A Bank)');
DynalogFileList = dir(fullfile(BankAPathName, 'a*.dlg'));
%
for iter2 = 1: size(DynalogFileList,1)
    SelectedDynalog = DynalogFileList(1).name;
    bankA_info = dynRead(fullfile(BankAPathName,SelectedDynalog));
    for iter1 = 1: size(bankA_info.planPosition,1) - SelectedNumberOfLogs
        theNumberOfCenter = iter1+(SelectedNumberOfLogs/2);
        %     centerMLC_info = bankA_info.planPosition(theNumberOfCenter,:);
        %     belowMLC_info = bankA_info.planPosition(1:theNumberOfCenter-1,:);
        %     aboveMLC_info = bankA_info.planPosition(1+theNumberOfCenter:theNumberOfCenter+SelectedNumberOfLogs/2,:);
        %     MLCSet_info = [belowMLC_info ; centerMLC_info ; aboveMLC_info] ;
        MLCSet_info = bankA_info.planPosition(theNumberOfCenter-SelectedNumberOfLogs/2:theNumberOfCenter+SelectedNumberOfLogs/2,:);
        %
        bankA_info_doseFraction_selected = bankA_info.doseFraction(theNumberOfCenter-SelectedNumberOfLogs/2:theNumberOfCenter+SelectedNumberOfLogs/2,:);
        bankA_info_gantryRotation_selected = bankA_info.gantryRotation(theNumberOfCenter-SelectedNumberOfLogs/2:theNumberOfCenter+SelectedNumberOfLogs/2,:);
        bankA_info_collimatorRotation_selected = bankA_info.collimatorRotation(theNumberOfCenter-SelectedNumberOfLogs/2:theNumberOfCenter+SelectedNumberOfLogs/2,:);
        bankA_info_beamOn_selected =  bankA_info.beamOn(theNumberOfCenter-SelectedNumberOfLogs/2:theNumberOfCenter+SelectedNumberOfLogs/2,:);
        %
        learningData_buffer = [MLCSet_info, bankA_info_doseFraction_selected, bankA_info_gantryRotation_selected...
            bankA_info_collimatorRotation_selected, bankA_info_beamOn_selected];
        train_X = learningData_buffer;
        train_Y = bankA_info.actualPosition(theNumberOfCenter,:);
        filename_trainX = sprintf('Train_%d_Xdata%s.csv',iter2, num2str(iter1,'%04i'));
        filename_trainY = sprintf('Train_%d_Ydata%s.csv',iter2, num2str(iter1,'%04i'));
        %
        directory_train_Xdata = fullfile(BankAPathName,'Train_Xdata');
        directory_train_Ydata = fullfile(BankAPathName,'Train_Ydata');
        if(MKDIR_FALG)
            mkdir(directory_train_Xdata)
            mkdir(directory_train_Ydata)
            MKDIR_FALG = false;
        end
        %
        csvwrite(fullfile(directory_train_Xdata,filename_trainX),train_X)
        csvwrite(fullfile(directory_train_Ydata,filename_trainY),train_Y)
        clear learningData_buffer train_X train_Y
        if mod(iter1,PrintPerIterative) == 0
            fprintf('%d of %d ::: %1.2f percent is done\n',iter2, size(DynalogFileList,1), iter1./(size(bankA_info.planPosition,1) - SelectedNumberOfLogs/2).*100)
        end
    end
    fprintf('%d of %d ::: %1.2f percent is done\n',iter2, size(DynalogFileList,1), 100)
end
%% TEST
[TestFileName,TestPathName,TestFilterIndex] = uigetfile('Train*Xdata*.csv','Select train_X data');
TestFileName_trainX = TestFileName;
k = strfind(TestFileName_trainX, 'X');
TestFileName_trainY = TestFileName;
TestFileName_trainY(k) = 'Y';
TestPathName_trainY = TestPathName;
k2 = strfind(TestPathName_trainY , 'X');
TestPathName_trainY(k2)='Y';
%
trainX_data_loaded = csvread(fullfile(TestPathName,TestFileName_trainX));
trainY_data_loaded = csvread(fullfile(TestPathName_trainY,TestFileName_trainY));

for iter3 = 1: size(trainX_data_loaded,1)
    cost_val(iter3) = mean((trainX_data_loaded(iter3,1:60) - trainY_data_loaded).^2);
end
[min_val, min_index] = min(cost_val);
figure, plot(cost_val), title(sprintf('Test for generating training set, min index: %d',min_index)), grid on




























