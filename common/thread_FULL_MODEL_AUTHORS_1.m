function [cpost, clevel, cauthors, cauthorsrep, cprobs] = thread_FULL_MODEL_AUTHORS_1(N, x)

% with authormodel and NO constraints
cprobs = zeros(1,N+1);

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
bet = exp( x(1) );
alp = x(2);
tau = x(3);
kap = exp( x(4) );

auth_replied = zeros(1,N+1);        % how many times an author has been replied
auth_replied(1) = 2;
auth_replied(2) = 1;

auth_com_replied = zeros(N+1,N+1);      % whether author i replied comment j
auth_com_replied(2,1) = 1;

cauthors = zeros(1,N+1);    % vector of authors
cauthors(1) = 1;          % vector of authors
cauthors(2) = 2;

cauthorsrep = zeros(1,N+1);    % vector of parents of authors
cauthorsrep(1) = 0;          % vector of authors
cauthorsrep(2) = 1;

ha = zeros(1,N+1);    % num comments per author
ha(1) = 1;
ha(2) = 1;
na = 3;             % current author

for t = 2:N
    
    %% SELECT AUTHOR
    % choose new author with probability pn
    new_author = rand<(t-1)^(-1/7);
    
    if ~new_author
        ir = 1:na-1;
        %ir(ir == cauthors(t)) = [];   % skip previous author
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
    forbid = auth_com_replied(ca,1:t);%(cauthors(1:t) == ca) | 
    
    rec = ap == ca;       % get comments with parent author equal to ca
    
    %% SELECT NODE
	pd = ~forbid(1:t).*[degrees(1)*alp + bet + tau^t, ...
        degrees(2:t).*alp + tau.^(t-1:-1:1) + kap*rec];
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
    cauthorsrep(t+1) = cauthors(theparent);
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
