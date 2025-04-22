function dens = density(xwerte, ywerte)
% SYNTAX:
%        output = density(xwerte,ywerte)
% xwerte= Vektor mit x-Werten der Punkte 
% Ywerte= Vektor mit Y-Werten der Punkte
%
% This function calculates the density of dots
%
% Created Mai 2014  -- HD

%calculate number of iterations:
len=length(xwerte);
iterations=0;
k=1;

while k<len
    iterations = iterations + len-k;
    k=k+1;  
end

%calculate density
d=zeros(iterations,1);
num1=1;
num2=2;

for i=1 : iterations
        
    d(i)=sqrt( power((xwerte(num1) - xwerte(num2)),2) + power((ywerte(num1) - ywerte(num2)),2) );
    
    num2=num2+1;
    if num2>len
        num1=num1+1;
        num2=num1+1;
    end
    
end

dens = d;

    


  
end
