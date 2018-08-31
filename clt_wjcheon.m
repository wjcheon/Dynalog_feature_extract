function [ output_args ] = clt_wjcheon( random_vector_, number_of_conduct_, number_of_sample_ )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% a=0;
sz_random_vector = size(random_vector_,1);
clt_container = zeros(number_of_conduct_,1);

for iter1 = 1: number_of_conduct_
    random_index = randi(sz_random_vector, [number_of_sample_, 1]);
    clt_container(iter1) = mean(random_vector_(random_index));
    fprintf('%d / %d was performed !!\n',iter1,number_of_conduct_)
end

output_args = clt_container;
end

