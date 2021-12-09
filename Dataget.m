function Dataget()
data=xlsread('./solomon-instances/c101.xlsx');
%% 网络图数据
x=data(:,2)';
y=data(:,3)';
x=[x,x(1)];
y=[y,y(1)];
% x=[35 41 35 55 55 15 25 20 10 55 30 20];
% y=[35 49 17 45 20 30 30 50 43 60 60 35];
node=length(x);%节点数
for i = 1:(node-1)
    for j = (i+1):node
        d(i,j)=((x(i)-x(j))^2+(y(i)-y(j))^2)^0.5;%求两点距离坐标;
        d(j,i)=d(i,j);
    end
end

n=node-2;
%% 时间窗
a=data(:,5)';
a=[a,a(1)];
b=data(:,6)';
b=[b,b(1)];
q=data(:,4)';
q=[q,q(1)];
Q=200;
Kdim=25;
M=1e+100;

save data
end