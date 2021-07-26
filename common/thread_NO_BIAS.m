function [cpost, clevel] = thread_NO_BIAS(N, x)

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
alp = x(1);
tau = x(2);

for t = 2:N
    pdf = alp*degrees(1:t) + tau.^(t:-1:1);% +1;
	pdf = pdf/sum(pdf);
    cdf = cumsum(pdf);
    if (abs(cdf(end)-1) > 2e-13)
        disp(['error cdf: ' num2str(abs(cdf(end)-1))]);
    end
    theparent = find(cdf > rand, 1, 'first');
    cpost(t+1) = theparent;
    clevel(t+1) = clevel(theparent)+1;
    degrees(theparent) = degrees(theparent) + 1;
    degrees(t+1) = deg0;
end
