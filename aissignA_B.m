function [newA,B,lb,c]=aissignA_B(newA,routes,newc,A,c)
    [ran,~]=size(newA);
    if nargin==5  %�����ݴ�
        newA=[-A(1:ran,:),newA];
        c=[c,newc];
    end
    newA=-newA;
    B=-ones(ran,1);
    B=[B;length(routes)];%�޶�ϵ��
    newA=[newA;ones(1,length(routes))];%����ϵ��
    lb=zeros(1,length(routes));
end