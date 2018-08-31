%%
% Date: 2017.10.30
% Author: Wonjoong Cheon

clc
clear
close all
%%
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
% viewer 
% fDrawMLC_gui_sub(bankA_pos, bankB_pos,BankAFileName);

%% Cal Positioning error 
GantryRotation_info = bankA.gantryRotation;
GantryRotation_info_theat = GantryRotation_info.*pi./(180);
% Select Expected position and Actual Position 
ExpectedPosition = bankA.planPosition;
ActualalPosition = bankA.actualPosition;
% ActualPosition_hat 
PositionError = ActualalPosition - ExpectedPosition;
PositionError_mean = mean(PositionError,2);
figure, polar(GantryRotation_info_theat, PositionError_mean)
view([90 270])
title(sprintf('Position error of MLC\n: %s\n', strrep(BankAFileName,'_',' ')))
%% Cal Velocity error: total MLC (Original)
delta_t = 0.05;
ExpectedPosition_Velocity = diff(ExpectedPosition)./delta_t ;
ExpectedPosition_Velocity_mean = mean(ExpectedPosition_Velocity,2);
% figure, plot(ExpectedPosition_Velocity)
%
% Actual position
ActualalPosition_Velocity = diff(ActualalPosition)./delta_t;
VelocityError = ActualalPosition_Velocity - ExpectedPosition_Velocity;
VelocityError_mean = mean(VelocityError,2);
figure, polar(GantryRotation_info_theat(2:end), VelocityError_mean)
title(sprintf('Velocity error of MLC\n: %s\n', strrep(BankAFileName,'_',' ')))
view([90 270])
%%
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
%% CalVelocity error (Talor)
% -AP(t+2, n)+ 8 *(AP+1,n) -8*AP(t-a,n) + AP(t-2,n) ./ (delta_t * 12)
t= 3:size(ExpectedPosition,1)-2;
ExpectedPosition_Velocity_Taylor = (-ExpectedPosition(t+2,:)+ (8 *ExpectedPosition(t+1,:)) + (-8*ExpectedPosition(t-1,:)) + (ExpectedPosition(t-2,:)))./ (delta_t * 12);
ActualalPosition_Velocity_Taylor = (-ActualalPosition(t+2,:)+ (8 *ActualalPosition(t+1,:)) + (-8*ActualalPosition(t-1,:)) + (ActualalPosition(t-2,:)))./ (delta_t * 12);
VelocityError_Taylor = ActualalPosition_Velocity_Taylor - ExpectedPosition_Velocity_Taylor ;
VelocityError_Taylor_mean = mean(VelocityError_Taylor,2);
figure, polar(GantryRotation_info_theat(3:end-2), VelocityError_Taylor_mean), 
title(sprintf('Velocity error of MLC (Talyor method)\n: %s\n', strrep(BankAFileName,'_',' ')))
view([90 270])
% figure, plot(ExpectedPosition_Velocity(:,30))
%% CalVelocity error (Talor)
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
VelocityError_single = VelocityError(:,30);
VelocityError_clt = clt_wjcheon(VelocityError_Taylor_single , number_of_conduct, number_of_element);
figure, subplot(1,2,1), histogram(VelocityError_single ), title('Histogram of velocity error'), grid on
subplot(1,2,2),histogram(VelocityError_clt), title('Histogram of velocity error (CLT)');
grid on
PositionError_clt_mean = mean(VelocityError_clt);
PositionError_clt_std  = std(VelocityError_clt);

%% VelocityError_clt 
number_of_conduct = 2000;
number_of_element = 50;
VelocityError_single = PositionError(:,30);
VelocityError_clt = clt_wjcheon(VelocityError_Taylor_single , number_of_conduct, number_of_element);
figure, subplot(1,2,1), histogram(PositionError), title('Histogram of velocity error'), grid on;
subplot(1,2,2), histogram(VelocityError_clt), title('Histogram of velocity error (CLT)');
grid on
VelocityError_clt_mean = mean(VelocityError_clt);
VelocityError_clt_std = std(VelocityError_clt);

%% Expected Position_clt

%% Actual Position 


