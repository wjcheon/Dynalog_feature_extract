function [ LSV_cp ] = cal_LSV_cp_v2( pos_max_cp_, bankA_pos_, bankB_pos_ )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
NUMBER_OF_LEAF = 60 ;

bankA_pos_sel = bankA_pos_(cp_index_,:);
bankB_pos_sel = bankB_pos_(cp_index_,:);
pos_max_left = max(bankA_pos_sel) - min(bankA_pos_sel);
pos_max_right = max(bankB_pos_sel) - min(bankB_pos_sel);


leafbank_numerator_left = sum(pos_max_left - abs(diff(bankA_pos_sel)));
leafbank_denominator_left = (NUMBER_OF_LEAF -1 )* pos_max_left;
LSV_cp_leftbank = leafbank_numerator_left/leafbank_denominator_left;

leafbank_numerator_right = sum(pos_max_right - abs(diff(bankB_pos_sel)));
leafbank_denominator_right = (NUMBER_OF_LEAF -1 )* pos_max_right;
LSV_cp_rightbank = leafbank_numerator_right/leafbank_denominator_right;

LSV_cp = LSV_cp_leftbank*LSV_cp_rightbank;
end

