function [A,C]=addRoutesToMaster(routes, mat, costs, d)
for i=1:length(routes)
    cost=d(routes{i}(1)+1,routes{i}(2)+1);
    for j=2:length(routes{i})-1
        cost=cost+d(routes{i}(j)+1,routes{i}(j+1)+1);
        mat(routes{i}(j),i)=1;
    end
    costs(i)=cost;
end
A=mat;
C=costs;
end