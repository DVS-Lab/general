function better_than_chance = get_chance(nperms,Ap,Bp)
% goal: simulate chance behavior to determine payment
% 
% nperms is number of fake subjects (use at least 10000)
% Ap is p(reward) for option A
% Bb is p(reward) for option B

ntrials = 40;
data = zeros(nperms,1);
for p = 1:nperms
    subdata = zeros(ntrials,1);
    for t = 1:ntrials
        if rand < 0.5 
            % chose A
            if rand < Ap
                subdata(t,1) = 1;
            else
                subdata(t,1) = 0;
            end
        else
            % chose b
            if rand < Bp
                subdata(t,1) = 1;
            else
                subdata(t,1) = 0;
            end
        end
    end
    data(p,1) = sum(subdata); % count wins
end
figure,hist(data,50); % always look at your data
better_than_chance = prctile(data,95)/ntrials; % grab 95th percentile of chance distribution of winnings and dvide by ntrials to get chance accuracy