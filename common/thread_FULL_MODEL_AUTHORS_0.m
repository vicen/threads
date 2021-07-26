function [cpost, clevel, cauthors, cprobs, cZs] = thread_FULL_MODEL_AUTHORS_0(N, x)

%% delete this
cZs = zeros(1,N+1);
cprobs = zeros(1,N+1);
%% delete this

deg0=1;
degrees = zeros(1,N+1);
degrees(1:2) = deg0;

cpost = zeros(1,N+1);
cpost(1) = -42;
cpost(2) = 1;

clevel = zeros(1,N+1);
clevel(1) = 1;
clevel(2) = 2;

% parameters
bet = exp(x(1));
alp = x(2);
tau = x(3);
kap = exp(x(4));

auth_replied = zeros(1,N+1);        % how many times an author has been replied
auth_com_replied = zeros(N+1,N+1);      % whether author i replied comment j
auth_replied(1) = 1;
auth_replied(2) = 1;
mint = 10;

na = 3;             % current author
cauthors = zeros(1,N+1);    % vector of authors
ha = zeros(1,N+1);    % num comments per author
cauthors(1) = 1;          % vector of authors
cauthors(2) = 2;
ha(1) = 1;
ha(2) = 1;
for t = 2:N
    
    %% SELECT AUTHOR
    % choose new author with probability pn
    if t > 5, %max(N-round(2*N/3),3)
        new_author = rand<((t-1)^(-1/7)) || t<3;
    else
        new_author = 1;
    end
    
    if ~new_author
%         afi = false;
%         ta = max(2,t-mint);
%         while ~afi && (ta > 1)
%             afi = numel(unique(cauthors(ta:t-1)))>=mint;
%             ta = ta-1;
%         end
%         if ta == 1
%             ir = 2:na-1;
%         else
%             ir = unique(cauthors(ta:t-1));
%         end
        ir = 2:na-1;
        ir(ir == cauthors(t)) = [];   % skip previous author
        pd = auth_replied(ir);%ha(ir);
        pd = pd/sum(pd);
        cdf = cumsum(pd);
        ca = ir(find(cdf > rand, 1, 'first'));
    else
        ca = na;
    end
    cauthors(t+1) = ca;
    ha(ca) = ha(ca) + 1;
    ap = cauthors(cpost(cpost > 0));
    forbid = (cauthors(1:t) == ca) | auth_com_replied(ca,1:t);
    rec = ap == ca;       % get comments with parent author equal to ca
    
    %% SELECT NODE
	pd = ~forbid(1:t).*[degrees(1)*alp + bet + tau^t, ...
        degrees(2:t).*alp + tau.^(t-1:-1:1) + kap*rec];
    cZs(t+1) = sum(pd);    % delete this
    pd = pd/sum(pd);
    cdf = cumsum(pd);
    if (abs(cdf(end)-1) > 2e-13)
        disp(['error cdf: ' num2str(abs(cdf(end)-1))]);
    end
    theparent = find(cdf > rand, 1, 'first');
    cprobs(t+1) = pd(theparent); % delete this
    cpost(t+1) = theparent;
    clevel(t+1) = clevel(theparent)+1;
    degrees(theparent) = degrees(theparent) + 1;
    degrees(t+1) = deg0;
    
    %% update replies
    auth_replied(cauthors(theparent)) = auth_replied(cauthors(theparent))*2;
    auth_com_replied(ca,theparent) = 1;

    %% update parent author as replied
    if new_author
        auth_replied(ca) = 1; % baseline
        na = na + 1;
    end
    
end
% bar(log2(auth_replied(auth_replied>0)))
% auth_replied
