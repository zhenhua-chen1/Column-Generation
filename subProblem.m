function [routes, rcosts]= subProblem(n, q, d, readyt, duedate, rc, Q, M)
  % Time windows reduction
  [a,b]=reduceTimeWindows(n, d, readyt, duedate);
  % Reduce max capacity to boost algorithm
  if sum(q)<Q
      Q=sum(q);
  end
  T=max(b);
  
  % Init necessary data structure
  f={};
  p={};
  f_tk={};
  
  paths={};
  paths_tk={};
  
  for j=1:n+2
      paths{j,1}={};
      paths_tk{j,1}={};
      for qt=1:(Q-q(j))
           paths{j}{qt,1}={};
           paths_tk{j}{qt,1}={};  
           for tm=1:b(j)-a(j)
                 paths{j}{qt}{tm,1}=[];
                 paths_tk{j}{qt}{tm,1}=[]; 
           end
      end
      mat=zeros(Q-q(j),b(j)-a(j));
      p{j,1}=mat-1;
      f{j,1}=mat+M;
      f_tk{j,1}=mat+M;      
  end
  f{1,1}(1,1)=0;
  f_tk{1}(1,1)=0;
  L=[0];
  
  % Ëã·¨¿ªÊ¼
  while ~isempty(L)
      i=L(1)+1;
      L(1)=[];
      if i==n+2
          continue
      end
    % Explore all possible arcs (i,j)
      for j=2:n+2
          if i==j
              continue
          end
          for q_tk=q(i):(Q-q(j)-1)
              for t_tk=a(i):(b(i)-1)
                    if p{i}(q_tk-q(i)+1, t_tk-a(i)+1) ~= j-1
                      if f{i}(q_tk-q(i)+1, t_tk-a(i)+1) < M
                          for t=max(a(j),round(t_tk+d(i,j))):b(j)-1
     % if the current best path is suitable to become the alternative path 
                              if f{j}(q_tk+1, t-a(j)+1)> f{i}(q_tk-q(i)+1,t_tk-a(i)+1)+rc(i,j)
                                  if (p{j}(q_tk+1,t-a(j)+1)~=i-1)&& ...
                                         (p{j}(q_tk+1, t-a(j)+1) ~= -1)&& ...
                                         (f{j}(q_tk+1, t-a(j)+1) < M)&& ...
                                          f{j}(q_tk+1, t-a(j)+1) < f_tk{j}(q_tk+1, t-a(j)+1)
                                           f_tk{j}(q_tk+1, t-a(j)+1)=f{j}(q_tk+1, t-a(j)+1);
                                           paths_tk{j}{q_tk+1}{t-a(j)+1} = paths{j}{q_tk+1}{t-a(j)+1};
                                  end
                              % update f 
                                  f{j}(q_tk+1,t-a(j)+1)=f{i}(q_tk-q(i)+1,t_tk-a(i)+1) + rc(i,j);
                              % update path that leads to node j
                                  paths{j}{q_tk+1}{t-a(j)+1}=[paths{i}{q_tk-q(i)+1}{t_tk-a(i)+1},j-1];
                              % Update predecessor
                                  p{j}(q_tk+1,t-a(j)+1)=i-1;
                                  L=[L;j-1];
                                  L=unique(L,'rows','stable');
                              elseif (p{j}(q_tk+1, t-a(j)+1) ~= i-1)&& ...
                                     (p{j}(q_tk+1, t-a(j)+1) ~= -1)&& ...
                                     (f_tk{j}(q_tk+1, t-a(j)+1)>f{i}(q_tk-q(i)+1,t_tk-a(i)+1)+rc(i,j))
                                     f_tk{j}(q_tk+1, t-a(j)+1)=f{i}(q_tk-q(i)+1,t_tk-a(i)+1)+rc(i,j);
                                     paths_tk{j}{q_tk+1}{t-a(j)+1}=[paths{i}{q_tk-q(i)+1}{t_tk-a(i)+1},j-1];
                              end                        
                          end
                      end
                   else   % if predecessor of i is j
                          if f_tk{i}(q_tk-q(i)+1, t_tk-a(i)+1)<M
                              for t=max(a(j),round(t_tk+d(i,j))):b(j)-1
                                  if f{j}(q_tk+1,t-a(j)+1)>f_tk{i}(q_tk-q(i)+1,t_tk-a(i)+1)+rc(i,j)
                                    %if the current best path is suitable to
                                    %become the alternative path
                                    if (p{j}(q_tk+1,t-a(j)+1)~=i-1) && ...
                                         (p{j}(q_tk+1,t-a(j)+1)~=-1)&& ...
                                         (f{j}(q_tk+1,t-a(j)+1)<M)&& ...
                                         (f{j}(q_tk+1,t-a(j)+1))<(f_tk{j}(q_tk+1,t-a(j)+1))
                                              f_tk{j}(q_tk+1,t-a(j)+1) = f{j}(q_tk+1,t-a(j)+1);
                                              paths_tk{j}{q_tk+1}{t-a(j)+1} = paths{j}{q_tk+1}{t-a(j)+1};
                                    end
                                  % update f, path and bucket
                                  f{j}(q_tk+1,t-a(j)+1) = f_tk{i}(q_tk-q(i)+1,t_tk-a(i)+1) + rc(i,j);
                                  paths{j}{q_tk+1}{t-a(j)+1} =  [paths_tk{i}{q_tk-q(i)+1}{t_tk-a(i)+1} ,j-1];
                                  p{j}(q_tk+1+1,t-a(j)+1) = i-1;
                                  L=[L;j-1];
                                  L=unique(L,'rows','stable');
                                  % if the alternative path of i is suitable to  be the alternate of j
                                  elseif (p{j}(q_tk+1, t-a(j)+1) ~= i-1)&& ...
                                          (p{j}(q_tk+1, t-a(j)+1) ~= -1)&& ...
                                          (f_tk{j}(q_tk+1,t-a(j)+1)>f_tk{i}(q_tk-q(i)+1,t_tk-a(i)+1)+rc(i,j))
                                      f_tk{j}(q_tk+1, t-a(j)+1) =f_tk{i}(q_tk-q(i)+1,t_tk-a(i)+1)+rc(i,j);
                                      paths_tk{j}{q_tk+1}{t-a(j)+1} = [paths_tk{i}{q_tk-q(i)+1}{t_tk-a(i)+1},j-1];
                                  end
                              end
                          end
                    end
              end
          end
      end   
  end
  %return all the routes with negative cost
  [qBest,tBest]=find(f{n+2}<-1e-9);
   routes={};
   rcosts=[];
   for i=1:length(qBest)
       newRoute=[0,paths{n+2}{qBest(i)}{tBest(i)}];
       if ~(ismembermatrix(newRoute,routes))
           routes=[routes;newRoute];
           rcosts=[rcosts;f{n+2}(qBest(i),tBest(i))];
       end
   end
    fprintf("Impact routes:\n");
    for route=routes'
     disp(cell2mat(route))
    end
