function [ AAV_cp ] = cal_AAV_cp_v2( cp_index_, AAVActual_, AAV_max_)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
a=0;

AAVActual_cp = AAVActual_(:,:,cp_index_);
AAVActual_cp = sum(AAVActual_cp(:));
AAV_cp = AAVActual_cp./AAV_max_;

end

