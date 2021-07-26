function f = generic_fun2min_ML(x,p)

f = 0;
nn = 0;
for k = 1:numel(p.data.post)  
    vlik = p.hndfmin(numel(p.data.post{k})-1, x, ...
        {p.data.post{k}, p.data.author{k}});
    if any(vlik(3:end)==0)
        disp('vlik')
    elseif any(vlik == Inf)
        f = Inf;
        break;
    else
        nn = nn+1;
        f = f - sum(log(vlik(vlik>0)));
    end
end
%fprintf('\tx = %s, f=%.5e\n', num2str(x'), f);
