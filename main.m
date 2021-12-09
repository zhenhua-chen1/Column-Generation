clc
clear all
dbstop if error
Dataget()
load data
impactSol = initializePathsWithImpact();%���ɳ�ʼ��
routes=impactSol;
impactcosts=0;
for route=routes'
    route=route{1};
    impactcosts=impactcosts+computeRouteCost(route, d);
end
A=zeros(n,length(routes));%ϵ������
C=zeros(1,length(routes));%��ֵϵ��
[A,c]=addRoutesToMaster(routes, A, C, d);%��������ӵ���������
%assign A and B
[A,B,lb]=aissignA_B(A,routes);
% A=-A;
% [ran,col]=size(A);
% B=-ones(ran,1);
% B=[B;length(routes)];%�޶�ϵ��
% A=[A;ones(1,length(routes))];%����ϵ��
% lb=zeros(1,length(routes));

rc=zeros(n+2,n+2);%reduced costs
iter=1;
tic
while 1    
    disp(['��',num2str(iter),'�˵���'])
    [x,fval,exitflag,output,lambda]=linprog(c,A,B,[],[],lb);%���
    pi_i=lambda.ineqlin;
    pi_i(end)=[];
    pi_i=[0;pi_i;0];%������

    for i=1:n+2
        for j=1:n+2
            rc(i,j)=d(i,j)-pi_i(i);
        end
    end

    if find(rc<=-M)
        break
    end
    newRoutes = subProblem(n, q, d, a, b, rc, Q, M);
    if isempty(newRoutes)
        break
    end
    for route=newRoutes'
        if ismembermatrix(route,routes)
            break
        end
    end
    %Add new routes to master problem
    newMat = zeros(n,length(newRoutes));
    newCosts = zeros(1,length(newRoutes));
    [newMat,newCosts] = addRoutesToMaster(newRoutes,newMat,newCosts,d);
    routes = [routes;newRoutes];
    [A,B,lb,c]=aissignA_B(newMat,routes,newCosts,A,c);
    iter=iter+1;
    toc
end

%% solve IP 
% NumberofVariable=length(c);
% ops=sdpsettings('solver','gurobi','savesolveroutput',1);
% % Set variable type back to binary
% y=binvar(1,NumberofVariable);
% CT1=[];
% for i=1:n
%     CT1=[CT1,(-A(i,:)*y(:)>=1)];
% end
% CT2=[sum(y(:))<=Kdim,y>=0];
% obj=y*c';
% sol=optimize(CT1+CT2,obj,ops);
% y=double(y);
% pos=find(y==1);
% routes{pos}
% obj=double(obj)
pos=find(x==1);
routes{pos}
fval
toc