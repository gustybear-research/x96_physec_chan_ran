function ind = rmDupanew2(a0)
ind = [];
for ii = 2:length(a0)
    jj = ii-1;
    if (a0(jj)-a0(ii)) >= 350
        ind = [ind;jj];
    end
end
% ind = find(a0==max(a0));
numEst = length(ind)+1;
if ind(end) == length(a0)
    numEst = length(ind);
end