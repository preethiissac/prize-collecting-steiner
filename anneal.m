function [x0,f0]=sim_anl(f,x0,l,u,Mmax,TolFun)
    % Preethi Issac , Vivek Sardeshmukh
    %EXAMPLE
    camel= @(x)(4-2.1*x(1).^2+x(1).^4/3).*x(1).^2+x(1).*x(2)+4*(x(2).^2-1).*x(2).^2;% function 
    f = camel ; % a function handle
    x0 =[0,0] ; % an initial guess for the minimun
    l = [-10,-10]; % lower bound for minimun
    u = [10,10];%a upper bound for minimun
    Mmax = 400; % maximun number of temperatures
    TolFun = .001; %tolerence


    if nargin<6
	TolFun=1e-4;
	if nargin<5
	    Mmax=100;
	end
    end
    %x0 is the current solution point and f0=f(x0).
    %x is the current point and fx=f(x)
    %x1 is the test point and fx1=f(x1)
    %Our initial current point will be the current solution point
    x=x0;fx=feval(f,x);f0=fx;
    %Main loop simulates de annealing from a high temperature to zero in Mmax iterations.
    for m=0:Mmax
	%We calculate T as the inverse of temperature.
	%Boltzman constant = 1
	T=m/Mmax; 
	mu=10^(T*100);    
	%For each temperature we take 500 test points to simulate reach termal
	%equilibrium.
	for k=0:500        
	    %We generate new test point using mu_inv function [3]        
	    dx=mu_inv(2*rand(size(x))-1,mu).*(u-l);
	    x1=x+dx;
	    %Next step is to keep solution within bounds
	    x1=(x1 < l).*l+(l <= x1).*(x1 <= u).*x1+(u < x1).*u;
	    %We evaluate the function and the change between test point and
	    %current point
	    fx1=feval(f,x1);df=fx1-fx;
	    %If the function variation,df, is <0 we take test point as current
	    %point. And if df>0 we use Metropolis [5] condition to accept or
	    %reject the test point as current point.
	    %We use eps and TolFun to adjust temperature [4].        
	    if (df < 0 || rand < exp(-T*df/(abs(fx)+eps)/TolFun))==1
		x=x1;fx=fx1;
	    end        
	    %If the current point is better than current solution, we take
	    %current point as cuyrrent solution.       
	    if fx1 < f0 ==1
		x0=x1;f0=fx1;
	    end   
	end
    end
end

function x=mu_inv(y,mu)
    %This function is used to generate new point according to lower and upper
    %and a random factor proportional to current point.
    x=(((1+mu).^abs(y)-1)/mu).*sign(y);
end
