function f = fun2min_ML_FULL_MODEL(x, p)

% CHECKED
bet = exp(x(1));
alp = x(2);
tau = x(3);

f = 0;
%Zs =  repmat( bet+alp*(2*(1:p.Tmax-1)') + tau + (1:p.Tmax-1)'+cumsum(tau.^(2:p.Tmax))', 1, max(p.nposts) );
Zs =  repmat( bet+alp*(2*(1:p.Tmax-1)') + tau + cumsum(tau.^(2:p.Tmax))', 1, max(p.nposts) );
for T=p.Tmin:p.Tmax
    N = p.nposts(T);
    if N>0
        bets = p.ispost{T}*bet;% + ~p.ispost{T};
        R = repmat((2:T)',1,N)-p.sel_post{T}(2:T,:)+1;
        A = log( alp*p.degreeki{T}(2:T,:) + bets(2:end,:) + tau.^R ) - ...
            log(Zs(1:T-1,1:N));
        f = f-sum(A(:));
    end
end
if (tau<=0) || (tau>=1) || (alp<=0)
    f = Inf;
end

%fprintf('bet = %.3f, alp = %.3f, tau = %.3f, f = %.6f\n', x(1), alp, tau, f);
