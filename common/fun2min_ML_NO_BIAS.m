function f = fun2min_ML_NO_BIAS(x, p)

% CHECKED
alp = x(1);
tau = x(2);

%Zs = repmat(alp*(2*(1:p.Tmax-1)') + tau + (2:p.Tmax)' + cumsum(tau.^(2:p.Tmax))', 1, max(p.nposts));
Zs = repmat(alp*(2*(1:p.Tmax-1)') + tau +cumsum(tau.^(2:p.Tmax))', 1, max(p.nposts));
f = 0;
for T=p.Tmin:p.Tmax
    N = p.nposts(T);
    if N>0
        R = repmat((2:T)',1,N)-p.sel_post{T}(2:T,:)+1;
        %A2 = log((alp.*p.degreeki{T}(2:T,:)) +1+ tau.^R) - log(Zs(1:T-1,1:N));
        A2 = log((alp.*p.degreeki{T}(2:T,:))+ tau.^R) - log(Zs(1:T-1,1:N));
        f = f-sum(A2(:));
    end
end
if (tau<=0) || (tau>=1) || (alp<=0) 
    f = Inf;
end

%fprintf('beta is %.3f, tau is %.3f, lik is %.6f\n', alp, tau, f);
