function pos=ismembermatrix(newRoute,routes)
[a,~]=size(routes);
for i=1:a
    if isequal(newRoute,routes{i,:})
        pos=1;
        return
    end
end
pos=0;
end