function routes=initializePathsWithImpact()
load data
b1=1/3;b2=1/3;b3=1/3;bs=1/3;be=1/3;br=1/3;
J=1:n;
routes={};
costs=[];
flag=1;
while J
   %寻找最远的距离
   far = -1 ;
   max_dist = -1 ;
   for j=J
       if d(1,j+1)>max_dist
           far=j;
           max_dist=d(1,j+1);
       end
   end
   route=[0,far,n+1]; %
   arr=[0,d(1,far+1)];
   s=[0,max(a(far+1),arr(2))]; %上界
   arr=[arr,s(2)+d(far+1,n+2)];
   s=[s,max(arr(3),a(n+2))];
   J(find(J==far))=[];
   feasible=J;
   while feasible
       proposals=[];
       %寻找可插入的节点
       for u=feasible
           bestImpact=0;
           bestPosition=0;
           Jminu=J;
           Jminu(find(Jminu==u))=[];
           feasiblePositions = [];
           IS=[];IU=[];LD=[];
           % 插入节点的位置
           for pos=2:length(route)
               [newRoute,newS,newArr]=insertNode(route,u,pos,s,arr,d,a); %插入节点
               %判断节点是否可插入
               if routeIsFeasible(newRoute, a, b, newS, d, q, Q)
                   feasiblePositions=[feasiblePositions,pos];
                   [Is,Iu,Ld]=computeISIULD(pos,newRoute,newArr,newS,a,b,d,Jminu);
                   IS=[IS,Is];IU=[IU,Iu];LD=[LD,Ld];
               end
           end
           if isempty(feasiblePositions)
               feasible(find(feasible==u))=[];
           else
               [bestPosition, bestImpact] = computeImpact(IS, IU, LD, feasiblePositions);
               proposals=[proposals;u,bestPosition,bestImpact];
           end
       end
       if ~isempty(proposals)
           [~,MinPositions]=min(proposals(:,3));
           nodeToInsert=proposals(MinPositions,1);
           insertPos = proposals(MinPositions,2);
           [route, s, arr]= insertNode(route, nodeToInsert, insertPos, s,arr, d, a);
           feasible(find(feasible==nodeToInsert))=[];
           J(find(J==nodeToInsert))=[];
       end
   end
    routes=[routes;route];
    costs=[costs;computeRouteCost(route, d)];
end
fprintf("Impact routes:\n");
for route=routes'
 disp(cell2mat(route))
end
end

function [newRoute,newS,newArr]=insertNode(route, node, position, s, arr, d, a)
    newRoute=route;
    newRoute=[newRoute(1:position-1),node,newRoute(position:end)];
    newS=[];newArr=[];
    for i=1:position-1
        newS=[newS,s(i)];
        newArr=[newArr,arr(i)];
    end
    for i=position:length(newRoute)
        newArr=[newArr,newS(i-1)+d(newRoute(i-1)+1,newRoute(i)+1)];
        newS=[newS,max(newArr(i), a(i))];
    end
end
function is=routeIsFeasible(route, a, b, s, d, q, Q)
    cap=sum(q(route+1));
    if cap>Q
        is=0;
        return
    end
    for i=1:length(route)
        if s(i)>=a(route(i)+1) && s(i)<=b(route(i)+1)
            is=1;
        else
            is=0;
            return
        end
    end
end
function [IS,IU,LD]=computeISIULD(posU, route, arr, s, a, b, d, Jminu)
    b1=1/3;b2=1/3;b3=1/3;
    u=route(posU);
    posI = posU-1; posJ = posU+1;
    i = route(posI); j = route(posJ);
    IS=arr(posU)-a(u+1);
    IU=1/(max(length(Jminu),1))*sum(max((b(Jminu+1)-a(u+1)-d(u+1,Jminu+1)),(b(u+1)-a(Jminu+1)-d(u+1,Jminu+1))));
    c1=d(i+1,u+1)+d(u+1,j+1)-d(i+1,j+1);
    c2=(b(j+1)- (arr(posI) + d(i+1,j+1))) -(b(j+1) - (arr(posU) + d(i+1,j+1)));
    c3=(b(u+1) - (arr(posI) + d(i+1,u+1)));
    LD = b1*c1 + b2*c2 + b3*c3;
end
function [bestPosition, bestImpact] = computeImpact(IS, IU, LD, feasiblePositions)
    IR = sum(LD)/length(feasiblePositions);
    bestImpact = -1;
    bestPosition = -1;
    for i=1:length(feasiblePositions)
        impact=IS(i) + IU(i) + IR;
        if (bestPosition==-1)|| impact<=bestImpact
            bestImpact=impact;
            bestPosition = feasiblePositions(i);
        end
    end
end