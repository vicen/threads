% Conclusions:

% mirando los resultados esta claro que el modelo del kumar sin bias
% es comparable a nuestro model sin tau y con bias
% 
% nobias_tau_PAprod
% biasexp_tau_PAexp
% 

% biasexp_tau_PAprod seems to perform best for BP, SL and MN
% however, there are problems for the WKs (overfit?)
% is not stable, multiple local minima.

% biasprod_tau_PAprod perform best for all datasets and results are very
% stable: best candidate.

% biasexp_tau_PAexp is a nice candidate because it's our old model plus
% tau.
%   For MN and SL there's multiple local minima, but global minima can be found
% usually in a few tries.
%   Is very consistent (negative alpha_c for the WKs)
% Rated : 2nd.

% nobias_tau_noPA is a good baseline to check the relevance of the PA
% nobias_tau_PAprod is better than nobias_tau_PAexp
% with these two we can analyze the impact of popularity

% choose best of nobias_notau_PAexp and nobias_notau_PAprod
% with these two we can analyze the impact of novelty
% nobias_notau_PAexp is better than nobias_notau_PAprod (parameter free)

% for the second main result (bias and tau) we have to check nobias_tau and bias_notau
% if nobias_tau is before bias_notau then removing tau is worse than


% btw, what about bias, tau and noPA?


% repeating experiments with nobias_tau_PAexp in cn02, cn03
% seem to be better the likelihoods now

comb = [{'nobias_tau_PAprod'},{'nobias_tau_PAexp'},{'nobias_tau_noPA'},...
        {'biasprod_tau_PAprod'},{'biasprod_notau_PAprod'},{'nobias_notau_PAexp'},...
        {'nobias_notau_PAprod'},{'biasexp_notau_PAexp'},{'biasexp_tau_PAexp'},...
        {'biasexp_tau_PAprod'}];

likelihoods = zeros(7,50,numel(comb));
disp('results:');
for dataset = [1 2 3 6 7],
    switch dataset
      case 1
        str_compact = 'sl_ok';
      case 2
        str_compact = 'bp_ok';
      case 3
        str_compact = 'mn_pub';
      case 6
        str_compact = 'wk_nostructnodes_sort_50000_rnd';
      case 7
        str_compact = 'wk_nostructnodes_split_sort_50000_rnd';
    end
    for d=1:50,
        for c=1:numel(comb)
            str_output = ['output_' str_compact '_subset_' num2str(d) '_' comb{c} '.txt'];
            if exist(str_output, 'file')
                fid = fopen(str_output, 'r');
                output = textscan(fid, '%.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.3f %.3f %d %d %d %d');
                % likelihood is column 11 (see ML_fit.m)
                [lik,idx]=min(output{11});
                likelihoods(dataset, d, c) = lik;
                fclose(fid);
            end            
        end
    end
    means = zeros(1,numel(comb));
    stds = zeros(1,numel(comb));
    for c=1:numel(comb)
        liks = nonzeros(likelihoods(dataset,:,c));
        liks = liks(~isinf(liks));
        means(c) = mean(liks);
        stds(c) = std(liks);
    end
    [a,b]=sort(means);
    for c=1:numel(b),
        fprintf('%d : %s -> %s : \tmean = %.3f(%.3f)\n', c, str_compact, comb{b(c)}, means(b(c)), stds(b(c)));
    end
    disp('---------------------------');
end



% figure(1);clf;
% color = {'r', 'k', 'b', 'm', 'c', 'g'};

%[a,b]=hist(liks,min(liks):max(liks));
    %bar(b,a,color{c},'edgecolor','none');
    %plot(b,a,color{c});
    %hold on;