end

function [a,b]=reduceTimeWindows(n, d, a, b)
 update=1;
 while update
     update = 0;
     for k=1:n
         min_a=[];
         %  Ready Time
         for i=1:n+1
             if i~=k+1
                 min_a=[min_a,a(i)+d(i,k+1)];
             end
         end
         min_a=min(min_a);
         minArrPred = min(b(k+1),min_a);
         min_a=[];
         for j=2:n+2
             if j~=k+1
                 min_a=[min_a,a(j)-d(k+1,j)];
             end
         end 
         min_a=min(min_a);
         minArrNext=min(b(k+1),min_a);
         newa=fix(max([a(k+1),minArrPred,minArrNext]));
         if newa~=a(k+1)
             update = 1;
         end
         a(k+1)=newa;
         %  Due Time
         max_b=[];
         for i=1:n+1
             if i~=k+1
                 max_b=[max_b,b(i)+d(i,k+1)];
             end
         end
         max_b=max(max_b);
         maxDepPred = max(a(k+1),max_b);
         max_b=[];
         for j=2:n+2
             if j~=k+1
                 max_b=[max_b,b(j)-d(k+1,j)];
             end
         end 
         max_b=max(max_b);
         maxDepNext=max(a(k+1),max_b);
         newb=fix(min([b(k+1),maxDepPred,maxDepNext]));
         if newb~=b(k+1)
             update = 1;
         end
         b(k+1)=newb;
     end
 end
    
end