function f = fun2min_ML_NO_TAU_cte(x, p)

bet = exp(x(1));
alp = x(2);

cte = 1.5;
f = 0;
Zs = repmat(alp*(2*(1:p.Tmax-1)') + bet +cte*(2:p.Tmax)', 1,max(p.nposts));
for T=p.Tmin:p.Tmax
    N = p.nposts(T);
    if N>0
        bets = p.ispost{T}*bet;% + ~p.ispost{T};
        A2 = log( (p.degreeki{T}(2:T,:))*alp +bets(2:end,:)+cte) - ...
            log(Zs(1:T-1,1:N));
        f = f-sum(A2(:));
    end
end
if alp<=0
    f = Inf;
end

%fprintf('alp is %.3f, bet is %.3f, -loglik=%.6f\n', x(1), x(2), f);
