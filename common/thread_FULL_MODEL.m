function [cpost, clevel] = thread_FULL_MODEL(N, x)

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

for t = 2:N
    %pdf = [degrees(1)*alp + bet + tau^t, degrees(2:t).*alp + 1 + tau.^(t-1:-1:1)];
	pdf = [degrees(1)*alp + bet + tau^t, degrees(2:t).*alp + tau.^(t-1:-1:1)];
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
