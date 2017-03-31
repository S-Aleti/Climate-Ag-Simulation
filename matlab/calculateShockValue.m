function [ new_price ] = calculateShockValue( alpha_d, beta_d, ...
                                     alpha_s, beta_s, price, new_quantity)
%CALCULATESHOCKVALUE Summary of this function goes here
%   Detailed explanation goes here

% 2

a_shock = new_quantity - beta_s*price - alpha_s;

% 3

new_price = ( a_d - (a


end

