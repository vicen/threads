function vcomments = generate_numcomments(N, total_comments, minc)

% ----------------------------------------------
% vcomments = generate_numcomments(numsamples, total_comments)
%
% generates N samples from the empirical distribution total_comments
% of the number of comments per post of slashdot

if nargin < 3
    minc = 1;
end

[a,b]=hist(total_comments,min(total_comments):max(total_comments));
%plot(b,cumsum(a)./sum(a),'k');hold on;

% generate uniform random numbers in the cdf
r = 1 + (sum(a)-1).*rand(2*N,1);

% get the corresponding num comments
vcomments = zeros(1,N);
s = 1;
n = 1;
while s<=N && n<numel(r)
    nc = find(cumsum(a) > r(s), 1, 'first');
    if nc >= minc
        vcomments(s) = nc;
        s = s+1;
    else
        n = n+1;
    end
end

if s == 2*n
    vcomments = [];
end

%[a,b]=hist(vcomments,min(vcomments):max(vcomments));
%plot(b,cumsum(a)./sum(a),'b');hold on;
