function [ y ] = exponential( x, n )
%EXPONENTIAL Summary of this function goes here
%   Detailed explanation goes here

y=1;
for k=1:n
    y=y+(x.^k)/factorial(k);
end

% y=sum(x.^(0:n)./factorial(0:n));

end