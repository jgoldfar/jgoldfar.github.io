function [ pi_est ] = DigitsOfPi( tol )
%DIGITSOFPI Calculate digits of pi within tolerance tol.
%   Uses an arctangent approximation to pi to calculate digits.
% pi = 4*sum_k=0^infinity (-1)^k/(2k+1)

pi_est = 0;
pi_est1 = 1;
k=0;
kmax = 10^6;

if tol<=0
    error('Tolerance is negative. Iteration will never stop.')
else
    disp('Thank you for the valid tolerance.');
end

while abs(pi_est-pi_est1)>tol
    % Calculate while the difference between successive iterations/values
    % is too large.
    pi_est1 = pi_est;
    pi_est = pi_est + 4*(-1)^k/(2*k+1);
    
    k=k+1;
    if k>kmax
        break
%     else
%         disp(abs(pi_est-pi_est1))
    end
end

end