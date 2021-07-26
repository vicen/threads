function f = fun2min_ML_NO_ALPHA(x, p)

bet = exp(x(1));
tau = x(2);

%Zs = repmat( bet+ tau+(1:p.Tmax-1)'+cumsum(tau.^(2:p.Tmax))', 1, max(p.nposts) );
Zs = repmat( bet+ tau+cumsum(tau.^(2:p.Tmax))', 1, max(p.nposts) );
f = 0;
for T=p.Tmin:p.Tmax
    N = p.nposts(T);
    if N>0
        bets = p.ispost{T}*bet;% + ~p.ispost{T};
        R = repmat((2:T)',1,N)-p.sel_post{T}(2:T,:)+1;
        A = log( bets(2:end,:) + tau.^R ) - log(Zs(1:T-1,1:N));
        f = f-sum(A(:));
    end
end
if (x(2)<=0) || (x(2)>=1)
    f = Inf;
end

%fprintf('alpha_p is %.3f, alpha_c is %.3f, tau is %.3f, -loglik=%.6f\n', x(1), x(2), x(3), f);
