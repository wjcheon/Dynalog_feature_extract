function [ AVV_cp ] = cal_AAV_cp( cp_index_, bankA_pos_, bankB_pos_ )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
a=0;
bankA_pos_sel = bankA_pos_(cp_index_, :);
backB_pos_sel = bankB_pos_(cp_index_, :);
AVV_cp_numerator = abs(sum(bankA_pos_sel - backB_pos_sel));
AVV_cp_denominator =  max(abs(sum(bankA_pos_ - bankB_pos_ , 2)));
AVV_cp = AVV_cp_numerator/AVV_cp_denominator;


end

