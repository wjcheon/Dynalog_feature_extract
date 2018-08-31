%%
% Date: 2017.10.30
% Author: Wonjoong Cheon

clc
clear
close all
%%
Debug_flag = 1;
%% Load Dynalog
addpath('LB_Dynalog')
dynConstants
[BankAFileName,BankAPathName,BankAFilterIndex] = uigetfile('a*.dlg','Select Dynalog file (A Bank)');
dynalog_lists = dir(fullfile(BankAPathName,'*.dlg'))
%%
PositionError_cell = {}
PositionError_mean_cell ={}
PositionError_set = []
for iter_list = 1: size(dynalog_lists ,1)
    if Debug_flag == 1
        fprintf('iterlist : %d\n',iter_list)
    end
    
    Target_BankAFileName = dynalog_lists(iter_list).name;
    bankA = dynRead(fullfile(BankAPathName,Target_BankAFileName));
    Target_BankAFileName (1) = [];
    bankBName = strcat('B', Target_BankAFileName );
    bankB = dynRead(fullfile(BankAPathName,bankBName));
    %
    numLeaves = bankA.numLeaves;
    numFraction = bankA.numFractions;
    %
    bankA_pos = bankA.planPosition;
    bankB_pos = bankB.planPosition;
    % viewer
    % fDrawMLC_gui_sub(bankA_pos, bankB_pos,BankAFileName);
    
    % Cal Positioning error
    GantryRotation_info = bankA.gantryRotation;
    GantryRotation_info_theat = GantryRotation_info.*pi./(180);
    if Debug_flag == 1
        fprintf('size : %d\n',size(GantryRotation_info_theat,1))
    end
    % Select Expected position and Actual Position
    ExpectedPosition = bankA.planPosition;
    ExpectedPosition = ExpectedPosition(:,1:60);
    ActualalPosition = bankA.actualPosition;
    ActualalPosition = ActualalPosition(:,1:60);
    % ActualPosition_hat
    PositionError = ActualalPosition - ExpectedPosition;
    PositionError_mean = mean(PositionError,2);
    PositionError_cell{iter_list} = PositionError;
    PositionError_mean_cell{iter_list} = PositionError_mean;
    PositionError_set = [PositionError_set ; PositionError];
    clear PositionError PositionError_mean
    
