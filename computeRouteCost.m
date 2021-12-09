function cost=computeRouteCost(route, d)
 cost = 0;
    for i =1:(length(route)-1)
        cost =cost+ d(route(i)+1, route(i+1)+1);
    end
end