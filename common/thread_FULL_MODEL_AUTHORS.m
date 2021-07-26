function [cpost, clevel, cauthors] = thread_FULL_MODEL_AUTHORS(N, x)

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

na = 3;             % current author
pn = .95;            % probability of new author
pr = .9;            % probability of replied author
va = zeros(1,N);    % vector of authors
ha = zeros(1,N);    % num comments per author
repl = false(1,N);  % whether authors was replied or not
va(1) = 1;          % vector of authors
va(2) = 2;
ha(1) = 1;
ha(2) = 1;
repl(1) = true;
for t = 2:N
    
    %% SELECT AUTHOR
    % choose new author with probability pn
    new_author = rand>pn || t<3;
    if ~new_author
        if rand<pr && sum(repl(2:t))>1

            % choose replied author
            ir = find(repl(1:na-1));
            ir = ir(2:end);     % skip root
        else
            
            % choose non-replied author
            ir = find(~repl(1:na-1));
        end
        ir(ir == va(t)) = [];   % skip previous author
        pd = ha(ir);
        pd = pd/sum(pd);
        cdf = cumsum(pd);
        ca = ir(find(cdf > rand, 1, 'first'));
    else
        ca = na;
    end
    va(t+1) = ca;
    ha(ca) = ha(ca) + 1;
    ap = va(cpost(cpost > 0));
    rec = (ap == ca);       % get comments with parent author equal to ca

    %% SELECT NODE
	pd = [degrees(1)*alp + bet + tau^t, ...
        degrees(2:t).*alp + tau.^(t-1:-1:1) + kap*rec];
    pd = pd/sum(pd);
    cdf = cumsum(pd);
    if (abs(cdf(end)-1) > 2e-13)
        disp(['error cdf: ' num2str(abs(cdf(end)-1))]);
    end
    theparent = find(cdf > rand, 1, 'first');
    cpost(t+1) = theparent;
    clevel(t+1) = clevel(theparent)+1;
    degrees(theparent) = degrees(theparent) + 1;
    degrees(t+1) = deg0;
    
    %% update parent author as replied
    if theparent > 1
        repl(va(theparent)) = true;
    end
    if new_author
        na = na + 1;
    end
end
cauthors = va;