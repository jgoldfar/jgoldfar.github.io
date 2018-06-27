x=1;
y=[1, 10000, 3.2456, sin(pi/4), x];
z=[1 10000 3.2456 sin(pi/4) x]; % Commas are optional

% Let's start something new

n=100;
x=1:n; % This is a vector of integers between 1 and 100
y=-10:(n-10); % In general, we can write y=min:max
z=1:2:n; % In general, z=min:step:max

x=linspace(0,1,20); % In general, linspace(min, max, numpts)

x(1:3:20)
x(x>0.5) % values of x where x>0.5 (logical indexing)