end
%%
PositionError_set_backup  = PositionError_set;
PositionError_set_backup(PositionError_set_backup<-5) = [];
PositionError_set_backup(PositionError_set_backup>5) = [];
figure, histogram(PositionError_set_backup,50,'Normalization','probability')
title('Position error of all dynalogs'), grid on,
xlabel('Position error at isocenter [mm]')
ylabel('Count')
% at single
% figure, polar(GantryRotation_info_theat, mean(PositionError_set)
% view([90 270])
% title(sprintf('Position error of MLC\n: %s\n', strrep(BankAFileName,'_',' ')))
%% Calculate,  Velocity error: total MLC (Original)
VelocityError_cell = {}
VelocityError_mean_cell ={}
VelocityError_set = []
iter_list=[]
for iter_list = 1: size(dynalog_lists ,1)
    if Debug_flag == 1
        fprintf('iter_list : %d\n',iter_list)
    end
    delta_t = 0.05;
    ExpectedPosition_Velocity = diff(ExpectedPosition)./delta_t ;
    ExpectedPosition_Velocity_mean = mean(ExpectedPosition_Velocity,2);
    % figure, plot(ExpectedPosition_Velocity)
    %
    % Actual position
    ActualalPosition_Velocity = diff(ActualalPosition)./delta_t;
    VelocityError = ActualalPosition_Velocity - ExpectedPosition_Velocity;
    VelocityError_mean = mean(VelocityError,2);
    %
    VelocityError_cell{iter_list} = VelocityError;
    VelocityError_mean_cell{iter_list} = VelocityError_mean;
    VelocityError_set = [VelocityError_set ; VelocityError];
end
%
%
VelocityError_set_backup  = VelocityError_set;
VelocityError_set(VelocityError_set<-40) = [];
VelocityError_set(VelocityError_set>40) = [];
figure, histogram(VelocityError_set,30)
title('Velocity error of all dynalogs'), grid on,
xlabel('Velocity error at isocenter [mm/s]')
ylabel('Count')

% at single
% figure, polar(GantryRotation_info_theat(2:end), VelocityError_mean)
% title(sprintf('Velocity error of MLC\n: %s\n', strrep(BankAFileName,'_',' ')))
% view([90 270])
%% figure, common velocity calculation 
number_of_target_mlc = 30;
delta_t = 0.05;
ExpectedPosition_Velocity_single_mlc = diff(ExpectedPosition(:,number_of_target_mlc))./delta_t ;
ExpectedPosition_Velocity_single_mlc_mean = mean(ExpectedPosition_Velocity_single_mlc ,2);
% figure, plot(ExpectedPosition_Velocity)
%
% Actual position
ActualalPosition_Velocity_single_mlc = diff(ActualalPosition(:,number_of_target_mlc))./delta_t;
VelocityError_single = ActualalPosition_Velocity_single_mlc - ExpectedPosition_Velocity_single_mlc;
VelocityError_mean_single = mean(VelocityError_single,2);

figure, polar(GantryRotation_info_theat(2:end), VelocityError_mean_single )
title(sprintf('Velocity error of MLC\n : %s\nLeaf number: %d\n', strrep(BankAFileName,'_',' '), number_of_target_mlc))
view([90 270])
figure(10), subplot(2,1,1), plot(ExpectedPosition_Velocity(:,30)), title('Velocity (simple)')
xlabel('number of dynalog'), ylabel('~'), grid on
%
%% Calculate, CalVelocity error (Talor)
TalorVelocityError_cell = {}
TalorVelocityError_mean_cell ={}
TalorVelocityError_set = []
iter_list=[]
for iter_list = 1: size(dynalog_lists ,1)
    if Debug_flag == 1
        fprintf('iter_list : %d\n',iter_list)
    end
    % -AP(t+2, n)+ 8 *(AP+1,n) -8*AP(t-a,n) + AP(t-2,n) ./ (delta_t * 12)
    t= 3:size(ExpectedPosition,1)-2;
    ExpectedPosition_Velocity_Taylor = (-ExpectedPosition(t+2,:)+ (8 *ExpectedPosition(t+1,:)) + (-8*ExpectedPosition(t-1,:)) + (ExpectedPosition(t-2,:)))./ (delta_t * 12);
    ActualalPosition_Velocity_Taylor = (-ActualalPosition(t+2,:)+ (8 *ActualalPosition(t+1,:)) + (-8*ActualalPosition(t-1,:)) + (ActualalPosition(t-2,:)))./ (delta_t * 12);
    VelocityError_Taylor = ActualalPosition_Velocity_Taylor - ExpectedPosition_Velocity_Taylor ;
    VelocityError_Taylor_mean = mean(VelocityError_Taylor,2);
    %
    TalorVelocityError_cell{iter_list} = VelocityError_Taylor;
    TalorVelocityError_mean_cell{iter_list} = VelocityError_Taylor_mean;
    TalorVelocityError_set = [TalorVelocityError_set ; VelocityError_Taylor];
end
%
%
TalorVelocityError_set_backup  = TalorVelocityError_set;
TalorVelocityError_set(TalorVelocityError_set<-40) = [];
TalorVelocityError_set(TalorVelocityError_set>40) = [];
figure, histogram(TalorVelocityError_set,30)
title('Velocity error of all dynalogs (Talor method)'), grid on,
xlabel('Velocity error at isocenter [mm/s]')
ylabel('Count')


% at single
% figure, polar(GantryRotation_info_theat(3:end-2), VelocityError_Taylor_mean),
% title(sprintf('Velocity error of MLC (Talyor method)\n: %s\n', strrep(BankAFileName,'_',' ')))
% view([90 270])
% % figure, plot(ExpectedPosition_Velocity(:,30))
%% figure, CalVelocity error (Talor)
% -AP(t+2, n)+ 8 *(AP+1,n) -8*AP(t-a,n) + AP(t-2,n) ./ (delta_t * 12)
number_of_target_mlc = number_of_target_mlc;
t= 3:size(ExpectedPosition,1)-2;
ExpectedPosition_Velocity_Taylor = (-ExpectedPosition(t+2,:)+ (8 *ExpectedPosition(t+1,:)) + (-8*ExpectedPosition(t-1,:)) + (ExpectedPosition(t-2,:)))./ (delta_t * 12);
ActualalPosition_Velocity_Taylor = (-ActualalPosition(t+2,:)+ (8 *ActualalPosition(t+1,:)) + (-8*ActualalPosition(t-1,:)) + (ActualalPosition(t-2,:)))./ (delta_t * 12);
ExpectedPosition_Velocity_Taylor_single = ExpectedPosition_Velocity_Taylor(:,number_of_target_mlc);
ActualalPosition_Velocity_Taylor_single = ActualalPosition_Velocity_Taylor(:,number_of_target_mlc);
%
VelocityError_Taylor_single = ActualalPosition_Velocity_Taylor_single - ExpectedPosition_Velocity_Taylor_single;
figure, polar(GantryRotation_info_theat(3:end-2), VelocityError_Taylor_single),
title(sprintf('Velocity error of MLC (Talyor method) \n : %s\nLeaf number: %d\n', strrep(BankAFileName,'_',' '), number_of_target_mlc))
view([90 270])
%
figure(10), subplot(2,1,2), plot(ExpectedPosition_Velocity_Taylor_single), title('Velocity (Talyor)')
xlabel('number of dynalog'), ylabel('~'), grid on
%% PositionError_clt
number_of_conduct = 2000;
number_of_element = 50;
PositionError_original = PositionError_set_backup(:);
PositionError_clt = clt_wjcheon(PositionError_original , number_of_conduct, number_of_element);
figure, subplot(1,2,1), histogram(PositionError_original,'Normalization','probability'), title('Histogram of position error'), grid on
subplot(1,2,2),histogram(PositionError_clt,'Normalization','probability'), title('Histogram of position error (CLT)');
grid on
PositionError_clt_mean = mean(PositionError_clt);
PositionError_clt_std  = std(PositionError_clt);
%
figure,histogram(PositionError_clt(1:2000).*1000,100)

%% VelocityError_clt
number_of_conduct = 2000;
number_of_element = 50;
VelocityError_single = TalorVelocityError_set(:);
VelocityError_clt = clt_wjcheon(VelocityError_Taylor_single , number_of_conduct, number_of_element);
figure, subplot(1,2,1), histogram(VelocityError_single,'Normalization','probability'), title('Histogram of velocity error'), grid on;
subplot(1,2,2), histogram(VelocityError_clt,'Normalization','probability'), title('Histogram of velocity error (CLT)'), xlim([-3 3]);
grid on
VelocityError_clt_mean = mean(VelocityError_clt);
VelocityError_clt_std = std(VelocityError_clt);

%% Expected Position_clt

%% Actual Position


