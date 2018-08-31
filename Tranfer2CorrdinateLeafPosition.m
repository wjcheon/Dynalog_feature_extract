function [ output_args ] = Tranfer2CorrdinateLeafPosition( cp_index_, bankA_pos_, bankB_pos_ )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

%% Witdh and Count
% Width
Outboard_1 = 0.272; %[cm]
Half = 0.250;  %[cm]
Quater = 0.122;  %[cm]
Outboard_60 = 0.39;  %[cm]
% Count
NumberOfOutboard_1 = 1;  %[ea]
NumberOfHalf = 13;  %[ea]
NumberOfQuater = 16;  %[ea]
NumberOfOutboard_60 = 1;  %[ea]

% PositionOffset = eps; % [cm]
PositionOffset = 18.6; % [cm]

TotalWithOfMLC = (Outboard_1*NumberOfOutboard_1)+(Half*NumberOfHalf)+(Quater*NumberOfQuater)+...
    (Quater*NumberOfQuater)+(Half*NumberOfHalf)+(Outboard_60*NumberOfOutboard_60);
%  11.0660 [cm]
%
index_ = cp_index_

%%
LengthOfMLC = 16;
Initial_open_A = 6.5;
InitPosition_A_Bank = -16+(PositionOffset/2)+Initial_open_A;
% DynamicLeafData_A_bank = flipud(cell2mat(DynamicLeafData(1:60,2)))*.0;
% DynamicLeafData_A_bank = flipud(cell2mat(DynamicLeafData(1:60,2)))*0.1;
DynamicLeafData_A_bank = transpose(bankA_pos_(index_,:).*0.1);
% DynamicLeafData_A_bank = flipud(cell2mat(DynamicLeafData))*0.1;
MLC_Position_A_Bank = zeros(4,120);

for iter2 = 1: size(MLC_Position_A_Bank,2)
    if iter2 <= size(MLC_Position_A_Bank,2)/2
        if iter2 == 1
            MLC_Position_A_Bank(1,iter2) = InitPosition_A_Bank+DynamicLeafData_A_bank(iter2,1);
            %             MLC_Position_A_Bank(1,iter2) = DynamicLeafData_A_bank
            MLC_Position_A_Bank(2,iter2) = TotalWithOfMLC/2 - 0.272;
            MLC_Position_A_Bank(3,iter2) = LengthOfMLC;
            MLC_Position_A_Bank(4,iter2) = Outboard_1;
            
        elseif iter2 > 1 && iter2 <15
            MLC_Position_A_Bank(1,iter2) = InitPosition_A_Bank+DynamicLeafData_A_bank(iter2,1);
            MLC_Position_A_Bank(2,iter2) =TotalWithOfMLC/2 - 0.272 - 0.250*(iter2-1);
            MLC_Position_A_Bank(3,iter2) = LengthOfMLC;
            MLC_Position_A_Bank(4,iter2) = Half;
            
        elseif iter2 >=15 && iter2 < 47
            MLC_Position_A_Bank(1,iter2) = InitPosition_A_Bank+DynamicLeafData_A_bank(iter2,1);
            MLC_Position_A_Bank(2,iter2) = TotalWithOfMLC/2 - 0.272 - (0.250*13) - Quater*(iter2-14);
            MLC_Position_A_Bank(3,iter2) = LengthOfMLC;
            MLC_Position_A_Bank(4,iter2) = Quater;
            
        elseif iter2 >= 47 && iter2 < 60
            MLC_Position_A_Bank(1,iter2) = InitPosition_A_Bank+DynamicLeafData_A_bank(iter2,1);
            MLC_Position_A_Bank(2,iter2) = TotalWithOfMLC/2 - 0.272 - 0.250*(iter2-33) - (Quater*32);
            MLC_Position_A_Bank(3,iter2) = LengthOfMLC;
            MLC_Position_A_Bank(4,iter2) = Half;
            
        else
            MLC_Position_A_Bank(1,iter2) = InitPosition_A_Bank+DynamicLeafData_A_bank(iter2,1);
            MLC_Position_A_Bank(2,iter2) = TotalWithOfMLC/2 - 0.272 - 0.250*(iter2-34) - (Quater*32) -  Outboard_60;
            MLC_Position_A_Bank(3,iter2) = LengthOfMLC;
            MLC_Position_A_Bank(4,iter2) = Outboard_60;
            
        end
    end
end

%

Initial_open_B = Initial_open_A.*(-1);
InitPosition_B_Bank = 0-(PositionOffset/2)+Initial_open_B;
MLC_Position_B_Bank = zeros(4,120);
% DynamicLeafData_B_bank = flipud(cell2mat(DynamicLeafData(61:120,2)))*.0;
% DynamicLeafData_B_bank = flipud(cell2mat(DynamicLeafData(61:120,2)))*0.1;
DynamicLeafData_B_bank = transpose(bankB_pos_(index_,:).*0.1);


for iter3= 1: size(MLC_Position_B_Bank,2)
    if iter3 <= size(MLC_Position_B_Bank,2)/2
        if iter3 == 1
            MLC_Position_B_Bank(1,iter3) = InitPosition_B_Bank+DynamicLeafData_B_bank(iter3,1);
            MLC_Position_B_Bank(2,iter3) = TotalWithOfMLC/2 - 0.272;
            MLC_Position_B_Bank(3,iter3) = LengthOfMLC;
            MLC_Position_B_Bank(4,iter3) = Outboard_1;
            
        elseif iter3 > 1 && iter3 <15
            MLC_Position_B_Bank(1,iter3) = InitPosition_B_Bank+DynamicLeafData_B_bank(iter3,1);
            MLC_Position_B_Bank(2,iter3) = TotalWithOfMLC/2 - 0.272 - 0.250*(iter3-1);
            MLC_Position_B_Bank(3,iter3) = LengthOfMLC;
            MLC_Position_B_Bank(4,iter3) = Half;
            
        elseif iter3 >=15 && iter3 < 47
            MLC_Position_B_Bank(1,iter3) = InitPosition_B_Bank+DynamicLeafData_B_bank(iter3,1);
            MLC_Position_B_Bank(2,iter3) = TotalWithOfMLC/2 - 0.272 - (0.250*13) - Quater*(iter3-14);
            MLC_Position_B_Bank(3,iter3) = LengthOfMLC;
            MLC_Position_B_Bank(4,iter3) = Quater;
            
        elseif iter3 >= 47 && iter3 < 60
            MLC_Position_B_Bank(1,iter3) = InitPosition_B_Bank+DynamicLeafData_B_bank(iter3,1);
            MLC_Position_B_Bank(2,iter3) = TotalWithOfMLC/2 - 0.272 - 0.250*(iter3-33) - (Quater*32);
            MLC_Position_B_Bank(3,iter3) = LengthOfMLC;
            MLC_Position_B_Bank(4,iter3) = Half;
            
        else
            MLC_Position_B_Bank(1,iter3) = InitPosition_B_Bank+DynamicLeafData_B_bank(iter3,1);
            MLC_Position_B_Bank(2,iter3) = TotalWithOfMLC/2 - 0.272 - 0.250*(iter3-34) - (Quater*32) -  Outboard_60;
            MLC_Position_B_Bank(3,iter3) = LengthOfMLC;
            MLC_Position_B_Bank(4,iter3) = Outboard_60;
            
        end
    end
end




end

