% fn=@(x)x.^2-4*x+1;
% % (1:10).^2 - 4*(1:10)+1;
% % fn(1:10);
% 
% % Plot fn at the x-values 1:10
% plot(linspace(1,10,500),fn(linspace(1,10,500)), 1:10, (1:10).^2)
% xlabel('x'); ylabel('y');
% legend('fn(x)','x^2');
% axis([3, 6, -5, 30]); % axis([xmin xmax ymin ymax])

% fn1=@(x,y)sqrt((x-(-1)).^2+(y-3).^2);
% [Xgrid, Ygrid]=meshgrid(linspace(-2,2,100), linspace(0,4,100));
% Z=fn1(Xgrid, Ygrid);
% % mesh(Xgrid, Ygrid, Z);
% surf(Xgrid, Ygrid, Z);
% xlabel('x'); ylabel('y'); zlabel('z');
% title('sqrt{(x+1)^2+(y-3)^2}');

% xgrid = linspace(0,1,100);
% plot(xgrid, exp(xgrid), xgrid, exponential(xgrid,3))

try
    DigitsOfPi(1)
    DigitsOfPi(0.03)
    DigitsOfPi(-1)
catch MException
    disp('One of those computations failed.');
end

exponential(1,100)