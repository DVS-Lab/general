function [x1_minus_x2, permP] = PermTest_2sample(x1,x2)

nperms = 10000;
nx1 = length(x1);
nx2 = length(x2);

data = [x1; x2];
labels = [ones(nx1,1); ones(nx2,1)*2]; %set labels
perm_dist = zeros(nperms+1,1); %first row will be the empirical result
count = 0;
for perm = 0:length(perm_dist)
    count = count + 1;
    if ~perm
        %compute the group difference
        perm_dist(count,1) = mean(data(labels==1)) - mean(data(labels==2));
    else
        perm_data = data(randperm(length(data)));
        perm_dist(count,1) = mean(perm_data(labels==1)) - mean(perm_data(labels==2));
    end
end
figure,hist(perm_dist,50)

[ranks, ~] = tiedrank(perm_dist);
pcts = ranks/length(ranks);
permP = 1-pcts(1);
x1_minus_x2 = perm_dist(1);

