function vliks = thread_NO_TAU_AUTHORS_0_lik(N, x, data)

cpost = data{1}; % assumes [-42 ..] notation
cauthors = data{2};
vliks = zeros(1,N+1);

deg0=1;
degrees = zeros(1,N+1);
degrees(1:2) = deg0;

% parameters
bet = exp(x(1));
alp = x(2);
kap = exp(x(3));

if (alp<=0)
    vliks = Inf;
    return
end

auth_com_replied = zeros(N+1,N+1);      % whether author i replied comment j
auth_com_replied(cauthors(2),1) = 1;

ap = cauthors(cpost(cpost > 0));
for t = 2:N
    ca = cauthors(t+1);
    forbid = (cauthors(1:t) == ca) | auth_com_replied(ca,1:t);
    rec = ap(1:t-1) == ca;       % get comments with parent author equal to ca
        
    %% SELECT NODE   
	pd = ~forbid(1:t).*[degrees(1)*alp + bet, degrees(2:t).*alp + kap*rec];
    pd = pd/sum(pd);
    theparent = cpost(t+1);
    if forbid(theparent)
        vliks(t+1) = -1;
        return;
    end
    vliks(t+1) = pd(theparent); % delete this
    degrees(theparent) = degrees(theparent) + 1;
    degrees(t+1) = deg0;
    
    auth_com_replied(ca,theparent) = 1;
end
