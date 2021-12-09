function [newA,B,lb,c]=aissignA_B(newA,routes,newc,A,c)
    [ran,~]=size(newA);
    if nargin==5  %输入容错
        newA=[-A(1:ran,:),newA];
        c=[c,newc];
    end
    newA=-newA;
    B=-ones(ran,1);
    B=[B;length(routes)];%限定系数
    newA=[newA;ones(1,length(routes))];%技术系数
    lb=zeros(1,length(routes));
end